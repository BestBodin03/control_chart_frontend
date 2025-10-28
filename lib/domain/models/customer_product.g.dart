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
      isDisplay: json['isDisplay'] as bool,
    );

Map<String, dynamic> _$CustomerProductToJson(CustomerProduct instance) =>
    <String, dynamic>{
      'CPNo': instance.cpNo,
      'furnaceId': instance.furnaceId,
      'isDisplay': instance.isDisplay,
    };
