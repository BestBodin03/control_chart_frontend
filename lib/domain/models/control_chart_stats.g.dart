// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'control_chart_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ControlChartStats _$ControlChartStatsFromJson(Map<String, dynamic> json) =>
    ControlChartStats(
      numberOfSpots: (json['numberOfSpots'] as num?)?.toInt(),
      average: (json['average'] as num?)?.toDouble(),
      mrAverage: (json['MRAverage'] as num?)?.toDouble(),
      controlLimitIChart:
          json['controlLimitIChart'] == null
              ? null
              : ControlLimitIChart.fromJson(
                json['controlLimitIChart'] as Map<String, dynamic>,
              ),
      sigmaIChart:
          json['sigmaIChart'] == null
              ? null
              : SigmaIChart.fromJson(
                json['sigmaIChart'] as Map<String, dynamic>,
              ),
      controlLimitMRChart:
          json['controlLimitMRChart'] == null
              ? null
              : ControlLimitMRChart.fromJson(
                json['controlLimitMRChart'] as Map<String, dynamic>,
              ),
      mrChartSpots:
          (json['mrChartSpots'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList(),
      specAttribute:
          json['specAttribute'] == null
              ? null
              : SpecAttribute.fromJson(
                json['specAttribute'] as Map<String, dynamic>,
              ),
    );

Map<String, dynamic> _$ControlChartStatsToJson(ControlChartStats instance) =>
    <String, dynamic>{
      'numberOfSpots': instance.numberOfSpots,
      'average': instance.average,
      'MRAverage': instance.mrAverage,
      'controlLimitIChart': instance.controlLimitIChart,
      'sigmaIChart': instance.sigmaIChart,
      'controlLimitMRChart': instance.controlLimitMRChart,
      'mrChartSpots': instance.mrChartSpots,
      'specAttribute': instance.specAttribute,
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

SpecAttribute _$SpecAttributeFromJson(Map<String, dynamic> json) =>
    SpecAttribute(
      materialNo: json['materialNo'] as String?,
      surfaceHardnessUpperSpec:
          (json['surfaceHardnessUpperSpec'] as num?)?.toDouble(),
      surfaceHardnessLowerSpec:
          (json['surfaceHardnessLowerSpec'] as num?)?.toDouble(),
      surfaceHardnessTarget:
          (json['surfaceHardnessTarget'] as num?)?.toDouble(),
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
      'cdeUpperSpec': instance.cdeUpperSpec,
      'cdeLowerSpec': instance.cdeLowerSpec,
      'cdeTarget': instance.cdeTarget,
      'cdtUpperSpec': instance.cdtUpperSpec,
      'cdtLowerSpec': instance.cdtLowerSpec,
      'cdtTarget': instance.cdtTarget,
    };
