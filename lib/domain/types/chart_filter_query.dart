// models/chart_filter_query.dart
import 'dart:convert';

class ChartFilterQuery {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? furnaceNo;
  final String? materialNo;

  const ChartFilterQuery({
    this.startDate,
    this.endDate,
    this.furnaceNo,
    this.materialNo,
  });

  Map<String, dynamic> toQueryParams() {
    final Map<String, dynamic> params = {};

    if (startDate != null) {
      // 🔹 Normalize startDate → 00:00:00.000 UTC
      final startAtMidnightUtc = DateTime.utc(
        startDate!.toUtc().year,
        startDate!.toUtc().month,
        startDate!.toUtc().day,
        0, 0, 0, 0,
      );
      params['startDate'] = jsonEncode(startAtMidnightUtc.toIso8601String());
    }

    if (endDate != null) {
      // 🔹 Normalize endDate → 23:59:59.999 UTC
      final endAtEndOfDayUtc = DateTime.utc(
        endDate!.toUtc().year,
        endDate!.toUtc().month,
        endDate!.toUtc().day,
        23, 59, 59, 999,
      );
      params['endDate'] = jsonEncode(endAtEndOfDayUtc.toIso8601String());
    }

    if (furnaceNo != null) {
      params['furnaceNo'] = furnaceNo;
    }

    if (materialNo != null) {
      params['matNo'] = materialNo;
    }

    return params;
  }

  ChartFilterQuery copyWith({
    DateTime? startDate,
    DateTime? endDate,
    String? furnaceNo,
    String? materialNo,
  }) {
    return ChartFilterQuery(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      furnaceNo: furnaceNo ?? this.furnaceNo,
      materialNo: materialNo ?? this.materialNo,
    );
  }
}
