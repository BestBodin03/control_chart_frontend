import '../../../../domain/models/data_importing.dart';

extension DataImportingCopy on DataImporting {
  DataImporting copyWith({
    String? jobId,
    String? status,
    int? startedAt,
    int? finishedAt,
    int? total,
    int? completed,
    int? success,
    int? failed,
    int? percent,
    String? lastItem,
    List<String>? errors,
  }) => DataImporting(
        jobId: jobId ?? this.jobId,
        status: status ?? this.status,
        startedAt: startedAt ?? this.startedAt,
        finishedAt: finishedAt ?? this.finishedAt,
        total: total ?? this.total,
        completed: completed ?? this.completed,
        success: success ?? this.success,
        failed: failed ?? this.failed,
        percent: percent ?? this.percent,
        lastItem: lastItem ?? this.lastItem,
        errors: errors ?? this.errors,
      );
}
