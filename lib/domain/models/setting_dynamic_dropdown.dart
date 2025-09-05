// models/setting_dynamic_dropdown.dart
import 'package:json_annotation/json_annotation.dart';

part 'setting_dynamic_dropdown.g.dart';

@JsonSerializable(explicitToJson: true)
class SettingDynamicDropdownResponse {
  const SettingDynamicDropdownResponse({
    required this.status,
    required this.statusCode,
    required this.data,
  });

  factory SettingDynamicDropdownResponse.fromJson(Map<String, dynamic> json) =>
      _$SettingDynamicDropdownResponseFromJson(json);

  final String status;
  final int statusCode;
  final SettingDynamicDropdownData data;

  Map<String, dynamic> toJson() =>
      _$SettingDynamicDropdownResponseToJson(this);

  SettingDynamicDropdownResponse copyWith({
    String? status,
    int? statusCode,
    SettingDynamicDropdownData? data,
  }) {
    return SettingDynamicDropdownResponse(
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      data: data ?? this.data,
    );
  }

  @override
  String toString() =>
      'SettingDynamicDropdownResponse(status: $status, statusCode: $statusCode, data: $data)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingDynamicDropdownResponse &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          statusCode == other.statusCode &&
          data == other.data;

  @override
  int get hashCode => status.hashCode ^ statusCode.hashCode ^ data.hashCode;
}

/// Payload data only
@JsonSerializable()
class SettingDynamicDropdownData {
  const SettingDynamicDropdownData({
    required this.furnaceNo,
    required this.cpNo,
  });

  factory SettingDynamicDropdownData.fromJson(Map<String, dynamic> json) =>
      _$SettingDynamicDropdownDataFromJson(json);

  /// e.g. [1, 3]
  final List<String> furnaceNo;

  /// e.g. ["24009","2400","24006"]
  final List<String> cpNo;

  Map<String, dynamic> toJson() =>
      _$SettingDynamicDropdownDataToJson(this);

  SettingDynamicDropdownData copyWith({
    List<String>? furnaceNo,
    List<String>? cpNo,
  }) {
    return SettingDynamicDropdownData(
      furnaceNo: furnaceNo ?? this.furnaceNo,
      cpNo: cpNo ?? this.cpNo,
    );
  }

  @override
  String toString() =>
      'SettingDynamicDropdownData(furnaceNo: $furnaceNo, cpNo: $cpNo)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingDynamicDropdownData &&
          runtimeType == other.runtimeType &&
          _listEqualsInt(furnaceNo, other.furnaceNo) &&
          _listEqualsString(cpNo, other.cpNo);

  @override
  int get hashCode => Object.hashAll([...furnaceNo, ...cpNo]);
}

// ---- simple list equals helpers (kept inline to stay one-file) ----
bool _listEqualsInt(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

bool _listEqualsString(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
