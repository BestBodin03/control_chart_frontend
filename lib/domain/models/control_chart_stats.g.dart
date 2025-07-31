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
    );

Map<String, dynamic> _$ControlChartStatsToJson(ControlChartStats instance) =>
    <String, dynamic>{
      'numberOfSpots': instance.numberOfSpots,
      'average': instance.average,
      'MRAverage': instance.mrAverage,
      'controlLimitIChart': instance.controlLimitIChart,
      'sigmaIChart': instance.sigmaIChart,
      'controlLimitMRChart': instance.controlLimitMRChart,
    };

ControlLimitIChart _$ControlLimitIChartFromJson(Map<String, dynamic> json) =>
    ControlLimitIChart(
      cl: (json['CL'] as num?)?.toDouble(),
      ucl: (json['UCL'] as num?)?.toDouble(),
      lcl: (json['LCL'] as num?)?.toDouble(),
      usl: (json['USL'] as num?)?.toDouble(),
      lsl: (json['LSL'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ControlLimitIChartToJson(ControlLimitIChart instance) =>
    <String, dynamic>{
      'CL': instance.cl,
      'UCL': instance.ucl,
      'LCL': instance.lcl,
      'USL': instance.usl,
      'LSL': instance.lsl,
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
