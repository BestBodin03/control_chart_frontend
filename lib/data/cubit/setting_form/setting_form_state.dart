import 'package:control_chart/domain/models/setting.dart';

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
  });

  bool get isValid {
    if (settingProfileName.trim().isEmpty) return false;
    if (chartChangeInterval <= 10) return false;
    if (specifics.isEmpty) return false;
    
    // Check global period settings
    if (globalPeriodType == null || globalStartDate == null || globalEndDate == null) return false;

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
  String toString() {
    return 'SpecificSettingState(periodType: $periodType, startDate: $startDate, '
        'endDate: $endDate, furnaceNo: $furnaceNo, cpNo: $cpNo)';
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