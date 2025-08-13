import 'package:control_chart/config/api_config.dart';
import 'package:control_chart/domain/models/chart_detail.dart';
import 'package:control_chart/domain/models/control_chart_stats.dart';
import 'package:control_chart/domain/types/chart_filter_query.dart';
import 'package:control_chart/domain/types/search_table.dart';
// import 'package:dio/dio.dart';

class SearchChartDetailsApis {
  // Future<List<ChartDetail>> getFilteringChartDetails(ChartFilterQuery query) async {
  //   try {
  //     final response = await ApiConfig().getQueryParam<Map<String, dynamic>>(
  //       '/chart-details/filter',
  //       queryParameters: query.toQueryParams(),
  //     );
  //     print('QUERY PARAMS IS ${query.toQueryParams()}');

  //     // Get the array of chart details
  //     final List<dynamic> data = response['data'] ?? [];
  //     final List<dynamic> summary = response['summary'] ?? [];
  //     print('✅ Found ${data.length} items');
  //     print('SUMMARY: $summary');
  //     // print(data);
      
  //     // Access the separate summary data (not part of the array)
  //     if (response['machanicDetail'] != null && response['chartGeneralDetail'] != null) {
  //       // print('====== Spots =====');
  //       // print('Value: ${response['machanicDetail']['surfaceHardnessMean']}');
  //       // print('Date Label: ${response['chartGeneralDetail']['collectedDate']}');
  //     }
      
  //     return data.map((json) => ChartDetail.fromJson(json)).toList();
      
  //   } catch (e) {
  //     throw Exception('Failed to get filtering chart details spots: $e');
  //   }
  // }

  Future<(List<ChartDetail>, List<SearchTable>)> getFilteringChartDetails(ChartFilterQuery query) async {
    try {
      final response = await ApiConfig().getQueryParam<Map<String, dynamic>>(
        '/chart-details/filter',
        queryParameters: query.toQueryParams(),
      );
      // print(query.toQueryParams());
      final List<dynamic> data = response['data'] ?? [];
      final List<dynamic> summary = response['summary'] ?? [];
      final lengOfSummary = summary.length;
      print('No. of Summary List: $lengOfSummary');
      
      // Map ChartDetail
      final chartDetails = data.map((json) => ChartDetail.fromJson(json)).toList();
      
      // Map SearchTable จาก summary ใช้ helper method
      final searchTables = SearchTable.fromSummaryList(summary);
      
      return (chartDetails, searchTables);
      
    } catch (e) {
      throw Exception('Failed to get filtering chart details spots: $e');
    }
  }

  Future<ControlChartStats> getControlChartStat(ChartFilterQuery query) async {
    try {
      final response = await ApiConfig().getQueryParam<Map<String, dynamic>>(
        '/chart-details/calculate',
        queryParameters: query.toQueryParams(),
      );
      final data = response['data'];
      final stats = ControlChartStats.fromJson(data);
      
      return stats;
    } catch (e) {
      print('Unexpected error: $e');
      throw Exception('ต้องการข้อมูลอย่างน้อย 2 รายการเพื่อคำนวณแสดงแผนภูมิควบคุม');
    }
  }
}