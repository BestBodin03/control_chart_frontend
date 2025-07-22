// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chart_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChartDetail _$ChartDetailFromJson(Map<String, dynamic> json) => ChartDetail(
  cpNo: json['CPNo'] as String,
  fgNo: json['FGNo'] as String,
  chartGeneralDetail: ChartGeneralDetail.fromJson(
    json['chartGeneralDetail'] as Map<String, dynamic>,
  ),
  machanicDetail: MachanicDetail.fromJson(
    json['machanicDetail'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$ChartDetailToJson(ChartDetail instance) =>
    <String, dynamic>{
      'CPNo': instance.cpNo,
      'FGNo': instance.fgNo,
      'chartGeneralDetail': instance.chartGeneralDetail,
      'machanicDetail': instance.machanicDetail,
    };

ChartGeneralDetail _$ChartGeneralDetailFromJson(Map<String, dynamic> json) =>
    ChartGeneralDetail(
      furnaceNo: (json['furnaceNo'] as num).toInt(),
      part: json['part'] as String,
      partName: json['partName'] as String,
      collectedDate: DateTime.parse(json['collectedDate'] as String),
    );

Map<String, dynamic> _$ChartGeneralDetailToJson(ChartGeneralDetail instance) =>
    <String, dynamic>{
      'furnaceNo': instance.furnaceNo,
      'part': instance.part,
      'partName': instance.partName,
      'collectedDate': instance.collectedDate.toIso8601String(),
    };

MachanicDetail _$MachanicDetailFromJson(Map<String, dynamic> json) =>
    MachanicDetail(
      surfaceHardnessMean: (json['surfaceHardnessMean'] as num).toDouble(),
      hardnessAt01mmMean: (json['hardnessAt01mmMean'] as num).toDouble(),
      cde: CDE.fromJson(json['CDE'] as Map<String, dynamic>),
      coreHardnessMean: (json['coreHardnessMean'] as num).toDouble(),
      compoundLayer: (json['compoundLayer'] as num).toDouble(),
    );

Map<String, dynamic> _$MachanicDetailToJson(MachanicDetail instance) =>
    <String, dynamic>{
      'surfaceHardnessMean': instance.surfaceHardnessMean,
      'hardnessAt01mmMean': instance.hardnessAt01mmMean,
      'CDE': instance.cde,
      'coreHardnessMean': instance.coreHardnessMean,
      'compoundLayer': instance.compoundLayer,
    };

CDE _$CDEFromJson(Map<String, dynamic> json) => CDE(
  cdex: (json['CDEX'] as num).toDouble(),
  cdey: (json['CDEY'] as num).toDouble(),
);

Map<String, dynamic> _$CDEToJson(CDE instance) => <String, dynamic>{
  'CDEX': instance.cdex,
  'CDEY': instance.cdey,
};
