// models/chart_filter_query.dart
class ChartFilterQuery {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? furnaceNo;
  final String? materialNo;
  final int? page;
  final int? limit;

  const ChartFilterQuery({
    this.startDate,
    this.endDate,
    this.furnaceNo,
    this.materialNo,
    this.page,
    this.limit,
  });

  Map<String, dynamic> toQueryParams() {
    final Map<String, dynamic> params = {};
    
    if (startDate != null) {
      params['startDate'] = startDate!.toIso8601String();
    }
    if (endDate != null) {
      params['endDate'] = endDate!.toIso8601String();
    }
    if (furnaceNo != null && furnaceNo!.isNotEmpty) {
      params['furnaceNo'] = furnaceNo;
    }
    if (materialNo != null && materialNo!.isNotEmpty) {
      params['matNo'] = materialNo;
    }
    if (page != null) {
      params['page'] = page.toString();
    }
    if (limit != null) {
      params['limit'] = limit.toString();
    }
    
    return params;
  }

  ChartFilterQuery copyWith({
    DateTime? startDate,
    DateTime? endDate,
    String? furnaceNo,
    String? materialNo,
    int? page,
    int? limit,
  }) {
    return ChartFilterQuery(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      furnaceNo: furnaceNo ?? this.furnaceNo,
      materialNo: materialNo ?? this.materialNo,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }
}