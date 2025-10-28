import 'dart:core';

import 'package:control_chart/domain/models/setting.dart';
import 'package:intl/intl.dart';

class SettingFormState {
  final String profileId;
  final String settingProfileName;
  final bool isUsed;
  final DisplayType displayType;
  final int chartChangeInterval;
  final List<RuleSelected> ruleSelected;
  final List<SpecificSettingState> specifics;
  final SubmitStatus status;
  final String? error;

  // Global period settings (shared by all specifics)
  final PeriodType? globalPeriodType;
  final DateTime? globalStartDate;
  final DateTime? globalEndDate;

  // Dynamic dropdown (per index)
  final bool dropdownLoading;
  final Map<int, List<String>> furnaceOptionsByIndex;
  final Map<int, List<String>> cpOptionsByIndex;
  final Map<int, List<String>> cpNameOptionsByIndex;

  final int recordCount;

  const SettingFormState({
    this.profileId = '',
    this.settingProfileName = '',
    this.isUsed = true,
    this.displayType = DisplayType.FURNACE_CP,
    this.chartChangeInterval = 45,
    this.ruleSelected = const [],
    this.specifics = const [],
    this.status = SubmitStatus.idle,
    this.error,
    // Global period defaults
    this.globalPeriodType,
    this.globalStartDate,
    this.globalEndDate,
    // Dropdown
    this.dropdownLoading = false,
    this.furnaceOptionsByIndex = const {},
    this.cpOptionsByIndex = const {},
    this.cpNameOptionsByIndex = const {},
    this.recordCount = 0
  });

  bool get isValid {
    if (settingProfileName.trim().isEmpty) return false;
    if (chartChangeInterval <= 10) return false;
    if (specifics.isEmpty) return false;
    
    // Check global period settings
    // if (globalPeriodType == null || globalStartDate == null || globalEndDate == null) return false;

    for (final sp in specifics) {
      if (displayType == DisplayType.FURNACE || displayType == DisplayType.FURNACE_CP) {
        if (sp.furnaceNo == null) return false;
      }
      if (displayType == DisplayType.CP || displayType == DisplayType.FURNACE_CP) {
        if ((sp.cpNo ?? '').trim().isEmpty) return false;
      }
    }
    return true;
  }

  SettingFormState copyWith({
    String? profileId,
    String? settingProfileName,
    bool? isUsed,
    DisplayType? displayType,
    int? chartChangeInterval,
    List<RuleSelected>? ruleSelected,
    List<SpecificSettingState>? specifics,
    SubmitStatus? status,
    String? error,
    // Global period fields
    PeriodType? globalPeriodType,
    DateTime? globalStartDate,
    DateTime? globalEndDate,
    // Dropdown fields
    bool? dropdownLoading,
    Map<int, List<String>>? furnaceOptionsByIndex,
    Map<int, List<String>>? cpOptionsByIndex,
    Map<int, List<String>>? cpNameOptionsByIndex,
    int? recordCount
  }) {
    return SettingFormState(
      profileId: profileId ?? this.profileId,
      settingProfileName: settingProfileName ?? this.settingProfileName,
      isUsed: isUsed ?? this.isUsed,
      displayType: displayType ?? this.displayType,
      chartChangeInterval: chartChangeInterval ?? this.chartChangeInterval,
      ruleSelected: ruleSelected ?? this.ruleSelected,
      specifics: specifics ?? this.specifics,
      status: status ?? this.status,
      error: error ?? this.error,
      globalPeriodType: globalPeriodType ?? this.globalPeriodType,
      globalStartDate: globalStartDate ?? this.globalStartDate,
      globalEndDate: globalEndDate ?? this.globalEndDate,
      dropdownLoading: dropdownLoading ?? this.dropdownLoading,
      furnaceOptionsByIndex: furnaceOptionsByIndex ?? this.furnaceOptionsByIndex,
      cpOptionsByIndex: cpOptionsByIndex ?? this.cpOptionsByIndex,
      cpNameOptionsByIndex: cpNameOptionsByIndex ?? this.cpNameOptionsByIndex,
      recordCount: recordCount ?? this.recordCount
    );
  }

  @override
  String toString() => 'SettingFormState('
      'profileId: $profileId, settingProfileName: $settingProfileName, isUsed: $isUsed, displayType: $displayType, '
      'chartChangeInterval: $chartChangeInterval, ruleSelected: $ruleSelected, specifics: $specifics, '
      'globalPeriodType: $globalPeriodType, globalStartDate: $globalStartDate, globalEndDate: $globalEndDate, '
      'status: $status, error: $error, dropdownLoading: $dropdownLoading, '
      'furnaceOptionsByIndex: $furnaceOptionsByIndex, cpOptionsByIndex: $cpOptionsByIndex'
      ')';
}

class SpecificSettingState {
  final String? id;
  final PeriodType? periodType;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? furnaceNo;
  final String? cpNo;

  const SpecificSettingState({
    this.id,
    this.periodType,
    this.startDate,
    this.endDate,
    this.furnaceNo,
    this.cpNo,
  });

factory SpecificSettingState.fromJson(Map<String, dynamic> json) {
  return SpecificSettingState(
    id: json['_id'] as String?,
    periodType: json['period']?['type'] != null
        ? PeriodType.values.firstWhere(
            (e) => e.name.toUpperCase() == json['period']['type'].toString().toUpperCase(),
            orElse: () => PeriodType.ONE_MONTH,
          )
        : null,
    startDate: json['period']?['startDate'] != null
        ? DateTime.parse(json['period']['startDate'])
        : null,
    endDate: json['period']?['endDate'] != null
        ? DateTime.parse(json['period']['endDate'])
        : null,
    furnaceNo: json['furnaceNo'] as int?,
    cpNo: json['cpNo'] as String?,
  );
}

Map<String, dynamic> toJson() {
  final fmt = DateFormat('yyyy-MM-dd');
  return {
    if (id != null) '_id': id,
    'period': {
      if (periodType != null) 'type': periodType!.name.toUpperCase(),
      if (startDate != null) 'startDate': fmt.format(startDate!),
      if (endDate != null) 'endDate': fmt.format(endDate!),
    },
    if (furnaceNo != null) 'furnaceNo': furnaceNo,
    if (cpNo != null) 'cpNo': cpNo,
  };
}


  SpecificSettingState copyWith({
    String? id,
    PeriodType? periodType,
    DateTime? startDate,
    DateTime? endDate,
    int? furnaceNo,
    String? cpNo,
    int? recordCount
  }) {
    return SpecificSettingState(
      id: id ?? this.id,
      periodType: periodType ?? this.periodType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      furnaceNo: furnaceNo ?? this.furnaceNo,
      cpNo: cpNo ?? this.cpNo,
    );
  }

  factory SpecificSettingState.fromModel(SpecificSetting model) {
    return SpecificSettingState(
      periodType: model.period?.type,
      startDate: model.period?.startDate,
      endDate: model.period?.endDate,
      furnaceNo: model.furnaceNo,
      cpNo: model.cpNo,
    );
  }

  SpecificSetting toModel() {
    return SpecificSetting(
      period: Period(
        type: periodType ?? PeriodType.ONE_MONTH,
        startDate: startDate,
        endDate: endDate,
      ),
      furnaceNo: furnaceNo,
      cpNo: cpNo,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SpecificSettingState &&
        other.id == id &&
        other.periodType == periodType &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.furnaceNo == furnaceNo &&
        other.cpNo == cpNo;
  }

  @override
  int get hashCode => Object.hash(id, periodType, startDate, endDate, furnaceNo, cpNo);

  @override
  String toString() {
    return 'SpecificSettingState(id: $id, periodType: $periodType, '
        'startDate: $startDate, endDate: $endDate, '
        'furnaceNo: $furnaceNo, cpNo: $cpNo)';
  }
}

enum SubmitStatus { idle, submitting, success, failure }
// ถ้าไม่ได้ใช้ PeriodTypeReq ในที่อื่น แนะนำลบออกเพื่อลดสับสน
// enum PeriodTypeReq { ONE_MONTH, THREE_MONTHS, SIX_MONTHS, ONE_YEAR, CUSTOM, LIFETIME }

class RuleSelected {
  final int? ruleId;
  final String? ruleName;
  final bool? isUsed;

  const RuleSelected({this.ruleId , this.ruleName, this.isUsed});

  RuleSelected copyWith({int? ruleId, String? ruleName, bool? isUsed}) {
    return RuleSelected(
      ruleId: ruleId ?? this.ruleId,
      ruleName: ruleName ?? this.ruleName,
      isUsed: isUsed ?? this.isUsed,
    );
  }

  factory RuleSelected.fromNelson(NelsonRule n) {
    return RuleSelected(
      ruleId: n.ruleId,
      ruleName: n.ruleName,
      isUsed: n.isUsed,
    );
  }

  @override
  String toString() => 'RuleSelected(ruleId: $ruleId, ruleName: $ruleName, isUsed: $isUsed)';
}

