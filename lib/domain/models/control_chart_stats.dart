import 'package:json_annotation/json_annotation.dart';

part 'control_chart_stats.g.dart';

@JsonSerializable()
class ControlChartStats {
  final int? numberOfSpots;
  final double? average;
  @JsonKey(name: 'MRAverage')
  final double? mrAverage;
  final ControlLimitIChart? controlLimitIChart;
  final SigmaIChart? sigmaIChart;
  final ControlLimitMRChart? controlLimitMRChart;
  final List<double>? mrChartSpots;  // Added this field
  final SpecAttribute? specAttribute;  // Added this field

  const ControlChartStats({
    this.numberOfSpots,
    this.average,
    this.mrAverage,
    this.controlLimitIChart,
    this.sigmaIChart,
    this.controlLimitMRChart,
    this.mrChartSpots,      // Added
    this.specAttribute,     // Added
  });

  // Add empty constructor for error handling
  const ControlChartStats.empty()
      : numberOfSpots = 0,
        average = 0.0,
        mrAverage = 0.0,
        controlLimitIChart = null,
        sigmaIChart = null,
        controlLimitMRChart = null,
        mrChartSpots = const [],
        specAttribute = null;

  factory ControlChartStats.fromJson(Map<String, dynamic> json) =>
      _$ControlChartStatsFromJson(json);

  Map<String, dynamic> toJson() => _$ControlChartStatsToJson(this);
}

@JsonSerializable()
class ControlLimitIChart {
  @JsonKey(name: 'CL')
  final double? cl;
  @JsonKey(name: 'UCL')
  final double? ucl;
  @JsonKey(name: 'LCL')
  final double? lcl;

  const ControlLimitIChart({
    this.cl,
    this.ucl,
    this.lcl,
  });

  factory ControlLimitIChart.fromJson(Map<String, dynamic> json) =>
      _$ControlLimitIChartFromJson(json);

  Map<String, dynamic> toJson() => _$ControlLimitIChartToJson(this);
}

@JsonSerializable()
class SigmaIChart {
  final double? sigmaMinus3;
  final double? sigmaMinus2;
  final double? sigmaMinus1;
  final double? sigmaPlus1;
  final double? sigmaPlus2;
  final double? sigmaPlus3;

  const SigmaIChart({
    this.sigmaMinus3,
    this.sigmaMinus2,
    this.sigmaMinus1,
    this.sigmaPlus1,
    this.sigmaPlus2,
    this.sigmaPlus3,
  });

  factory SigmaIChart.fromJson(Map<String, dynamic> json) =>
      _$SigmaIChartFromJson(json);

  Map<String, dynamic> toJson() => _$SigmaIChartToJson(this);
}

@JsonSerializable()
class ControlLimitMRChart {
  @JsonKey(name: 'CL')
  final double? cl;
  @JsonKey(name: 'UCL')
  final double? ucl;
  @JsonKey(name: 'LCL')
  final double? lcl;

  const ControlLimitMRChart({
    this.cl,
    this.ucl,
    this.lcl,
  });

  factory ControlLimitMRChart.fromJson(Map<String, dynamic> json) =>
      _$ControlLimitMRChartFromJson(json);

  Map<String, dynamic> toJson() => _$ControlLimitMRChartToJson(this);
}

@JsonSerializable()
class SpecAttribute {
  final String? materialNo;
  final double? surfaceHardnessUpperSpec;
  final double? surfaceHardnessLowerSpec;
  final double? surfaceHardnessTarget;
  final double? cdeUpperSpec;
  final double? cdeLowerSpec;
  final double? cdeTarget;
  final double? cdtUpperSpec;
  final double? cdtLowerSpec;
  final double? cdtTarget;

  const SpecAttribute({
    this.materialNo,
    this.surfaceHardnessUpperSpec,
    this.surfaceHardnessLowerSpec,
    this.surfaceHardnessTarget,
    this.cdeUpperSpec,
    this.cdeLowerSpec,
    this.cdeTarget,
    this.cdtUpperSpec,
    this.cdtLowerSpec,
    this.cdtTarget,
  });

  factory SpecAttribute.fromJson(Map<String, dynamic> json) =>
      _$SpecAttributeFromJson(json);

  Map<String, dynamic> toJson() => _$SpecAttributeToJson(this);
}