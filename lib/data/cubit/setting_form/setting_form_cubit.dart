import 'dart:convert';

import 'package:control_chart/apis/settings/setting_apis.dart';
import 'package:control_chart/bootstrap.dart';
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

  /// Update isUsed flag
  void updateIsUsed(bool isUsed) {
    emit(state.copyWith(isUsed: isUsed));
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
  void updateRuleSelected(List<RuleSelected> rules) {
    emit(state.copyWith(ruleSelected: rules));
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

  /// Add a new specific setting block
  int addSpecificSetting() {
    final now = DateTime.now();

    // 1) เพิ่ม specific ใหม่
    final list = List<SpecificSettingState>.from(state.specifics)
      ..add(SpecificSettingState(
        periodType: PeriodType.ONE_MONTH,
        startDate: DateTime(now.year, now.month - 1, now.day),
        endDate: now,
      ));
    final newIndex = list.length - 1;

    // 2) เตรียม dropdown ต่อ index ให้ว่าง (กัน dropdown โชว์ All อย่างเดียวเพราะ map ไม่มี key)
    final fBy = Map<int, List<String>>.from(state.furnaceOptionsByIndex);
    final cBy = Map<int, List<String>>.from(state.cpOptionsByIndex);
    fBy[newIndex] = <String>[];
    cBy[newIndex] = <String>[];

    // 3) emit state ใหม่
    emit(state.copyWith(
      specifics: list,
      furnaceOptionsByIndex: fBy,
      cpOptionsByIndex: cBy,
    ));

    // 4) บอก index ที่เพิ่ม เพื่อให้ผู้เรียกไปโหลด options ต่อ
    return newIndex;
  }


  /// Remove a specific setting block by index
  void removeSpecificSetting(int index) {
    if (index >= 0 && index < state.specifics.length) {
      final updatedSpecifics = List<SpecificSettingState>.from(state.specifics)
        ..removeAt(index);
      emit(state.copyWith(specifics: updatedSpecifics));
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
      .cast<SpecificSetting>()                           // 👈 บังคับเป็น SpecificSetting
      .map<SpecificSettingState>(SpecificSettingState.fromModel)
      .toList(growable: false);

    emit(state.copyWith(
      id: p.id,                       // <- เก็บ id ที่กำลังแก้
      settingProfileName: p.name,
      displayType: p.profileDisplayType!,
      chartChangeInterval: p.chartChangeInterval!,
      ruleSelected: p.ruleSelected!,
      specifics: specs,
      isUsed: p.active,
    ));
  }

  Future<bool> saveForm({String? id}) async {
    // กันยิงซ้ำระหว่างกำลัง submit หรือ cubit ถูกปิดไปแล้ว
    if (state.status == SubmitStatus.submitting || isClosed) return false;

    // ตรวจความถูกต้องก่อนส่ง
    if (!state.isValid) {
      emit(state.copyWith(
        status: SubmitStatus.failure,
        error: 'Please fill all required fields correctly',
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
        debugPrint('[saveForm] Fail: $msg');
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

      debugPrint('[saveForm] DioException HTTP $status : $msg');
      debugPrint('[saveForm] Stack: $st');

      emit(state.copyWith(status: SubmitStatus.failure, error: msg));
      return false;
    } catch (e, st) {
      debugPrint('[saveForm] Unexpected error: $e');
      debugPrint('[saveForm] Stack: $st');
      emit(state.copyWith(status: SubmitStatus.failure, error: e.toString()));
      return false;
    }
  }

  /// Validate form and return validation errors
  List<String> validateForm() {
    final errors = <String>[];
    
    if (state.settingProfileName.trim().isEmpty) {
      errors.add('โปรดตั้งชื่อโปรไฟล์ตั้งคา');
    }
    
    if (state.chartChangeInterval >= 10 && state.chartChangeInterval <= 3600) {
      errors.add('ระยะเวลาเปลี่ยนหน้าจอต้องอยู่ระหว่าง 10 - 3,600 วินาที');
    }
    
    if (state.specifics.isEmpty) {
      errors.add('โปรดกรอกข้อมูลอย่างน้อย 1 ชุด');
    }

    for (int i = 0; i < state.specifics.length; i++) {
      final sp = state.specifics[i];
      final blockNum = i + 1;
      
      if (sp.periodType == null) {
        errors.add('โปรดกรอกรูปแบบระยะเวลาของ ชุดข้อมูลที่ $blockNum');
      }
      
      if (sp.startDate == null) {
        errors.add('โปรดกรอกรูปแบบวันที่เริ่มต้นของ ชุดข้อมูลที่  $blockNum');
      }
      
      if (sp.endDate == null) {
        errors.add('โปรดกรอกรูปแบบวันที่สิ้นสุดของ ชุดข้อมูลที่ $blockNum');
      }

      if (state.displayType == DisplayType.FURNACE ||
          state.displayType == DisplayType.FURNACE_CP) {
        if (sp.furnaceNo == null) {
          errors.add('โปรดกรอก Furnace No. ชุดข้อมูลที่ $blockNum');
        }
      }
      
      if (state.displayType == DisplayType.CP ||
          state.displayType == DisplayType.FURNACE_CP) {
        if ((sp.cpNo ?? '').trim().isEmpty) {
          errors.add('โปรดกรอก Material No. ชุดข้อมูลที่ $blockNum');
        }
      }
    }
    
    return errors;
  }

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
        : json as Map<String, dynamic>;

    List<String> _toStringList(dynamic v) {
      if (v == null) return <String>[];
      if (v is List) {
        return v.map((e) => e?.toString()).whereType<String>().toList();
      }
      return <String>[v.toString()];
    }

    final furnaces = _toStringList(payload['furnaceNo']);
    final cps      = _toStringList(payload['cpNo']);

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





}