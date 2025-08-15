import 'package:json_annotation/json_annotation.dart';

part 'control_chart_stats.g.dart';

@JsonSerializable()
class ControlChartStats {
  final int? numberOfSpots;
  final double? average;
  final double? cdeAverage;
  final double? cdtAverage;
  @JsonKey(name: 'MRAverage')
  final double? mrAverage;
  final double? cdeMrAverage;
  final double? cdtMrAverage;
  final ControlLimitIChart? controlLimitIChart;
  final ControlLimitIChart? cdeControlLimitIChart;
  final ControlLimitIChart? cdtControlLimitIChart;
  final SigmaIChart? sigmaIChart;
  final SigmaIChart? cdeSigmaIChart;
  final SigmaIChart? cdtSigmaIChart;
  final ControlLimitMRChart? controlLimitMRChart;
  final ControlLimitMRChart? cdeControlLimitMRChart;
  final ControlLimitMRChart? cdtControlLimitMRChart;
  final List<double>? mrChartSpots;
  final List<double>? cdeMrChartSpots;
  final List<double>? cdtMrChartSpots;
  final SpecAttribute? specAttribute;  // Added this field

  const ControlChartStats({
    this.numberOfSpots,
    this.average,
    this.cdeAverage,
    this.cdtAverage,
    this.mrAverage,
    this.cdeMrAverage,
    this.cdtMrAverage,
    this.controlLimitIChart,
    this.cdeControlLimitIChart,
    this.cdtControlLimitIChart,
    this.sigmaIChart,
    this.cdeSigmaIChart,
    this.cdtSigmaIChart,
    this.controlLimitMRChart,
    this.cdeControlLimitMRChart,
    this.cdtControlLimitMRChart,
    this.mrChartSpots,      
    this.cdeMrChartSpots,
    this.cdtMrChartSpots,
    this.specAttribute,     
  });

  // Add empty constructor for error handling
  const ControlChartStats.empty()
      : numberOfSpots = 0,
        average = 0.0,
        cdeAverage = 0.0,
        cdtAverage = 0.0,
        mrAverage = 0.0,
        cdeMrAverage = 0.0,
        cdtMrAverage = 0.0,
        controlLimitIChart = null,
        cdeControlLimitIChart = null,
        cdtControlLimitIChart = null,
        sigmaIChart = null,
        cdeSigmaIChart = null,
        cdtSigmaIChart = null,
        controlLimitMRChart = null,
        cdeControlLimitMRChart = null,
        cdtControlLimitMRChart = null,
        mrChartSpots = const [],
        cdeMrChartSpots = const [],
        cdtMrChartSpots = const [],
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