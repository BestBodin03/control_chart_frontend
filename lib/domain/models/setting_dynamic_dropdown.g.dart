// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setting_dynamic_dropdown.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SettingDynamicDropdownResponse _$SettingDynamicDropdownResponseFromJson(
  Map<String, dynamic> json,
) => SettingDynamicDropdownResponse(
  status: json['status'] as String,
  statusCode: (json['statusCode'] as num).toInt(),
  data: SettingDynamicDropdownData.fromJson(
    json['data'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$SettingDynamicDropdownResponseToJson(
  SettingDynamicDropdownResponse instance,
) => <String, dynamic>{
  'status': instance.status,
  'statusCode': instance.statusCode,
  'data': instance.data.toJson(),
};

SettingDynamicDropdownData _$SettingDynamicDropdownDataFromJson(
  Map<String, dynamic> json,
) => SettingDynamicDropdownData(
  furnaceNo:
      (json['furnaceNo'] as List<dynamic>).map((e) => e as String).toList(),
  cpNo: (json['cpNo'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$SettingDynamicDropdownDataToJson(
  SettingDynamicDropdownData instance,
) => <String, dynamic>{'furnaceNo': instance.furnaceNo, 'cpNo': instance.cpNo};
