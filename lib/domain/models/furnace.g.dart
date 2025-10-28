// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'furnace.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Furnace _$FurnaceFromJson(Map<String, dynamic> json) => Furnace(
  furnaceNo: (json['furnaceNo'] as num).toInt(),
  furnaceDescription: json['furnaceDescription'] as String,
  isDisplay: json['isDisplay'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$FurnaceToJson(Furnace instance) => <String, dynamic>{
  'furnaceNo': instance.furnaceNo,
  'furnaceDescription': instance.furnaceDescription,
  'isDisplay': instance.isDisplay,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
