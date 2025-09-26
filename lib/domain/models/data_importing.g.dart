// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_importing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DataImporting _$DataImportingFromJson(Map<String, dynamic> json) =>
    DataImporting(
      jobId: json['jobId'] as String,
      status: json['status'] as String,
      startedAt: (json['startedAt'] as num?)?.toInt(),
      finishedAt: (json['finishedAt'] as num?)?.toInt(),
      total: (json['total'] as num).toInt(),
      completed: (json['completed'] as num).toInt(),
      success: (json['success'] as num).toInt(),
      failed: (json['failed'] as num).toInt(),
      percent: (json['percent'] as num).toInt(),
      lastItem: json['lastItem'] as String?,
      errors:
          (json['errors'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$DataImportingToJson(DataImporting instance) =>
    <String, dynamic>{
      'jobId': instance.jobId,
      'status': instance.status,
      'startedAt': instance.startedAt,
      'finishedAt': instance.finishedAt,
      'total': instance.total,
      'completed': instance.completed,
      'success': instance.success,
      'failed': instance.failed,
      'percent': instance.percent,
      'lastItem': instance.lastItem,
      'errors': instance.errors,
    };
