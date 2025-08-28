import 'package:control_chart/domain/models/setting.dart';
import 'package:control_chart/domain/models/setting_request.dart';
import 'package:flutter/material.dart';

enum SubmitStatus { idle, submitting, success, failure }
enum PeriodTypeReq { ONE_MONTH, THREE_MONTHS, SIX_MONTHS, ONE_YEAR, CUSTOM, LIFETIME }

class RuleSelected {
  final int? ruleId;
  final String? ruleName;
  final bool? isUsed;

  const RuleSelected({
    this.ruleId,
    this.ruleName,
    this.isUsed,
  });

  RuleSelected copyWith({
    int? ruleId,
    String? ruleName,
    bool? isUsed,
  }) {
    return RuleSelected(
      ruleId: ruleId ?? this.ruleId,
      ruleName: ruleName ?? this.ruleName,
      isUsed: isUsed ?? this.isUsed,
    );
  }

  /// factory สำหรับแปลงจาก NelsonRule → RuleSelected
  factory RuleSelected.fromNelson(NelsonRule n) {
    return RuleSelected(
      ruleId: n.ruleId,
      ruleName: n.ruleName,
      isUsed: n.isUsed,
    );
  }

  @override
  String toString() =>
      'RuleSelected(ruleId: $ruleId, ruleName: $ruleName, isUsed: $isUsed)';
}


class SpecificSettingState {
  final PeriodType? periodType;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? furnaceNo;
  final String? cpNo;

  const SpecificSettingState({
    this.periodType,
    this.startDate,
    this.endDate,
    this.furnaceNo,
    this.cpNo,
  });

  SpecificSettingState copyWith({
    PeriodType? periodType,
    DateTime? startDate,
    DateTime? endDate,
    int? furnaceNo,
    String? cpNo,
  }) {
    return SpecificSettingState(
      periodType: periodType ?? this.periodType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      furnaceNo: furnaceNo ?? this.furnaceNo,
      cpNo: cpNo ?? this.cpNo,
    );
  }

  /// ✅ แปลงจาก Domain Model → State
  factory SpecificSettingState.fromModel(SpecificSetting model) {
    return SpecificSettingState(
      periodType: model.period?.type,
      startDate: model.period?.startDate,
      endDate: model.period?.endDate,
      furnaceNo: model.furnaceNo,
      cpNo: model.cpNo,
    );
  }

  /// ✅ แปลงจาก State → Domain Model
  SpecificSetting toModel() {
    return SpecificSetting(
      period: Period(
        type: periodType ?? PeriodType.ONE_MONTH, // default fallback
        startDate: startDate,
        endDate: endDate,
      ),
      furnaceNo: furnaceNo,
      cpNo: cpNo,
    );
  }

  @override
  String toString() {
    return 'SpecificSettingState(periodType: $periodType, '
        'startDate: $startDate, endDate: $endDate, '
        'furnaceNo: $furnaceNo, cpNo: $cpNo)';
  }
}


/// Single state object with a status enum
class SettingFormState {
  final String settingProfileName;
  final bool isUsed;
  final DisplayType displayType;
  final int chartChangeInterval;
  final List<RuleSelected> ruleSelected;
  final List<SpecificSettingState> specifics;
  final SubmitStatus status;
  final String? error;

  const SettingFormState({
    this.settingProfileName = '',
    this.isUsed = true,
    this.displayType = DisplayType.FURNACE_CP,
    this.chartChangeInterval = 45,
    this.ruleSelected = const [],
    this.specifics = const [],
    this.status = SubmitStatus.idle,
    this.error,
  });

  bool get isValid {
    if (settingProfileName.trim().isEmpty) return false;
    if (chartChangeInterval <= 10) return false;
    if (specifics.isEmpty) return false;

    for (final sp in specifics) {
      if (sp.periodType == null ||
          sp.startDate == null ||
          sp.endDate == null) {
        return false;
      }

      if (displayType == DisplayType.FURNACE ||
          displayType == DisplayType.FURNACE_CP) {
        if (sp.furnaceNo == null) return false;
      }
      if (displayType == DisplayType.CP ||
          displayType == DisplayType.FURNACE_CP) {
        if ((sp.cpNo ?? '').trim().isEmpty) return false;
      }
    }
    return true;
  }



  SettingFormState copyWith({
    String? settingProfileName,
    bool? isUsed,
    DisplayType? displayType,
    int? chartChangeInterval,
    List<RuleSelected>? ruleSelected,
    List<SpecificSettingState>? specifics,
    SubmitStatus? status,
    String? error,
  }) {
    return SettingFormState(
      settingProfileName: settingProfileName ?? this.settingProfileName,
      isUsed: isUsed ?? this.isUsed,
      displayType: displayType ?? this.displayType,
      chartChangeInterval: chartChangeInterval ?? this.chartChangeInterval,
      ruleSelected: ruleSelected ?? this.ruleSelected,
      specifics: specifics ?? this.specifics,
      status: status ?? this.status,
      error: error,
    );
  }
}
