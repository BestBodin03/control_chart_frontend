// models/customer_product.dart
import 'package:json_annotation/json_annotation.dart';

part 'customer_product.g.dart';

@JsonSerializable()
class CustomerProduct {
  const CustomerProduct({
    required this.cpNo,
    required this.furnaceId,
    required this.specifications,
    required this.isDisplay,
  });

  factory CustomerProduct.fromJson(Map<String, dynamic> json) =>
      _$CustomerProductFromJson(json);

  @JsonKey(name: 'CPNo')
  final String cpNo;

  final List<String> furnaceId;

  final Specifications specifications;

  final bool isDisplay;

  Map<String, dynamic> toJson() => _$CustomerProductToJson(this);

  @override
  String toString() {
    return 'CustomerProduct{cpNo: $cpNo, furnaceId: $furnaceId, specifications: $specifications, isDisplay: $isDisplay}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerProduct &&
          runtimeType == other.runtimeType &&
          cpNo == other.cpNo &&
          _listEquals(furnaceId, other.furnaceId) &&
          specifications == other.specifications &&
          isDisplay == other.isDisplay;

  @override
  int get hashCode =>
      cpNo.hashCode ^
      furnaceId.hashCode ^
      specifications.hashCode ^
      isDisplay.hashCode;

  // Helper method for list comparison
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }

  // Utility method สำหรับ copy with changes
  CustomerProduct copyWith({
    String? cpNo,
    List<String>? furnaceId,
    Specifications? specifications,
    bool? isDisplay,
  }) {
    return CustomerProduct(
      cpNo: cpNo ?? this.cpNo,
      furnaceId: furnaceId ?? this.furnaceId,
      specifications: specifications ?? this.specifications,
      isDisplay: isDisplay ?? this.isDisplay,
    );
  }
}

@JsonSerializable()
class Specifications {
  const Specifications({
    required this.upperSpecLimit,
    required this.lowerSpecLimit,
    required this.target,
  });

  factory Specifications.fromJson(Map<String, dynamic> json) =>
      _$SpecificationsFromJson(json);

  final double upperSpecLimit;
  final double lowerSpecLimit;
  final double target;

  Map<String, dynamic> toJson() => _$SpecificationsToJson(this);

  @override
  String toString() {
    return 'Specifications{upperSpecLimit: $upperSpecLimit, lowerSpecLimit: $lowerSpecLimit, target: $target}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Specifications &&
          runtimeType == other.runtimeType &&
          upperSpecLimit == other.upperSpecLimit &&
          lowerSpecLimit == other.lowerSpecLimit &&
          target == other.target;

  @override
  int get hashCode =>
      upperSpecLimit.hashCode ^
      lowerSpecLimit.hashCode ^
      target.hashCode;

  // Utility method สำหรับ copy with changes
  Specifications copyWith({
    double? upperSpecLimit,
    double? lowerSpecLimit,
    double? target,
  }) {
    return Specifications(
      upperSpecLimit: upperSpecLimit ?? this.upperSpecLimit,
      lowerSpecLimit: lowerSpecLimit ?? this.lowerSpecLimit,
      target: target ?? this.target,
    );
  }
}