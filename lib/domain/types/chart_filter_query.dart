class ChartFilterQuery {
  final String? furnaceNo;
  final String? matNo;
  final String? startDate;
  final String? endDate;

  const ChartFilterQuery({
    this.furnaceNo,
    this.matNo,
    this.startDate,
    this.endDate,
  });

  ChartFilterQuery copyWith({
    String? furnaceNo,
    String? matNo,
    String? startDate,
    String? endDate,
  }) {
    return ChartFilterQuery(
      furnaceNo: furnaceNo ?? this.furnaceNo,
      matNo: matNo ?? this.matNo,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  // Convert to query parameters for API call
  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    
    if (startDate != null) {
      params['startDate'] = startDate;
    }
    if (endDate != null) {
      params['endDate'] = endDate;
    }
    if (furnaceNo != null) {
      params['furnaceNo'] = furnaceNo;
    }
    if (matNo != null && matNo!.isNotEmpty) {
      params['matNo'] = matNo;
    }
    
    return params;
  }

  bool get isEmpty => 
    furnaceNo == null && 
    (matNo == null || matNo!.isEmpty) && 
    startDate == null && 
    endDate == null;
}