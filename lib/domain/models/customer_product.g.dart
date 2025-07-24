// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerProduct _$CustomerProductFromJson(Map<String, dynamic> json) =>
    CustomerProduct(
      cpNo: json['CPNo'] as String,
      furnaceId:
          (json['furnaceId'] as List<dynamic>).map((e) => e as String).toList(),
      specifications: Specifications.fromJson(
        json['specifications'] as Map<String, dynamic>,
      ),
      isDisplay: json['isDisplay'] as bool,
    );

Map<String, dynamic> _$CustomerProductToJson(CustomerProduct instance) =>
    <String, dynamic>{
      'CPNo': instance.cpNo,
      'furnaceId': instance.furnaceId,
      'specifications': instance.specifications,
      'isDisplay': instance.isDisplay,
    };

Specifications _$SpecificationsFromJson(Map<String, dynamic> json) =>
    Specifications(
      upperSpecLimit: (json['upperSpecLimit'] as num).toDouble(),
      lowerSpecLimit: (json['lowerSpecLimit'] as num).toDouble(),
      target: (json['target'] as num).toDouble(),
    );

Map<String, dynamic> _$SpecificationsToJson(Specifications instance) =>
    <String, dynamic>{
      'upperSpecLimit': instance.upperSpecLimit,
      'lowerSpecLimit': instance.lowerSpecLimit,
      'target': instance.target,
    };
