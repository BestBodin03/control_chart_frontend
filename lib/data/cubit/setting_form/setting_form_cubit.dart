import 'dart:convert';

import 'package:control_chart/apis/settings/setting_apis.dart';
import 'package:control_chart/bootstrap.dart';
import 'package:control_chart/data/bloc/setting_profile/setting_profile_bloc.dart';
import 'package:control_chart/data/cubit/setting_form/extension/setting_form_state_to_request.dart';
import 'package:control_chart/data/cubit/setting_form/setting_form_state.dart';
import 'package:control_chart/data/shared_preference/tv_setting_profile_pref.dart';
import 'package:control_chart/data/shared_preference/tv_setting_profile_state.dart';
import 'package:control_chart/domain/models/setting.dart';
import 'package:control_chart/domain/models/setting_dynamic_dropdown.dart';
import 'package:control_chart/ui/screen/home_screen.dart';
import 'package:control_chart/ui/screen/screen_content/home_screen_content/home_content_var.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/component/profile/profile.dart';
import 'package:control_chart/utils/app_store.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/models/chart_detail.dart';

class SettingFormCubit extends Cubit<SettingFormState> {
  // Inject your repository/service here
  final SettingApis _settingApis;
  final prefs = TvSettingProfilePref();

  SettingFormCubit(
    this._settingApis,
  ) : super(const SettingFormState());

  /// Update setting profile name
  void updateSettingProfileName(String name) {
    emit(state.copyWith(settingProfileName: name));
  }

  void updateSettingProfileId(String? id) {
    emit(state.copyWith(profileId: id));
  }

  /// Update isUsed flag
  void updateIsUsed(bool isUsed) {
    emit(state.copyWith(isUsed: isUsed));
  }

  void updateCountsFrom(List<ChartDetail> chartDetails) {
    final updated = state.specifics.map((sp) {
      final count = chartDetails.where((c) =>
        (sp.furnaceNo == null || c.chartGeneralDetail.furnaceNo == sp.furnaceNo) &&
        (sp.cpNo == null || c.cpNo == sp.cpNo)
      ).length;

      return sp.copyWith(recordCount: count);
    }).toList();

    emit(state.copyWith(specifics: updated));
  }


  /// Update display type
  void updateDisplayType(DisplayType displayType) {
    emit(state.copyWith(displayType: displayType));
  }

  /// Update chart change interval
  void updateChartChangeInterval(int interval) {
    emit(state.copyWith(chartChangeInterval: interval));
  }

  /// Update rule selection
  void updateRuleSelected() {
    // บังคับเลือกทุกกฎ
    final rules = <RuleSelected>[
      const RuleSelected(
        ruleId: 1,
        ruleName: 'Beyond Limit',
        isUsed: true,
      ),
      const RuleSelected(
        ruleId: 3,
        ruleName: 'Trend',
        isUsed: true,
      ),
    ];

    emit(state.copyWith(ruleSelected: rules));
  }


Future<void> preloadCounts(Profile profile, List<ChartDetail> details) async {
  updateSpecifics(profile.specifics!);
  updateCountsFrom(details);
  await Future.delayed(Duration.zero);
}



  /// Add or update a single rule
  void updateSingleRule(int index, RuleSelected rule) {
    final updatedRules = List<RuleSelected>.from(state.ruleSelected);
    if (index < updatedRules.length) {
      updatedRules[index] = rule;
    } else {
      updatedRules.add(rule);
    }
    emit(state.copyWith(ruleSelected: updatedRules));
  }

  /// Toggle rule usage by rule ID
  void toggleRuleUsage(int ruleId) {
    final updatedRules = state.ruleSelected.map((rule) {
      if (rule.ruleId == ruleId) {
        return rule.copyWith(isUsed: !(rule.isUsed ?? false));
      }
      return rule;
    }).toList();
    emit(state.copyWith(ruleSelected: updatedRules));
  }

  /// Update all specific settings
  void updateSpecifics(List<SpecificSettingState> specifics) {
    emit(state.copyWith(specifics: specifics));
  }

  // Update existing addSpecificSetting method
  int addSpecificSetting() {
    // Create new setting with global period values
    final newSetting = SpecificSettingState(
      periodType: state.globalPeriodType ?? PeriodType.ONE_MONTH,
      startDate: state.globalStartDate ?? DateTime.now().subtract(const Duration(days: 30)),
      endDate: state.globalEndDate ?? DateTime.now(),
    );

    final list = List<SpecificSettingState>.from(state.specifics)..add(newSetting);
    final newIndex = list.length - 1;

    // Prepare empty dropdown options for the new index
    final fBy = Map<int, List<String>>.from(state.furnaceOptionsByIndex);
    final cBy = Map<int, List<String>>.from(state.cpOptionsByIndex);
    fBy[newIndex] = <String>[];
    cBy[newIndex] = <String>[];

    emit(state.copyWith(
      specifics: list,
      furnaceOptionsByIndex: fBy,
      cpOptionsByIndex: cBy,
    ));

    return newIndex;
  }

  void removeSpecificSetting(int index) async {
    if (index >= 0 && index < state.specifics.length) {
      final updated = List<SpecificSettingState>.from(state.specifics)
        ..removeAt(index);
      emit(state.copyWith(specifics: updated));
      
      // 👇 Load ทุกแถวพร้อมกัน (เร็วกว่า)
      await Future.wait([
        for (int i = 0; i < updated.length; i++)
          loadDropdownOptions(
            index: i,
            furnaceNo: updated[i].furnaceNo?.toString(),
            cpNo: updated[i].cpNo,
          ),
      ]);
    }
  }


  /// Update a specific setting block by index
  void updateSpecificSetting(int index, SpecificSettingState setting) {
    if (index >= 0 && index < state.specifics.length) {
      final updatedSpecifics = List<SpecificSettingState>.from(state.specifics);
      updatedSpecifics[index] = setting;
      emit(state.copyWith(specifics: updatedSpecifics));
    }
  }

  /// Update period type for a specific setting
  void updatePeriodType(int index, PeriodType periodType) {
    if (index >= 0 && index < state.specifics.length) {
      final currentSetting = state.specifics[index];
      final updatedSetting = currentSetting.copyWith(periodType: periodType);
      updateSpecificSetting(index, updatedSetting);
    }
  }

  /// Update start date for a specific setting
  void updateStartDate(int index, DateTime date, {bool setCustom = false}) {
    final s = state.specifics[index];
    updateSpecificSetting(index, s.copyWith(
      startDate: date,
      periodType: setCustom ? PeriodType.CUSTOM : s.periodType,
    ));
  }


  /// Update end date for a specific setting
  void updateEndDate(int index, DateTime endDate, {bool setCustom = false}) {
    final s = state.specifics[index];
    updateSpecificSetting(index, s.copyWith(
        endDate: endDate,
      periodType: setCustom ? PeriodType.CUSTOM : s.periodType,
    ));
}

  /// Update furnace number for a specific setting
  void updateFurnaceNo(int index, int? furnaceNo) {
    if (index >= 0 && index < state.specifics.length) {
      final currentSetting = state.specifics[index];
      final updatedSetting = currentSetting.copyWith(furnaceNo: furnaceNo);
      updateSpecificSetting(index, updatedSetting);
    }
  }

  /// Update CP number for a specific setting
  void updateCpNo(int index, String? cpNo) {
    if (index >= 0 && index < state.specifics.length) {
      final currentSetting = state.specifics[index];
      final updatedSetting = currentSetting.copyWith(cpNo: cpNo);
      updateSpecificSetting(index, updatedSetting);
    }
  }

  /// Clear any error state
  void clearError() {
    if (state.error != null) {
      emit(state.copyWith(error: null));
    }
  }

  /// Reset form to initial state
  void resetForm() {
    emit(const SettingFormState());
  }

  /// Load existing settings (e.g., for editing)
  void loadSettings(SettingFormState existingState) {
    emit(existingState.copyWith(status: SubmitStatus.idle, error: null));
  }

  Future<SettingDynamicDropdownResponse> getDynamicFurnaceDropdown({
    String? furnaceNo,
    String? cpNo,
  }) async {
    try {
      // เรียก API
      final result = await _settingApis.getSettingFormDropdown(
        furnaceNo: furnaceNo,
        cpNo: cpNo,
      );

      // แปลงเป็น Model
      return SettingDynamicDropdownResponse.fromJson(result);
    } catch (e) {
      rethrow; // หรือ emit error state ตามต้องการ
    }
  }

  void startEdit(Profile p) {
    final specs = (p.specifics ?? const <dynamic>[])
        .cast<SpecificSetting>()
        .map<SpecificSettingState>(SpecificSettingState.fromModel)
        .toList(growable: false);

    // Set global period from first specific (assuming all have same period)
    PeriodType? globalPeriod;
    DateTime? globalStart;
    DateTime? globalEnd;
    
    if (specs.isNotEmpty) {
      globalPeriod = specs.first.periodType;
      globalStart = specs.first.startDate;
      globalEnd = specs.first.endDate;
    }

    emit(state.copyWith(
      profileId: p.profileId,
      settingProfileName: p.name,
      displayType: p.profileDisplayType!,
      chartChangeInterval: p.chartChangeInterval!,
      ruleSelected: p.ruleSelected!,
      specifics: specs,
      isUsed: p.active,
      // Initialize global period settings
      globalPeriodType: globalPeriod,
      globalStartDate: globalStart,
      globalEndDate: globalEnd,
    ));
  }

  Future<bool> saveForm({String? id}) async {
    // กันยิงซ้ำระหว่างกำลัง submit หรือ cubit ถูกปิดไปแล้ว
    if (state.status == SubmitStatus.submitting || isClosed) return false;
    // debugPrint(state.copyWith().toString());

    // ตรวจความถูกต้องก่อนส่ง
    if (!state.isValid) {
      emit(state.copyWith(
        status: SubmitStatus.failure,
        error: 'โปรดกรอกข้อมูลให้ครบถ้วน',
      ));
      return false;
    }
  
    // ตรวจความถูกต้องก่อนส่ง
    final validationErrors = validateForm();
    if (validationErrors.isNotEmpty) {
      emit(state.copyWith(
        status: SubmitStatus.failure,
        error: validationErrors.first,
      ));
      return false;
    }

    // สถานะกำลังส่ง
    emit(state.copyWith(status: SubmitStatus.submitting, error: null));

    // สร้างแมพ ruleNameById แบบปลอดภัยต่อ null/ค่าว่าง
    final Map<int, String> ruleNameById = {};
    for (final r in state.ruleSelected) {
      final rid = r.ruleId;
      final name = r.ruleName?.trim();
      if (rid != null && name != null && name.isNotEmpty) {
        ruleNameById[rid] = name;
      }
    }

    // กัน path ผิดกรณี id เป็น "" หรือ "   "
    final String? safeId =
        (id == null || id.trim().isEmpty) ? null : id.trim();

    try {
      // เรียก API → ได้ JSON (Map) กลับมา
      final Map<String, dynamic> res = safeId == null
          ? await _settingApis.addNewSettingProfile(state, ruleNameById: ruleNameById)
          : await _settingApis.updateSettingProfile(safeId, state, ruleNameById: ruleNameById);

      // อ่านคีย์มาตรฐาน ถ้ามี
      final bool? okPayload = res['success'] as bool?;
      final String? serverMsg = (res['message'] ?? res['error'])?.toString();

      // ถ้า backend ไม่มีฟิลด์ success เลย ให้ถือว่า success ตามปกติ
      final bool isSuccess = okPayload == null || okPayload == true;

      if (isSuccess) {
        emit(state.copyWith(status: SubmitStatus.success));

        final prefs = TvSettingProfilePref();
        final api = SettingApis();
        final newTvProfile = await bootstrap(prefs: prefs, api: api);
        prefs.clear();

        // map prefs -> List<HomeContentVar> (ให้แน่ใจว่า listFromPrefs คืน "ลิสต์")
        final List<HomeContentVar> newProfiles =
            (newTvProfile is TvSettingProfileLoaded)
                ? HomeContentVar.listFromPrefs(newTvProfile.data)
                : <HomeContentVar>[];

        // ✅ อัปเดตตัวกลาง → MyHomeScreen จะรีบิลด์เอง
        AppStore.instance.homeProfiles.value = newProfiles;
        return true;
      } else {
        final msg = serverMsg ?? 'Unexpected response: ${res.toString()}';
        // debugPrint('[saveForm] Fail: $msg');
        emit(state.copyWith(status: SubmitStatus.failure, error: msg));
        return false;
      }
    } on DioException catch (e, st) {
      // ดึงข้อความจากฝั่งเซิร์ฟเวอร์ให้มากที่สุด
      String msg = e.message ?? 'Network error';
      final status = e.response?.statusCode;
      final data = e.response?.data;

      // พยายามอ่าน message/error จาก payload
      if (data is Map<String, dynamic>) {
        msg = (data['message'] ?? data['error'] ?? msg).toString();
      } else if (data != null) {
        msg = data.toString();
      }

      // จับเคสต่อเซิร์ฟเวอร์ไม่ได้ให้ข้อความอ่านง่าย
      if (e.type == DioExceptionType.connectionError &&
          (msg.contains('ECONNREFUSED') || msg.contains('Connection refused'))) {
        msg = 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้ (connection refused)';
      }

      // debugPrint('[saveForm] DioException HTTP $status : $msg');
      // debugPrint('[saveForm] Stack: $st');

      emit(state.copyWith(status: SubmitStatus.failure, error: msg));
      return false;
    } catch (e, st) {
      // debugPrint('[saveForm] Unexpected error: $e');
      // debugPrint('[saveForm] Stack: $st');
      emit(state.copyWith(status: SubmitStatus.failure, error: e.toString()));
      return false;
    }
  }

/// Validate form and return validation errors
List<String> validateForm() {
  final errors = <String>[];
  
  // Validate profile name
  if (state.settingProfileName.trim().isEmpty) {
    errors.add('โปรดตั้งชื่อโปรไฟล์การตั้งค่า');
  } else {
    // Check for special characters (allow only letters, numbers, spaces, and Thai characters)
    final nameRegex = RegExp(r'^[a-zA-Z0-9ก-๙\s]+$');
    if (!nameRegex.hasMatch(state.settingProfileName)) {
      errors.add('ชื่อโปรไฟล์ไม่สามารถมีอักขระพิเศษได้');
    }
  }
  
  // Validate chart change interval
  if (state.chartChangeInterval < 20) {
    errors.add('ระยะเวลาเปลี่ยนหน้าจอต้องมากกว่า 20 วินาที');
  } else if (state.chartChangeInterval > 3600) {
    errors.add('ระยะเวลาเปลี่ยนหน้าจอต้องไม่เกิน 3,600 วินาที');
  }
  
  // Check if there's at least one specific setting
  if (state.specifics.isEmpty) {
    errors.add('โปรดกรอกข้อมูลอย่างน้อย 1 ชุด');
  }

  // Validate each specific setting
  for (int i = 0; i < state.specifics.length; i++) {
    final sp = state.specifics[i];
    final blockNum = i + 1;
    
    if (sp.periodType == null) {
      errors.add('โปรดกรอกรูปแบบระยะเวลาของชุดข้อมูลที่ $blockNum');
    }
    
    if (sp.startDate == null) {
      errors.add('โปรดกรอกวันที่เริ่มต้นของชุดข้อมูลที่ $blockNum');
    }
    
    if (sp.endDate == null) {
      errors.add('โปรดกรอกวันที่สิ้นสุดของชุดข้อมูลที่ $blockNum');
    }

    // Validate date range
    if (sp.startDate != null && sp.endDate != null) {
      if (sp.startDate!.isAfter(sp.endDate!)) {
        errors.add('วันที่เริ่มต้นต้องไม่เกินวันที่สิ้นสุดของชุดข้อมูลที่ $blockNum');
      }
    }

    // Validate based on display type
    if (state.displayType == DisplayType.FURNACE ||
        state.displayType == DisplayType.FURNACE_CP) {
      if (sp.furnaceNo == null) {
        errors.add('โปรดเลือก Furnace No. ของชุดข้อมูลที่ $blockNum');
      }
    }
    
    if (state.displayType == DisplayType.CP ||
        state.displayType == DisplayType.FURNACE_CP) {
      if ((sp.cpNo ?? '').trim().isEmpty) {
        errors.add('โปรดเลือก Material No. ของชุดข้อมูลที่ $blockNum');
      }
    }
  }
  
  return errors;
}

/// Validate form with external chart details
List<String> validateFormWithChartDetails(List<ChartDetail> chartDetails) {
  final errors = <String>[];
  
  // Validate profile name
  if (state.settingProfileName.trim().isEmpty) {
    errors.add('โปรดตั้งชื่อโปรไฟล์การตั้งค่า');
  } else {
    // Check for special characters (allow only letters, numbers, spaces, and Thai characters)
    final nameRegex = RegExp(r'^[a-zA-Z0-9ก-๙\s]+$');
    if (!nameRegex.hasMatch(state.settingProfileName)) {
      errors.add('ชื่อโปรไฟล์ไม่สามารถมีอักขระพิเศษได้');
    }
  }
  
  // Validate chart change interval
  if (state.chartChangeInterval < 20) {
    errors.add('ระยะเวลาเปลี่ยนหน้าจอต้องมากกว่า 20 วินาที');
  } else if (state.chartChangeInterval > 3600) {
    errors.add('ระยะเวลาเปลี่ยนหน้าจอต้องไม่เกิน 3,600 วินาที');
  }
  
  // Check if there's at least one specific setting
  if (state.specifics.isEmpty) {
    errors.add('โปรดกรอกข้อมูลอย่างน้อย 1 ชุด');
  }

  // Validate each specific setting
  for (int i = 0; i < state.specifics.length; i++) {
    final sp = state.specifics[i];
    final blockNum = i + 1;
    
    if (sp.periodType == null) {
      errors.add('โปรดกรอกรูปแบบระยะเวลาของชุดข้อมูลที่ $blockNum');
    }
    
    if (sp.startDate == null) {
      errors.add('โปรดกรอกวันที่เริ่มต้นของชุดข้อมูลที่ $blockNum');
    }
    
    if (sp.endDate == null) {
      errors.add('โปรดกรอกวันที่สิ้นสุดของชุดข้อมูลที่ $blockNum');
    }

    // Validate date range
    if (sp.startDate != null && sp.endDate != null) {
      if (sp.startDate!.isAfter(sp.endDate!)) {
        errors.add('วันที่เริ่มต้นต้องไม่เกินวันที่สิ้นสุดของชุดข้อมูลที่ $blockNum');
      }
    }

    // Validate based on display type
    if (state.displayType == DisplayType.FURNACE ||
        state.displayType == DisplayType.FURNACE_CP) {
      if (sp.furnaceNo == null) {
        errors.add('โปรดเลือก Furnace No. ของชุดข้อมูลที่ $blockNum');
      }
    }
    
    if (state.displayType == DisplayType.CP ||
        state.displayType == DisplayType.FURNACE_CP) {
      if ((sp.cpNo ?? '').trim().isEmpty) {
        errors.add('โปรดเลือก Material No. ของชุดข้อมูลที่ $blockNum');
      }
    }

    // Validate record count using provided chartDetails
    final recordCount = _getRecordCountFromChartDetails(sp, chartDetails);
    if (recordCount < 5) {
      errors.add('ชุดข้อมูลที่ $blockNum ต้องมีข้อมูลอย่างน้อย 5 รายการ (ปัจจุบันมี $recordCount รายการ)');
    }
  }
  
  return errors;
}

/// Helper method to count records from external chart details
int _getRecordCountFromChartDetails(
  SpecificSettingState sp,
  List<ChartDetail> chartDetails,
) {
  if (chartDetails.isEmpty) return 0;
  
  final filtered = chartDetails.where((c) {
    final matchFurnace = sp.furnaceNo == null || 
        c.chartGeneralDetail.furnaceNo == sp.furnaceNo;
    final matchCp = sp.cpNo == null || c.cpNo == sp.cpNo;
    return matchFurnace && matchCp;
  });
  
  return filtered.length;
}

  // /// Validate form and return validation errors
  // List<String> validateForm() {
  //   final errors = <String>[];
    
  //   if (state.settingProfileName.trim().isEmpty) {
  //     errors.add('โปรดตั้งชื่อโปรไฟล์ตั้งคา');
  //   }
    
  //   if (state.chartChangeInterval >= 10 && state.chartChangeInterval <= 3600) {
  //     errors.add('ระยะเวลาเปลี่ยนหน้าจอต้องอยู่ระหว่าง 10 - 3,600 วินาที');
  //   }
    
  //   if (state.specifics.isEmpty) {
  //     errors.add('โปรดกรอกข้อมูลอย่างน้อย 1 ชุด');
  //   }

  //   for (int i = 0; i < state.specifics.length; i++) {
  //     final sp = state.specifics[i];
  //     final blockNum = i + 1;
      
  //     if (sp.periodType == null) {
  //       errors.add('โปรดกรอกรูปแบบระยะเวลาของ ชุดข้อมูลที่ $blockNum');
  //     }
      
  //     if (sp.startDate == null) {
  //       errors.add('โปรดกรอกรูปแบบวันที่เริ่มต้นของ ชุดข้อมูลที่  $blockNum');
  //     }
      
  //     if (sp.endDate == null) {
  //       errors.add('โปรดกรอกรูปแบบวันที่สิ้นสุดของ ชุดข้อมูลที่ $blockNum');
  //     }

  //     if (state.displayType == DisplayType.FURNACE ||
  //         state.displayType == DisplayType.FURNACE_CP) {
  //       if (sp.furnaceNo == null) {
  //         errors.add('โปรดกรอก Furnace No. ชุดข้อมูลที่ $blockNum');
  //       }
  //     }
      
  //     if (state.displayType == DisplayType.CP ||
  //         state.displayType == DisplayType.FURNACE_CP) {
  //       if ((sp.cpNo ?? '').trim().isEmpty) {
  //         errors.add('โปรดกรอก Material No. ชุดข้อมูลที่ $blockNum');
  //       }
  //     }
  //   }
    
  //   return errors;
  // }

Future<void> loadDropdownOptions({
  required int index,
  String? furnaceNo,
  String? cpNo,
}) async {
  emit(state.copyWith(dropdownLoading: true));
  try {
    final json = await _settingApis.getSettingFormDropdown(
      furnaceNo: furnaceNo,
      cpNo: cpNo,
    );

    final payload = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;

    List<String> toStringList(dynamic v) {
      if (v == null) return <String>[];
      if (v is List) {
        return v.map((e) => e?.toString()).whereType<String>().toList();
      }
      return <String>[v.toString()];
    }

    final furnaces = toStringList(payload['furnaceNo']);
    final cps      = toStringList(payload['cpNo']);

    // ✅ update ตาม index
    final fBy = Map<int, List<String>>.from(state.furnaceOptionsByIndex);
    final cBy = Map<int, List<String>>.from(state.cpOptionsByIndex);
    fBy[index] = furnaces;
    cBy[index] = cps;

    emit(state.copyWith(
      dropdownLoading: false,
      furnaceOptionsByIndex: fBy,
      cpOptionsByIndex: cBy,
    ));
  } catch (e) {
    emit(state.copyWith(dropdownLoading: false));
  }
}

Future<bool> removeSettingProfile({
  required List<String> profileIds,
}) async {
  // กันเคสกดซ้ำตอนกำลัง process
  if (state.status == SubmitStatus.submitting || isClosed) return false;

  if (profileIds.isEmpty) {
    emit(state.copyWith(
      status: SubmitStatus.failure,
      error: 'โปรดเลือกโปรไฟล์อย่างน้อย 1 รายการ',
    ));
    return false;
  }

  emit(state.copyWith(status: SubmitStatus.submitting, error: null));

  try {
    // เรียก API ลบหลายรายการ
    final res = await _settingApis.removeSettingProfiles(ids: profileIds);

    // รองรับ 204 / ไม่มี body -> ถือว่าสำเร็จ
    final ok = (res == null) ? true : ((res['success'] as bool?) ?? true);
    final msg = res == null ? null : (res['message'] ?? res['error'])?.toString();

    if (ok) {
      emit(state.copyWith(status: SubmitStatus.success));
      return true;
    } else {
      emit(state.copyWith(status: SubmitStatus.failure, error: msg ?? 'ลบโปรไฟล์ไม่สำเร็จ'));
      return false;
    }
  } on DioException catch (e) {
    String err = e.message ?? 'Network error';
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      err = (data['message'] ?? data['error'] ?? err).toString();
    }
    emit(state.copyWith(status: SubmitStatus.failure, error: err));
    return false;
  } catch (e) {
    emit(state.copyWith(status: SubmitStatus.failure, error: e.toString()));
    return false;
  }
}
}