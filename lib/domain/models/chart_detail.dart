// models/chart_detail_data.dart
import 'package:json_annotation/json_annotation.dart';

part 'chart_detail.g.dart';

@JsonSerializable()
class ChartDetail {
  const ChartDetail({
    required this.cpNo,
    required this.fgNo,
    required this.chartGeneralDetail,
    required this.machanicDetail,
  });

  factory ChartDetail.fromJson(Map<String, dynamic> json) =>
      _$ChartDetailFromJson(json);

  @JsonKey(name: 'CPNo')
  final String cpNo;

  @JsonKey(name: 'FGNo')
  final String fgNo;

  final ChartGeneralDetail chartGeneralDetail;
  final MachanicDetail machanicDetail;

  Map<String, dynamic> toJson() => _$ChartDetailToJson(this);
}

@JsonSerializable()
class ChartGeneralDetail {
  const ChartGeneralDetail({
    required this.furnaceNo,
    required this.part,
    required this.partName,
    required this.collectedDate,
  });

  factory ChartGeneralDetail.fromJson(Map<String, dynamic> json) =>
      _$ChartGeneralDetailFromJson(json);

  final int furnaceNo;
  final String part;
  final String partName;
  final DateTime collectedDate;

  Map<String, dynamic> toJson() => _$ChartGeneralDetailToJson(this);
}

@JsonSerializable()
class MachanicDetail {
  const MachanicDetail({
    required this.surfaceHardnessMean,
    required this.hardnessAt01mmMean,
    required this.cde,
    required this.coreHardnessMean,
    required this.compoundLayer,
  });

  factory MachanicDetail.fromJson(Map<String, dynamic> json) =>
      _$MachanicDetailFromJson(json);

  final double surfaceHardnessMean;
  final double hardnessAt01mmMean;

  @JsonKey(name: 'CDE')
  final CDE cde;

  final double coreHardnessMean;
  final double compoundLayer;

  Map<String, dynamic> toJson() => _$MachanicDetailToJson(this);
}

@JsonSerializable()
class CDE {
  const CDE({
    required this.cdex,
    required this.cdey,
  });

  factory CDE.fromJson(Map<String, dynamic> json) => _$CDEFromJson(json);

  @JsonKey(name: 'CDEX')
  final double cdex;

  @JsonKey(name: 'CDEY')
  final double cdey;

  Map<String, dynamic> toJson() => _$CDEToJson(this);
}