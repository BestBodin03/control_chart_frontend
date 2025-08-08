import 'package:flutter/foundation.dart';

class SearchTable {
  final String? furnaceNo;
  final String? matNo;
  final String? partName;
  final int? count;

  const SearchTable({
    this.furnaceNo,
    this.matNo,
    this.partName,
    this.count
  });

  // Manual mapping จาก summary response
  factory SearchTable.fromSummary(Map<String, dynamic> summary) {
    return SearchTable(
      furnaceNo: summary['furnaceNo']?.toString() ?? '-',
      matNo: summary['matNo']?.toString() ?? '-',
      partName: summary['partName']?.toString() ?? '-', // summary ไม่มี partName
      count: summary['count'] is int 
        ? summary['count'] 
        : int.tryParse(summary['count']?.toString() ?? '0'),
    );
  }

  // Helper method สำหรับแปลง List
  static List<SearchTable> fromSummaryList(List<dynamic> summaryList) {
    final summaryToList = summaryList.map((summary) => SearchTable.fromSummary(summary)).toList();
    return summaryToList;
  }
}