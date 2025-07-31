import 'package:json_annotation/json_annotation.dart';

part 'control_chart_stats.g.dart';

@JsonSerializable()
class ControlChartStats {
  final int? numberOfSpots;  // Make nullable
  final double? average;     // Make nullable
  @JsonKey(name: 'MRAverage')
  final double? mrAverage;   // Make nullable
  final ControlLimitIChart? controlLimitIChart;  // Make nullable
  final SigmaIChart? sigmaIChart;               // Make nullable
  final ControlLimitMRChart? controlLimitMRChart; // Make nullable

  const ControlChartStats({
    this.numberOfSpots,      // Remove required
    this.average,           // Remove required
    this.mrAverage,         // Remove required
    this.controlLimitIChart, // Remove required
    this.sigmaIChart,       // Remove required
    this.controlLimitMRChart, // Remove required
  });

  factory ControlChartStats.fromJson(Map<String, dynamic> json) =>
      _$ControlChartStatsFromJson(json);

  Map<String, dynamic> toJson() => _$ControlChartStatsToJson(this);
}

@JsonSerializable()
class ControlLimitIChart {
  @JsonKey(name: 'CL')
  final double? cl;    // Make nullable
  @JsonKey(name: 'UCL')
  final double? ucl;   // Make nullable
  @JsonKey(name: 'LCL')
  final double? lcl;   // Make nullable
  @JsonKey(name: 'USL')
  final double? usl;   // Make nullable
  @JsonKey(name: 'LSL')
  final double? lsl;   // Make nullable

  const ControlLimitIChart({
    this.cl,    // Remove required
    this.ucl,   // Remove required
    this.lcl,   // Remove required
    this.usl,   // Remove required
    this.lsl,   // Remove required
  });

  factory ControlLimitIChart.fromJson(Map<String, dynamic> json) =>
      _$ControlLimitIChartFromJson(json);

  Map<String, dynamic> toJson() => _$ControlLimitIChartToJson(this);
}

@JsonSerializable()
class SigmaIChart {
  final double? sigmaMinus3;  // Make all nullable
  final double? sigmaMinus2;
  final double? sigmaMinus1;
  final double? sigmaPlus1;
  final double? sigmaPlus2;
  final double? sigmaPlus3;

  const SigmaIChart({
    this.sigmaMinus3,  // Remove required
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
  final double? cl;   // Make nullable
  @JsonKey(name: 'UCL')
  final double? ucl;  // Make nullable
  @JsonKey(name: 'LCL')
  final double? lcl;  // Make nullable

  const ControlLimitMRChart({
    this.cl,   // Remove required
    this.ucl,  // Remove required
    this.lcl,  // Remove required
  });

  factory ControlLimitMRChart.fromJson(Map<String, dynamic> json) =>
      _$ControlLimitMRChartFromJson(json);

  Map<String, dynamic> toJson() => _$ControlLimitMRChartToJson(this);
}