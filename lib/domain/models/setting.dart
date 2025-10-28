import 'package:json_annotation/json_annotation.dart';

part 'setting.g.dart';

@JsonSerializable(explicitToJson: true)
class Setting {
  const Setting({
    required this.id,
    required this.settingProfileName,
    required this.isUsed,
    required this.displayType,
    required this.generalSetting,
    required this.specificSetting,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Setting.fromJson(Map<String, dynamic> json) =>
      _$SettingFromJson(json);

  final String id;
  final String settingProfileName;
  final bool isUsed;

  final DisplayType displayType;

  final GeneralSetting generalSetting;

  final List<SpecificSetting> specificSetting;

  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => _$SettingToJson(this);
}

@JsonSerializable()
class GeneralSetting {
  const GeneralSetting({
    required this.chartChangeInterval,
    required this.nelsonRule,
  });

  factory GeneralSetting.fromJson(Map<String, dynamic> json) =>
      _$GeneralSettingFromJson(json);

  final int chartChangeInterval;
  final List<NelsonRule> nelsonRule;

  Map<String, dynamic> toJson() => _$GeneralSettingToJson(this);
}

@JsonSerializable()
class NelsonRule {
  const NelsonRule({
    required this.ruleId,
    required this.ruleName,
    required this.isUsed,
  });

  factory NelsonRule.fromJson(Map<String, dynamic> json) =>
      _$NelsonRuleFromJson(json);

  final int ruleId;
  final String ruleName;
  final bool isUsed;

  Map<String, dynamic> toJson() => _$NelsonRuleToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SpecificSetting {
  const SpecificSetting({
    this.period,
    this.furnaceNo,
    this.cpNo,
  });

  factory SpecificSetting.fromJson(Map<String, dynamic> json) =>
      _$SpecificSettingFromJson(json);

  final Period? period;
  final int? furnaceNo;
  final String? cpNo;

  Map<String, dynamic> toJson() => _$SpecificSettingToJson(this);
}

@JsonSerializable()
class Period {
  const Period({
    required this.type,
    this.startDate,
    this.endDate,
  });

  factory Period.fromJson(Map<String, dynamic> json) =>
      _$PeriodFromJson(json);

  final PeriodType type;
  final DateTime? startDate;
  final DateTime? endDate;

  Map<String, dynamic> toJson() => _$PeriodToJson(this);
}

/// --- Enums ---

@JsonEnum(alwaysCreate: true)
enum DisplayType {
  @JsonValue('FURNACE') FURNACE,
  @JsonValue('FURNACE_CP') FURNACE_CP,
  @JsonValue('CP') CP,
}

@JsonEnum(alwaysCreate: true)
enum PeriodType {
  @JsonValue('ONE_MONTH') ONE_MONTH,
  @JsonValue('THREE_MONTHS') THREE_MONTHS,
  @JsonValue('SIX_MONTHS') SIX_MONTHS,
  @JsonValue('ONE_YEAR') ONE_YEAR,
  @JsonValue('CUSTOM') CUSTOM,
  @JsonValue('LIFETIME') LIFETIME,
}
