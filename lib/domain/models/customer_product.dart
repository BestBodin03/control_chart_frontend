// models/customer_product.dart
import 'package:json_annotation/json_annotation.dart';

part 'customer_product.g.dart';

@JsonSerializable()
class CustomerProduct {
  const CustomerProduct({
    required this.cpNo,
    required this.furnaceId,
    required this.isDisplay,
  });

  factory CustomerProduct.fromJson(Map<String, dynamic> json) =>
      _$CustomerProductFromJson(json);

  @JsonKey(name: 'CPNo')
  final String cpNo;

  final List<String> furnaceId;

  final bool isDisplay;

  Map<String, dynamic> toJson() => _$CustomerProductToJson(this);

  @override
  String toString() {
    return 'CustomerProduct{cpNo: $cpNo, furnaceId: $furnaceId, isDisplay: $isDisplay}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerProduct &&
          runtimeType == other.runtimeType &&
          cpNo == other.cpNo &&
          _listEquals(furnaceId, other.furnaceId) &&
          isDisplay == other.isDisplay;

  @override
  int get hashCode =>
      cpNo.hashCode ^
      furnaceId.hashCode ^
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
    bool? isDisplay,
  }) {
    return CustomerProduct(
      cpNo: cpNo ?? this.cpNo,
      furnaceId: furnaceId ?? this.furnaceId,
      isDisplay: isDisplay ?? this.isDisplay,
    );
  }
}