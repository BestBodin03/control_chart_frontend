// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setting.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Setting _$SettingFromJson(Map<String, dynamic> json) => Setting(
  id: json['id'] as String,
  settingProfileName: json['settingProfileName'] as String,
  isUsed: json['isUsed'] as bool,
  displayType: $enumDecode(_$DisplayTypeEnumMap, json['displayType']),
  generalSetting: GeneralSetting.fromJson(
    json['generalSetting'] as Map<String, dynamic>,
  ),
  specificSetting:
      (json['specificSetting'] as List<dynamic>)
          .map((e) => SpecificSetting.fromJson(e as Map<String, dynamic>))
          .toList(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$SettingToJson(Setting instance) => <String, dynamic>{
  'id': instance.id,
  'settingProfileName': instance.settingProfileName,
  'isUsed': instance.isUsed,
  'displayType': _$DisplayTypeEnumMap[instance.displayType]!,
  'generalSetting': instance.generalSetting.toJson(),
  'specificSetting': instance.specificSetting.map((e) => e.toJson()).toList(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$DisplayTypeEnumMap = {
  DisplayType.furnace: 'FURNACE',
  DisplayType.furnaceCp: 'FURNACE_CP',
  DisplayType.cp: 'CP',
};

GeneralSetting _$GeneralSettingFromJson(Map<String, dynamic> json) =>
    GeneralSetting(
      chartChangeInterval: (json['chartChangeInterval'] as num).toInt(),
      nelsonRule:
          (json['nelsonRule'] as List<dynamic>)
              .map((e) => NelsonRule.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$GeneralSettingToJson(GeneralSetting instance) =>
    <String, dynamic>{
      'chartChangeInterval': instance.chartChangeInterval,
      'nelsonRule': instance.nelsonRule,
    };

NelsonRule _$NelsonRuleFromJson(Map<String, dynamic> json) => NelsonRule(
  ruleId: (json['ruleId'] as num).toInt(),
  ruleName: json['ruleName'] as String,
  ruleDescription: json['ruleDescription'] as String?,
  ruleIndicated: json['ruleIndicated'] as String?,
  isUsed: json['isUsed'] as bool,
);

Map<String, dynamic> _$NelsonRuleToJson(NelsonRule instance) =>
    <String, dynamic>{
      'ruleId': instance.ruleId,
      'ruleName': instance.ruleName,
      'ruleDescription': instance.ruleDescription,
      'ruleIndicated': instance.ruleIndicated,
      'isUsed': instance.isUsed,
    };

SpecificSetting _$SpecificSettingFromJson(Map<String, dynamic> json) =>
    SpecificSetting(
      period: Period.fromJson(json['period'] as Map<String, dynamic>),
      furnaceNo: (json['furnaceNo'] as num?)?.toInt(),
      cpNo: json['cpNo'] as String?,
    );

Map<String, dynamic> _$SpecificSettingToJson(SpecificSetting instance) =>
    <String, dynamic>{
      'period': instance.period.toJson(),
      'furnaceNo': instance.furnaceNo,
      'cpNo': instance.cpNo,
    };

Period _$PeriodFromJson(Map<String, dynamic> json) => Period(
  type: $enumDecode(_$PeriodTypeEnumMap, json['type']),
  startDate:
      json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
  endDate:
      json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
);

Map<String, dynamic> _$PeriodToJson(Period instance) => <String, dynamic>{
  'type': _$PeriodTypeEnumMap[instance.type]!,
  'startDate': instance.startDate?.toIso8601String(),
  'endDate': instance.endDate?.toIso8601String(),
};

const _$PeriodTypeEnumMap = {
  PeriodType.oneMonth: 'ONE_MONTH',
  PeriodType.threeMonths: 'THREE_MONTHS',
  PeriodType.sixMonths: 'SIX_MONTHS',
  PeriodType.oneYear: 'ONE_YEAR',
  PeriodType.custom: 'CUSTOM',
  PeriodType.lifetime: 'LIFETIME',
};
