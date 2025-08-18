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
    required this.cde,
  });

  factory MachanicDetail.fromJson(Map<String, dynamic> json) =>
      _$MachanicDetailFromJson(json);

  final double surfaceHardnessMean;

  @JsonKey(name: 'CDE')
  final CDE cde;

  Map<String, dynamic> toJson() => _$MachanicDetailToJson(this);
}

@JsonSerializable()
class CDE {
  const CDE({
    required this.cdex,
    required this.cdtx,
  });

  factory CDE.fromJson(Map<String, dynamic> json) => _$CDEFromJson(json);

  @JsonKey(name: 'CDEX')
  final double cdex;

  @JsonKey(name: 'CDTX')
  final double cdtx;

  Map<String, dynamic> toJson() => _$CDEToJson(this);
}

@JsonSerializable()
class Filters {
  final Period period;
  final int? furnaceNo;
  final String matNo;

  const Filters({
    required this.period,
    this.furnaceNo,
    required this.matNo,
  });

  factory Filters.fromJson(Map<String, dynamic> json) =>
      _$FiltersFromJson(json);

  Map<String, dynamic> toJson() => _$FiltersToJson(this);

  @override
  String toString() {
    return 'Filters(period: $period, furnaceNo: $furnaceNo, matNo: $matNo)';
  }

  Filters copyWith({
    Period? period,
    int? furnaceNo,
    String? matNo,
  }) {
    return Filters(
      period: period ?? this.period,
      furnaceNo: furnaceNo ?? this.furnaceNo,
      matNo: matNo ?? this.matNo,
    );
  }
}

@JsonSerializable()
class Period {
  final String startDate;
  final String endDate;

  const Period({
    required this.startDate,
    required this.endDate,
  });

  factory Period.fromJson(Map<String, dynamic> json) =>
      _$PeriodFromJson(json);

  Map<String, dynamic> toJson() => _$PeriodToJson(this);

  @override
  String toString() {
    return 'Period(startDate: $startDate, endDate: $endDate)';
  }

  Period copyWith({
    String? startDate,
    String? endDate,
  }) {
    return Period(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}