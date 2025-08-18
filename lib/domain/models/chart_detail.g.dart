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
      cde: CDE.fromJson(json['CDE'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MachanicDetailToJson(MachanicDetail instance) =>
    <String, dynamic>{
      'surfaceHardnessMean': instance.surfaceHardnessMean,
      'CDE': instance.cde,
    };

CDE _$CDEFromJson(Map<String, dynamic> json) => CDE(
  cdex: (json['CDEX'] as num).toDouble(),
  cdtx: (json['CDTX'] as num).toDouble(),
);

Map<String, dynamic> _$CDEToJson(CDE instance) => <String, dynamic>{
  'CDEX': instance.cdex,
  'CDTX': instance.cdtx,
};

Filters _$FiltersFromJson(Map<String, dynamic> json) => Filters(
  period: Period.fromJson(json['period'] as Map<String, dynamic>),
  furnaceNo: (json['furnaceNo'] as num?)?.toInt(),
  matNo: json['matNo'] as String,
);

Map<String, dynamic> _$FiltersToJson(Filters instance) => <String, dynamic>{
  'period': instance.period,
  'furnaceNo': instance.furnaceNo,
  'matNo': instance.matNo,
};

Period _$PeriodFromJson(Map<String, dynamic> json) => Period(
  startDate: json['startDate'] as String,
  endDate: json['endDate'] as String,
);

Map<String, dynamic> _$PeriodToJson(Period instance) => <String, dynamic>{
  'startDate': instance.startDate,
  'endDate': instance.endDate,
};
