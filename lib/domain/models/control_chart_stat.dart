import 'package:json_annotation/json_annotation.dart';

part 'control_chart_stat.g.dart';

@JsonSerializable()
class ControlChartStat {
  final int numberOfSpots;
  final double average;
  @JsonKey(name: 'MRAverage')
  final double mrAverage;
  final ControlLimitIChart controlLimitIChart;
  final SigmaIChart sigmaIChart;
  final ControlLimitMRChart controlLimitMRChart;

  const ControlChartStat({
    required this.numberOfSpots,
    required this.average,
    required this.mrAverage,
    required this.controlLimitIChart,
    required this.sigmaIChart,
    required this.controlLimitMRChart,
  });

  factory ControlChartStat.fromJson(Map<String, dynamic> json) =>
      _$ControlChartStatFromJson(json);

  Map<String, dynamic> toJson() => _$ControlChartStatToJson(this);

  @override
  String toString() {
    return 'ControlChartStat(numberOfSpots: $numberOfSpots, average: $average, mrAverage: $mrAverage, controlLimitIChart: $controlLimitIChart, sigmaIChart: $sigmaIChart, controlLimitMRChart: $controlLimitMRChart)';
  }

  ControlChartStat copyWith({
    int? numberOfSpots,
    double? average,
    double? mrAverage,
    ControlLimitIChart? controlLimitIChart,
    SigmaIChart? sigmaIChart,
    ControlLimitMRChart? controlLimitMRChart,
  }) {
    return ControlChartStat(
      numberOfSpots: numberOfSpots ?? this.numberOfSpots,
      average: average ?? this.average,
      mrAverage: mrAverage ?? this.mrAverage,
      controlLimitIChart: controlLimitIChart ?? this.controlLimitIChart,
      sigmaIChart: sigmaIChart ?? this.sigmaIChart,
      controlLimitMRChart: controlLimitMRChart ?? this.controlLimitMRChart,
    );
  }
}

@JsonSerializable()
class ControlLimitIChart {
  @JsonKey(name: 'CL')
  final double cl;
  @JsonKey(name: 'UCL')
  final double ucl;
  @JsonKey(name: 'LCL')
  final double lcl;
  @JsonKey(name: 'USL')
  final double usl;
  @JsonKey(name: 'LSL')
  final double lsl;

  const ControlLimitIChart({
    required this.cl,
    required this.ucl,
    required this.lcl,
    required this.usl,
    required this.lsl,
  });

  factory ControlLimitIChart.fromJson(Map<String, dynamic> json) =>
      _$ControlLimitIChartFromJson(json);

  Map<String, dynamic> toJson() => _$ControlLimitIChartToJson(this);

  @override
  String toString() {
    return 'ControlLimitIChart(cl: $cl, ucl: $ucl, lcl: $lcl, usl: $usl, lsl: $lsl)';
  }

  ControlLimitIChart copyWith({
    double? cl,
    double? ucl,
    double? lcl,
    double? usl,
    double? lsl,
  }) {
    return ControlLimitIChart(
      cl: cl ?? this.cl,
      ucl: ucl ?? this.ucl,
      lcl: lcl ?? this.lcl,
      usl: ucl ?? this.usl,
      lsl: lcl ?? this.lsl,
    );
  }
}

@JsonSerializable()
class SigmaIChart {
  final double sigmaMinus3;
  final double sigmaMinus2;
  final double sigmaMinus1;
  final double sigmaPlus1;
  final double sigmaPlus2;
  final double sigmaPlus3;

  const SigmaIChart({
    required this.sigmaMinus3,
    required this.sigmaMinus2,
    required this.sigmaMinus1,
    required this.sigmaPlus1,
    required this.sigmaPlus2,
    required this.sigmaPlus3,
  });

  factory SigmaIChart.fromJson(Map<String, dynamic> json) =>
      _$SigmaIChartFromJson(json);

  Map<String, dynamic> toJson() => _$SigmaIChartToJson(this);

  @override
  String toString() {
    return 'SigmaIChart(sigmaMinus3: $sigmaMinus3, sigmaMinus2: $sigmaMinus2, sigmaMinus1: $sigmaMinus1, sigmaPlus1: $sigmaPlus1, sigmaPlus2: $sigmaPlus2, sigmaPlus3: $sigmaPlus3)';
  }

  SigmaIChart copyWith({
    double? sigmaMinus3,
    double? sigmaMinus2,
    double? sigmaMinus1,
    double? sigmaPlus1,
    double? sigmaPlus2,
    double? sigmaPlus3,
  }) {
    return SigmaIChart(
      sigmaMinus3: sigmaMinus3 ?? this.sigmaMinus3,
      sigmaMinus2: sigmaMinus2 ?? this.sigmaMinus2,
      sigmaMinus1: sigmaMinus1 ?? this.sigmaMinus1,
      sigmaPlus1: sigmaPlus1 ?? this.sigmaPlus1,
      sigmaPlus2: sigmaPlus2 ?? this.sigmaPlus2,
      sigmaPlus3: sigmaPlus3 ?? this.sigmaPlus3,
    );
  }
}

@JsonSerializable()
class ControlLimitMRChart {
  @JsonKey(name: 'CL')
  final double cl;
  @JsonKey(name: 'UCL')
  final double ucl;
  @JsonKey(name: 'LCL')
  final double lcl;

  const ControlLimitMRChart({
    required this.cl,
    required this.ucl,
    required this.lcl,
  });

  factory ControlLimitMRChart.fromJson(Map<String, dynamic> json) =>
      _$ControlLimitMRChartFromJson(json);

  Map<String, dynamic> toJson() => _$ControlLimitMRChartToJson(this);

  @override
  String toString() {
    return 'ControlLimitMRChart(cl: $cl, ucl: $ucl, lcl: $lcl)';
  }

  ControlLimitMRChart copyWith({
    double? cl,
    double? ucl,
    double? lcl,
  }) {
    return ControlLimitMRChart(
      cl: cl ?? this.cl,
      ucl: ucl ?? this.ucl,
      lcl: lcl ?? this.lcl,
    );
  }
}