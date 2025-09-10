// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'control_chart_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ControlChartStats _$ControlChartStatsFromJson(
  Map<String, dynamic> json,
) => ControlChartStats(
  numberOfSpots: (json['numberOfSpots'] as num?)?.toInt(),
  average: (json['average'] as num?)?.toDouble(),
  compoundLayerAverage: (json['compoundLayerAverage'] as num?)?.toDouble(),
  cdeAverage: (json['cdeAverage'] as num?)?.toDouble(),
  cdtAverage: (json['cdtAverage'] as num?)?.toDouble(),
  mrAverage: (json['MRAverage'] as num?)?.toDouble(),
  compoundLayerMrAverage: (json['compoundLayerMRAverage'] as num?)?.toDouble(),
  cdeMrAverage: (json['cdeMRAverage'] as num?)?.toDouble(),
  cdtMrAverage: (json['cdtMRAverage'] as num?)?.toDouble(),
  controlLimitIChart:
      json['controlLimitIChart'] == null
          ? null
          : ControlLimitIChart.fromJson(
            json['controlLimitIChart'] as Map<String, dynamic>,
          ),
  compoundLayerControlLimitIChart:
      json['compoundLayerControlLimitIChart'] == null
          ? null
          : ControlLimitIChart.fromJson(
            json['compoundLayerControlLimitIChart'] as Map<String, dynamic>,
          ),
  cdeControlLimitIChart:
      json['cdeControlLimitIChart'] == null
          ? null
          : ControlLimitIChart.fromJson(
            json['cdeControlLimitIChart'] as Map<String, dynamic>,
          ),
  cdtControlLimitIChart:
      json['cdtControlLimitIChart'] == null
          ? null
          : ControlLimitIChart.fromJson(
            json['cdtControlLimitIChart'] as Map<String, dynamic>,
          ),
  sigmaIChart:
      json['sigmaIChart'] == null
          ? null
          : SigmaIChart.fromJson(json['sigmaIChart'] as Map<String, dynamic>),
  compoundLayerSigmaIChart:
      json['compoundLayerSigmaIChart'] == null
          ? null
          : SigmaIChart.fromJson(
            json['compoundLayerSigmaIChart'] as Map<String, dynamic>,
          ),
  cdeSigmaIChart:
      json['cdeSigmaIChart'] == null
          ? null
          : SigmaIChart.fromJson(
            json['cdeSigmaIChart'] as Map<String, dynamic>,
          ),
  cdtSigmaIChart:
      json['cdtSigmaIChart'] == null
          ? null
          : SigmaIChart.fromJson(
            json['cdtSigmaIChart'] as Map<String, dynamic>,
          ),
  controlLimitMRChart:
      json['controlLimitMRChart'] == null
          ? null
          : ControlLimitMRChart.fromJson(
            json['controlLimitMRChart'] as Map<String, dynamic>,
          ),
  compoundLayerControlLimitMRChart:
      json['compoundLayerControlLimitMRChart'] == null
          ? null
          : ControlLimitMRChart.fromJson(
            json['compoundLayerControlLimitMRChart'] as Map<String, dynamic>,
          ),
  cdeControlLimitMRChart:
      json['cdeControlLimitMRChart'] == null
          ? null
          : ControlLimitMRChart.fromJson(
            json['cdeControlLimitMRChart'] as Map<String, dynamic>,
          ),
  cdtControlLimitMRChart:
      json['cdtControlLimitMRChart'] == null
          ? null
          : ControlLimitMRChart.fromJson(
            json['cdtControlLimitMRChart'] as Map<String, dynamic>,
          ),
  surfaceHardnessChartSpots:
      (json['surfaceHardnessChartSpots'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
  compoundLayerChartSpots:
      (json['compoundLayerChartSpots'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
  cdeChartSpots:
      (json['cdeChartSpots'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
  cdtChartSpots:
      (json['cdtChartSpots'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
  mrChartSpots:
      (json['mrChartSpots'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
  compoundLayerMrChartSpots:
      (json['compoundLayerMrChartSpots'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
  cdeMrChartSpots:
      (json['cdeMrChartSpots'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
  cdtMrChartSpots:
      (json['cdtMrChartSpots'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
  specAttribute:
      json['specAttribute'] == null
          ? null
          : SpecAttribute.fromJson(
            json['specAttribute'] as Map<String, dynamic>,
          ),
  yAxisRange:
      json['yAxisRange'] == null
          ? null
          : YAxisRange.fromJson(json['yAxisRange'] as Map<String, dynamic>),
  controlChartSpots:
      json['controlChartSpots'] == null
          ? null
          : ChartPoints.fromJson(
            json['controlChartSpots'] as Map<String, dynamic>,
          ),
  secondChartSelected: $enumDecodeNullable(
    _$SecondChartSelectedEnumMap,
    json['secondChartSelected'],
  ),
);

Map<String, dynamic> _$ControlChartStatsToJson(ControlChartStats instance) =>
    <String, dynamic>{
      'numberOfSpots': instance.numberOfSpots,
      'average': instance.average,
      'compoundLayerAverage': instance.compoundLayerAverage,
      'cdeAverage': instance.cdeAverage,
      'cdtAverage': instance.cdtAverage,
      'MRAverage': instance.mrAverage,
      'compoundLayerMRAverage': instance.compoundLayerMrAverage,
      'cdeMRAverage': instance.cdeMrAverage,
      'cdtMRAverage': instance.cdtMrAverage,
      'controlLimitIChart': instance.controlLimitIChart?.toJson(),
      'compoundLayerControlLimitIChart':
          instance.compoundLayerControlLimitIChart?.toJson(),
      'cdeControlLimitIChart': instance.cdeControlLimitIChart?.toJson(),
      'cdtControlLimitIChart': instance.cdtControlLimitIChart?.toJson(),
      'sigmaIChart': instance.sigmaIChart?.toJson(),
      'compoundLayerSigmaIChart': instance.compoundLayerSigmaIChart?.toJson(),
      'cdeSigmaIChart': instance.cdeSigmaIChart?.toJson(),
      'cdtSigmaIChart': instance.cdtSigmaIChart?.toJson(),
      'controlLimitMRChart': instance.controlLimitMRChart?.toJson(),
      'compoundLayerControlLimitMRChart':
          instance.compoundLayerControlLimitMRChart?.toJson(),
      'cdeControlLimitMRChart': instance.cdeControlLimitMRChart?.toJson(),
      'cdtControlLimitMRChart': instance.cdtControlLimitMRChart?.toJson(),
      'surfaceHardnessChartSpots': instance.surfaceHardnessChartSpots,
      'compoundLayerChartSpots': instance.compoundLayerChartSpots,
      'cdeChartSpots': instance.cdeChartSpots,
      'cdtChartSpots': instance.cdtChartSpots,
      'mrChartSpots': instance.mrChartSpots,
      'compoundLayerMrChartSpots': instance.compoundLayerMrChartSpots,
      'cdeMrChartSpots': instance.cdeMrChartSpots,
      'cdtMrChartSpots': instance.cdtMrChartSpots,
      'specAttribute': instance.specAttribute?.toJson(),
      'yAxisRange': instance.yAxisRange?.toJson(),
      'controlChartSpots': instance.controlChartSpots?.toJson(),
      'secondChartSelected':
          _$SecondChartSelectedEnumMap[instance.secondChartSelected],
    };

const _$SecondChartSelectedEnumMap = {
  SecondChartSelected.cde: 'CDE',
  SecondChartSelected.cdt: 'CDT',
  SecondChartSelected.compoundLayer: 'COMPOUND LAYER',
  SecondChartSelected.na: 'NA',
};

ControlLimitIChart _$ControlLimitIChartFromJson(Map<String, dynamic> json) =>
    ControlLimitIChart(
      cl: (json['CL'] as num?)?.toDouble(),
      ucl: (json['UCL'] as num?)?.toDouble(),
      lcl: (json['LCL'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ControlLimitIChartToJson(ControlLimitIChart instance) =>
    <String, dynamic>{
      'CL': instance.cl,
      'UCL': instance.ucl,
      'LCL': instance.lcl,
    };

SigmaIChart _$SigmaIChartFromJson(Map<String, dynamic> json) => SigmaIChart(
  sigmaMinus3: (json['sigmaMinus3'] as num?)?.toDouble(),
  sigmaMinus2: (json['sigmaMinus2'] as num?)?.toDouble(),
  sigmaMinus1: (json['sigmaMinus1'] as num?)?.toDouble(),
  sigmaPlus1: (json['sigmaPlus1'] as num?)?.toDouble(),
  sigmaPlus2: (json['sigmaPlus2'] as num?)?.toDouble(),
  sigmaPlus3: (json['sigmaPlus3'] as num?)?.toDouble(),
);

Map<String, dynamic> _$SigmaIChartToJson(SigmaIChart instance) =>
    <String, dynamic>{
      'sigmaMinus3': instance.sigmaMinus3,
      'sigmaMinus2': instance.sigmaMinus2,
      'sigmaMinus1': instance.sigmaMinus1,
      'sigmaPlus1': instance.sigmaPlus1,
      'sigmaPlus2': instance.sigmaPlus2,
      'sigmaPlus3': instance.sigmaPlus3,
    };

ControlLimitMRChart _$ControlLimitMRChartFromJson(Map<String, dynamic> json) =>
    ControlLimitMRChart(
      cl: (json['CL'] as num?)?.toDouble(),
      ucl: (json['UCL'] as num?)?.toDouble(),
      lcl: (json['LCL'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ControlLimitMRChartToJson(
  ControlLimitMRChart instance,
) => <String, dynamic>{
  'CL': instance.cl,
  'UCL': instance.ucl,
  'LCL': instance.lcl,
};

SpecAttribute _$SpecAttributeFromJson(
  Map<String, dynamic> json,
) => SpecAttribute(
  materialNo: json['materialNo'] as String?,
  surfaceHardnessUpperSpec:
      (json['surfaceHardnessUpperSpec'] as num?)?.toDouble(),
  surfaceHardnessLowerSpec:
      (json['surfaceHardnessLowerSpec'] as num?)?.toDouble(),
  surfaceHardnessTarget: (json['surfaceHardnessTarget'] as num?)?.toDouble(),
  compoundLayerUpperSpec: (json['compoundLayerUpperSpec'] as num?)?.toDouble(),
  compoundLayerLowerSpec: (json['compoundLayerLowerSpec'] as num?)?.toDouble(),
  compoundLayerTarget: (json['compoundLayerTarget'] as num?)?.toDouble(),
  cdeUpperSpec: (json['cdeUpperSpec'] as num?)?.toDouble(),
  cdeLowerSpec: (json['cdeLowerSpec'] as num?)?.toDouble(),
  cdeTarget: (json['cdeTarget'] as num?)?.toDouble(),
  cdtUpperSpec: (json['cdtUpperSpec'] as num?)?.toDouble(),
  cdtLowerSpec: (json['cdtLowerSpec'] as num?)?.toDouble(),
  cdtTarget: (json['cdtTarget'] as num?)?.toDouble(),
);

Map<String, dynamic> _$SpecAttributeToJson(SpecAttribute instance) =>
    <String, dynamic>{
      'materialNo': instance.materialNo,
      'surfaceHardnessUpperSpec': instance.surfaceHardnessUpperSpec,
      'surfaceHardnessLowerSpec': instance.surfaceHardnessLowerSpec,
      'surfaceHardnessTarget': instance.surfaceHardnessTarget,
      'compoundLayerUpperSpec': instance.compoundLayerUpperSpec,
      'compoundLayerLowerSpec': instance.compoundLayerLowerSpec,
      'compoundLayerTarget': instance.compoundLayerTarget,
      'cdeUpperSpec': instance.cdeUpperSpec,
      'cdeLowerSpec': instance.cdeLowerSpec,
      'cdeTarget': instance.cdeTarget,
      'cdtUpperSpec': instance.cdtUpperSpec,
      'cdtLowerSpec': instance.cdtLowerSpec,
      'cdtTarget': instance.cdtTarget,
    };

DataPoint _$DataPointFromJson(Map<String, dynamic> json) => DataPoint(
  value: (json['value'] as num).toDouble(),
  isViolatedR1BeyondLCL: json['isViolatedR1BeyondLCL'] as bool? ?? false,
  isViolatedR1BeyondUCL: json['isViolatedR1BeyondUCL'] as bool? ?? false,
  isViolatedR1BeyondLSL: json['isViolatedR1BeyondLSL'] as bool? ?? false,
  isViolatedR1BeyondUSL: json['isViolatedR1BeyondUSL'] as bool? ?? false,
  isViolatedR3: json['isViolatedR3'] as bool? ?? false,
);

Map<String, dynamic> _$DataPointToJson(DataPoint instance) => <String, dynamic>{
  'value': instance.value,
  'isViolatedR1BeyondLCL': instance.isViolatedR1BeyondLCL,
  'isViolatedR1BeyondUCL': instance.isViolatedR1BeyondUCL,
  'isViolatedR1BeyondLSL': instance.isViolatedR1BeyondLSL,
  'isViolatedR1BeyondUSL': instance.isViolatedR1BeyondUSL,
  'isViolatedR3': instance.isViolatedR3,
};

ChartPoints _$ChartPointsFromJson(Map<String, dynamic> json) => ChartPoints(
  surfaceHardness:
      (json['surfaceHardness'] as List<dynamic>?)
          ?.map((e) => DataPoint.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  compoundLayer:
      (json['compoundLayer'] as List<dynamic>?)
          ?.map((e) => DataPoint.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  cde:
      (json['cde'] as List<dynamic>?)
          ?.map((e) => DataPoint.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  cdt:
      (json['cdt'] as List<dynamic>?)
          ?.map((e) => DataPoint.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$ChartPointsToJson(
  ChartPoints instance,
) => <String, dynamic>{
  'surfaceHardness': instance.surfaceHardness.map((e) => e.toJson()).toList(),
  'compoundLayer': instance.compoundLayer.map((e) => e.toJson()).toList(),
  'cde': instance.cde.map((e) => e.toJson()).toList(),
  'cdt': instance.cdt.map((e) => e.toJson()).toList(),
};
