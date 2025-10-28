// models/furnace_data.dart
import 'package:json_annotation/json_annotation.dart';

part 'furnace.g.dart';

@JsonSerializable()
class Furnace {
  const Furnace({
    required this.furnaceNo,
    required this.furnaceDescription,
    required this.isDisplay,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Furnace.fromJson(Map<String, dynamic> json) =>
      _$FurnaceFromJson(json);

  final int furnaceNo;
  final String furnaceDescription;
  final bool isDisplay;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => _$FurnaceToJson(this);

  @override
  String toString() {
    print('FurnaceNo. list is $furnaceNo');
    return 'Furnace{furnaceNo: $furnaceNo, furnaceDescription: $furnaceDescription, isDisplay: $isDisplay, createdAt: $createdAt, updatedAt: $updatedAt}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Furnace &&
          runtimeType == other.runtimeType &&
          furnaceNo == other.furnaceNo &&
          furnaceDescription == other.furnaceDescription &&
          isDisplay == other.isDisplay &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      furnaceNo.hashCode ^
      furnaceDescription.hashCode ^
      isDisplay.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;

  // Utility method สำหรับ copy with changes
  Furnace copyWith({
    int? furnaceNo,
    String? furnaceDescription,
    bool? isDisplay,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Furnace(
      furnaceNo: furnaceNo ?? this.furnaceNo,
      furnaceDescription: furnaceDescription ?? this.furnaceDescription,
      isDisplay: isDisplay ?? this.isDisplay,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}