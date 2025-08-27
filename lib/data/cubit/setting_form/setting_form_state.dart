import 'package:control_chart/domain/models/setting_request.dart';
import 'package:flutter/material.dart';

enum SubmitStatus { idle, submitting, success, failure }
enum DisplayTypeReq { FURNACE, FURNACE_CP, CP }
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
}

/// One repeatable block in the form
class SpecificSetting {
  final PeriodTypeReq? periodType;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? furnaceNo;
  final String? cpNo;

  const SpecificSetting({
    this.periodType,
    this.startDate,
    this.endDate,
    this.furnaceNo,
    this.cpNo,
  });

  SpecificSetting copyWith({
    PeriodTypeReq? periodType,
    DateTime? startDate,
    DateTime? endDate,
    int? furnaceNo,
    String? cpNo,
  }) {
    return SpecificSetting(
      periodType: periodType ?? this.periodType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      furnaceNo: furnaceNo ?? this.furnaceNo,
      cpNo: cpNo ?? this.cpNo,
    );
  }
}

/// Single state object with a status enum
class SettingFormState {
  final String settingProfileName;
  final bool isUsed;
  final DisplayTypeReq displayType;
  final int chartChangeInterval;
  final List<RuleSelected> ruleSelected;
  final List<SpecificSetting> specifics;
  final SubmitStatus status;
  final String? error;

  const SettingFormState({
    this.settingProfileName = '',
    this.isUsed = true,
    this.displayType = DisplayTypeReq.FURNACE_CP,
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

      if (displayType == DisplayTypeReq.FURNACE ||
          displayType == DisplayTypeReq.FURNACE_CP) {
        if (sp.furnaceNo == null) return false;
      }
      if (displayType == DisplayTypeReq.CP ||
          displayType == DisplayTypeReq.FURNACE_CP) {
        if ((sp.cpNo ?? '').trim().isEmpty) return false;
      }
    }
    return true;
  }



  SettingFormState copyWith({
    String? settingProfileName,
    bool? isUsed,
    DisplayTypeReq? displayType,
    int? chartChangeInterval,
    List<RuleSelected>? ruleSelected,
    List<SpecificSetting>? specifics,
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
