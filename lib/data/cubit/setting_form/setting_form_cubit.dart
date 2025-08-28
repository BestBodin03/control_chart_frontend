import 'package:control_chart/apis/settings/setting_apis.dart';
import 'package:control_chart/data/cubit/setting_form/extension/setting_form_state_to_request.dart';
import 'package:control_chart/data/cubit/setting_form/setting_form_state.dart';
import 'package:control_chart/domain/models/setting.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingFormCubit extends Cubit<SettingFormState> {
  // Inject your repository/service here
  final SettingApis _settingApis;

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
  void addSpecificSetting() {
    final now = DateTime.now();
    final updatedSpecifics = List<SpecificSettingState>.from(state.specifics)
      ..add(SpecificSettingState(
        periodType: PeriodType.ONE_MONTH,
        startDate: DateTime(now.year, now.month - 1, now.day),
        endDate: now,
      ));
    emit(state.copyWith(specifics: updatedSpecifics));
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
  void updateStartDate(int index, DateTime startDate) {
    if (index >= 0 && index < state.specifics.length) {
      final currentSetting = state.specifics[index];
      final updatedSetting = currentSetting.copyWith(startDate: startDate);
      updateSpecificSetting(index, updatedSetting);
    }
  }

  /// Update end date for a specific setting
  void updateEndDate(int index, DateTime endDate) {
    if (index >= 0 && index < state.specifics.length) {
      final currentSetting = state.specifics[index];
      final updatedSetting = currentSetting.copyWith(endDate: endDate);
      updateSpecificSetting(index, updatedSetting);
    }
  }

  /// Update furnace number for a specific setting
  void updateFurnaceNo(int index, int furnaceNo) {
    if (index >= 0 && index < state.specifics.length) {
      final currentSetting = state.specifics[index];
      final updatedSetting = currentSetting.copyWith(furnaceNo: furnaceNo);
      updateSpecificSetting(index, updatedSetting);
    }
  }

  /// Update CP number for a specific setting
  void updateCpNo(int index, String cpNo) {
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

Future<bool> saveForm({String? id}) async {
  if (state.status == SubmitStatus.submitting) return false;

  if (!state.isValid) {
    emit(state.copyWith(
      status: SubmitStatus.failure,
      error: 'Please fill all required fields correctly',
    ));
    return false;
  }

  emit(state.copyWith(status: SubmitStatus.submitting, error: null));

  // build ruleNameById from current state
  final ruleNameById = <int, String>{
    for (final r in state.ruleSelected)
      if (r.ruleId != null && (r.ruleName?.trim().isNotEmpty ?? false))
        r.ruleId!: r.ruleName!.trim(),
  };

  try {

    if (id == null) {
      print('Creating');
      // CREATE
      await _settingApis.addNewSettingProfile(
        state,
        ruleNameById: ruleNameById,
      );
    } else {
      print('Updating');
      print(id);
      // UPDATE (send id in path param)
      await _settingApis.updateSettingProfile(
        id,
        state,
        ruleNameById: ruleNameById,
      );
    }

    emit(state.copyWith(status: SubmitStatus.success));
    return true;
  } catch (e) {
    emit(state.copyWith(
      status: SubmitStatus.failure,
      error: e.toString(),
    ));
  }
  return false;
}




  /// Validate form and return validation errors
  List<String> validateForm() {
    final errors = <String>[];
    
    if (state.settingProfileName.trim().isEmpty) {
      errors.add('Setting profile name is required');
    }
    
    if (state.chartChangeInterval <= 10) {
      errors.add('Chart change interval must be greater than 10');
    }
    
    if (state.specifics.isEmpty) {
      errors.add('At least one specific setting is required');
    }

    for (int i = 0; i < state.specifics.length; i++) {
      final sp = state.specifics[i];
      final blockNum = i + 1;
      
      if (sp.periodType == null) {
        errors.add('Period type is required for block $blockNum');
      }
      
      if (sp.startDate == null) {
        errors.add('Start date is required for block $blockNum');
      }
      
      if (sp.endDate == null) {
        errors.add('End date is required for block $blockNum');
      }

      if (state.displayType == DisplayType.FURNACE ||
          state.displayType == DisplayType.FURNACE_CP) {
        if (sp.furnaceNo == null) {
          errors.add('Furnace number is required for block $blockNum');
        }
      }
      
      if (state.displayType == DisplayType.CP ||
          state.displayType == DisplayType.FURNACE_CP) {
        if ((sp.cpNo ?? '').trim().isEmpty) {
          errors.add('CP number is required for block $blockNum');
        }
      }
    }
    
    return errors;
  }
}