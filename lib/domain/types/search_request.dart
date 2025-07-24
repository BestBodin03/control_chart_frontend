class SearchRequest {
  final int furnaceNo;
  final String matNo;
  final DateTime startDate;
  final DateTime endDate;

  SearchRequest({
    required this.furnaceNo,
    required this.matNo,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toQueryParams() {
    return {
      'furnaceNo': furnaceNo,
      'matNo': matNo,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }
}