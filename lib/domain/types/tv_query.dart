// models/chart_filter_query.dart
import 'dart:convert';

import 'package:intl/intl.dart';

class TvQuery {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? furnaceNo;
  final String? materialNo;

  const TvQuery({
    this.startDate,
    this.endDate,
    this.furnaceNo,
    this.materialNo,
  });

  Map<String, dynamic> toQueryParams() {
    final Map<String, dynamic> params = {};
    
    if (startDate != null) {
      params['startDate'] = jsonEncode(startDate!.toIso8601String());
    }
    if (endDate != null) {
      params['endDate'] = jsonEncode(endDate!.toIso8601String());
    }
    if (furnaceNo != null) {
      params['furnaceNo'] = furnaceNo;
    }
    if (materialNo != null) {
      params['matNo'] = materialNo;
    }
    return params;
  }

  TvQuery copyWith({
    DateTime? startDate,
    DateTime? endDate,
    String? furnaceNo,
    String? materialNo,
  }) {
    return TvQuery(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      furnaceNo: furnaceNo ?? this.furnaceNo,
      materialNo: materialNo ?? this.materialNo,
    );
  }
}