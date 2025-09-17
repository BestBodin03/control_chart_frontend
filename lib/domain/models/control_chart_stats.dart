import 'package:control_chart/domain/models/setting.dart';
import 'package:control_chart/domain/models/y_axis_range.dart';
import 'package:json_annotation/json_annotation.dart';

part 'control_chart_stats.g.dart';

/// ==================== Root Model ====================
@JsonSerializable(explicitToJson: true)
class ControlChartStats {
  final int? numberOfSpots;

  final Violations? surfaceHardnessViolations;
  final Violations? compoundLayerViolations;
  final Violations? cdeViolations;
  final Violations? cdtViolations;

  final double? average;
  final PeriodType? periodType;
  final double? compoundLayerAverage;
  final double? cdeAverage;
  final double? cdtAverage;

  @JsonKey(name: 'MRAverage')
  final double? mrAverage;
  @JsonKey(name: 'compoundLayerMRAverage')
  final double? compoundLayerMrAverage;
  @JsonKey(name: 'cdeMRAverage')
  final double? cdeMrAverage;
  @JsonKey(name: 'cdtMRAverage')
  final double? cdtMrAverage;

  final ControlLimitIChart? controlLimitIChart;
  final ControlLimitIChart? compoundLayerControlLimitIChart;
  final ControlLimitIChart? cdeControlLimitIChart;
  final ControlLimitIChart? cdtControlLimitIChart;

  final SigmaIChart? sigmaIChart;
  final SigmaIChart? compoundLayerSigmaIChart;
  final SigmaIChart? cdeSigmaIChart;
  final SigmaIChart? cdtSigmaIChart;

  final ControlLimitMRChart? controlLimitMRChart;
  final ControlLimitMRChart? compoundLayerControlLimitMRChart;
  final ControlLimitMRChart? cdeControlLimitMRChart;
  final ControlLimitMRChart? cdtControlLimitMRChart;

  /// Spots (raw) for I/MR (ยังคงรับเป็นตัวเลข list)
  final List<double>? surfaceHardnessChartSpots;
  final List<double>? compoundLayerChartSpots;
  final List<double>? cdeChartSpots;
  final List<double>? cdtChartSpots;

  final List<double>? mrChartSpots;
  final List<double>? compoundLayerMrChartSpots;
  final List<double>? cdeMrChartSpots;
  final List<double>? cdtMrChartSpots;

  final SpecAttribute? specAttribute;
  final YAxisRange? yAxisRange;

  /// NEW: จุดของ Control Chart ที่ผ่านการตรวจ Nelson Rule (R1, R3)
  final ChartPoints? controlChartSpots;

  /// NEW: ตัวเลือกกราฟที่สองจาก backend ("CDE","CDT","COMPOUND LAYER","NA")
  final SecondChartSelected? secondChartSelected;
  final List<DateTime> xAxisMediumLabel;
  final List<DateTime> xAxisLargeLabel;
  final int xTick;

  const ControlChartStats({
    this.numberOfSpots,
    this.surfaceHardnessViolations,
    this.compoundLayerViolations,
    this.cdeViolations,
    this.cdtViolations,
    this.average,
    this.periodType,
    this.compoundLayerAverage,
    this.cdeAverage,
    this.cdtAverage,
    this.mrAverage,
    this.compoundLayerMrAverage,
    this.cdeMrAverage,
    this.cdtMrAverage,
    this.controlLimitIChart,
    this.compoundLayerControlLimitIChart,
    this.cdeControlLimitIChart,
    this.cdtControlLimitIChart,
    this.sigmaIChart,
    this.compoundLayerSigmaIChart,
    this.cdeSigmaIChart,
    this.cdtSigmaIChart,
    this.controlLimitMRChart,
    this.compoundLayerControlLimitMRChart,
    this.cdeControlLimitMRChart,
    this.cdtControlLimitMRChart,
    this.surfaceHardnessChartSpots,
    this.compoundLayerChartSpots,
    this.cdeChartSpots,
    this.cdtChartSpots,
    this.mrChartSpots,
    this.compoundLayerMrChartSpots,
    this.cdeMrChartSpots,
    this.cdtMrChartSpots,
    this.specAttribute,
    this.yAxisRange,
    this.controlChartSpots,
    this.secondChartSelected,
    required this.xAxisMediumLabel,
    required this.xAxisLargeLabel,
    required this.xTick

  });

  /// Empty-safe
  const ControlChartStats.empty(this.yAxisRange)
      : numberOfSpots = 0,
        average = 0.0,
        surfaceHardnessViolations = const Violations(),
        compoundLayerViolations = const Violations(),
        cdeViolations = const Violations(),
        cdtViolations = const Violations(),
        periodType = PeriodType.ONE_MONTH,
        compoundLayerAverage = 0.0,
        cdeAverage = 0.0,
        cdtAverage = 0.0,
        mrAverage = 0.0,
        compoundLayerMrAverage = 0.0,
        cdeMrAverage = 0.0,
        cdtMrAverage = 0.0,
        controlLimitIChart = null,
        compoundLayerControlLimitIChart = null,
        cdeControlLimitIChart = null,
        cdtControlLimitIChart = null,
        sigmaIChart = null,
        compoundLayerSigmaIChart = null,
        cdeSigmaIChart = null,
        cdtSigmaIChart = null,
        controlLimitMRChart = null,
        compoundLayerControlLimitMRChart = null,
        cdeControlLimitMRChart = null,
        cdtControlLimitMRChart = null,
        surfaceHardnessChartSpots = const [],
        compoundLayerChartSpots = const [],
        cdeChartSpots = const [],
        cdtChartSpots = const [],
        mrChartSpots = const [],
        compoundLayerMrChartSpots = const [],
        cdeMrChartSpots = const [],
        cdtMrChartSpots = const [],
        specAttribute = null,
        controlChartSpots = null,
        secondChartSelected = null,
        xAxisMediumLabel = const [],
        xAxisLargeLabel = const [],
        xTick = 6;

  factory ControlChartStats.fromJson(Map<String, dynamic> json) =>
      _$ControlChartStatsFromJson(json);

  Map<String, dynamic> toJson() => _$ControlChartStatsToJson(this);
}

/// ==================== Control Limits / Sigma ====================
@JsonSerializable()
class ControlLimitIChart {
  @JsonKey(name: 'CL') final double? cl;
  @JsonKey(name: 'UCL') final double? ucl;
  @JsonKey(name: 'LCL') final double? lcl;

  const ControlLimitIChart({this.cl, this.ucl, this.lcl});

  factory ControlLimitIChart.fromJson(Map<String, dynamic> json) =>
      _$ControlLimitIChartFromJson(json);
  Map<String, dynamic> toJson() => _$ControlLimitIChartToJson(this);
}


/// ==================== Violations ====================
@JsonSerializable()
class Violations{
  final int? beyondControlLimit;
  final int? beyondSpecLimit;
  final int? trend;

  const Violations({this.beyondControlLimit, this.beyondSpecLimit, this.trend});

  factory Violations.fromJson(Map<String, dynamic> json) =>
      _$ViolationsFromJson(json);
  Map<String, dynamic> toJson() => _$ViolationsToJson(this);
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
  @JsonKey(name: 'CL') final double? cl;
  @JsonKey(name: 'UCL') final double? ucl;
  @JsonKey(name: 'LCL') final double? lcl;

  const ControlLimitMRChart({this.cl, this.ucl, this.lcl});

  factory ControlLimitMRChart.fromJson(Map<String, dynamic> json) =>
      _$ControlLimitMRChartFromJson(json);
  Map<String, dynamic> toJson() => _$ControlLimitMRChartToJson(this);
}

/// ==================== Spec Attribute ====================
@JsonSerializable()
class SpecAttribute {
  final String? materialNo;
  final double? surfaceHardnessUpperSpec;
  final double? surfaceHardnessLowerSpec;
  final double? surfaceHardnessTarget;
  final double? compoundLayerUpperSpec;
  final double? compoundLayerLowerSpec;
  final double? compoundLayerTarget;
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
    this.compoundLayerUpperSpec,
    this.compoundLayerLowerSpec,
    this.compoundLayerTarget,
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

/// ==================== NEW: DataPoint / ChartPoints ====================
@JsonSerializable()
class DataPoint {
  /// ค่าจุดบน I-Chart
  final double value;
  final DateTime? collectDate;

  /// Nelson Rule 1 (เกิน LCL/UCL/LSL/USL)
  @JsonKey(defaultValue: false) final bool isViolatedR1BeyondLCL;
  @JsonKey(defaultValue: false) final bool isViolatedR1BeyondUCL;
  @JsonKey(defaultValue: false) final bool isViolatedR1BeyondLSL;
  @JsonKey(defaultValue: false) final bool isViolatedR1BeyondUSL;

  /// Nelson Rule 3 (8 จุดติดต่อกันด้านเดียวของเส้นกลาง)
  @JsonKey(defaultValue: false) final bool isViolatedR3;

  const DataPoint({
    required this.value,
    required this.collectDate,
    this.isViolatedR1BeyondLCL = false,
    this.isViolatedR1BeyondUCL = false,
    this.isViolatedR1BeyondLSL = false,
    this.isViolatedR1BeyondUSL = false,
    this.isViolatedR3 = false,
  });

  factory DataPoint.fromJson(Map<String, dynamic> json) =>
      _$DataPointFromJson(json);
  Map<String, dynamic> toJson() => _$DataPointToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ChartPoints {
  final List<DataPoint> surfaceHardness;
  final List<DataPoint> compoundLayer;
  final List<DataPoint> cde;
  final List<DataPoint> cdt;

  const ChartPoints({
    this.surfaceHardness = const [],
    this.compoundLayer = const [],
    this.cde = const [],
    this.cdt = const [],
  });

  factory ChartPoints.fromJson(Map<String, dynamic> json) =>
      _$ChartPointsFromJson(json);
  Map<String, dynamic> toJson() => _$ChartPointsToJson(this);
}

/// ==================== NEW: Second Chart Selected Enum ====================
@JsonEnum(alwaysCreate: true)
enum SecondChartSelected {
  @JsonValue('CDE')
  cde,

  @JsonValue('CDT')
  cdt,

  @JsonValue('COMPOUND LAYER')
  compoundLayer,

  @JsonValue('NA')
  na,
}