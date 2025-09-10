import 'package:control_chart/config/api_config.dart';
import 'package:control_chart/domain/models/chart_detail.dart';
import 'package:control_chart/domain/models/control_chart_stats.dart';
import 'package:control_chart/domain/types/chart_filter_query.dart';
import 'package:control_chart/domain/types/search_table.dart';
import 'package:control_chart/domain/types/tv_query.dart';
// import 'package:dio/dio.dart';

class SearchChartDetailsApis {

  Future<(List<ChartDetail>, List<SearchTable>)> getFilteringChartDetails(ChartFilterQuery query) async {
    try {
      final response = await ApiConfig().getQueryParam<Map<String, dynamic>>(
        '/chart-details/filter',
        queryParameters: query.toQueryParams(),
      );
      
      // Handle null response
      if (response.isEmpty) {
        return (const <ChartDetail>[], const <SearchTable>[]);
      }
      
      final List<dynamic> data = response['data'] ?? [];
      final List<dynamic> summary = response['summary'] ?? [];
      final lengOfSummary = summary.length;
      print('No. of Summary List: $lengOfSummary');
      
      // Map ChartDetail with null safety
      final chartDetails = data
          .where((json) => json != null)
          .map((json) => ChartDetail.fromJson(json as Map<String, dynamic>))
          .toList();
      
      // Map SearchTable from summary
      final searchTables = SearchTable.fromSummaryList(summary);
      
      return (chartDetails, searchTables);
      
    } catch (e) {
      print('Error in getFilteringChartDetails: $e');
      return (const <ChartDetail>[], const <SearchTable>[]);
    }
  }

  Future<(List<ChartDetail>, List<SearchTable>)> getTvChartDetails(TvQuery query) async {
    try {
      final response = await ApiConfig().getQueryParam<Map<String, dynamic>>(
        '/chart-details/filter',
        queryParameters: query.toQueryParams(),
      );
      
      // Handle null response
      if (response.isEmpty) {
        return (const <ChartDetail>[], const <SearchTable>[]);
      }
      
      final List<dynamic> data = response['data'] ?? [];
      final List<dynamic> summary = response['summary'] ?? [];
      final lengOfSummary = summary.length;
      print('No. of Summary List: $lengOfSummary');
      
      // Map ChartDetail with null safety
      final chartDetails = data
          .where((json) => json != null)
          .map((json) => ChartDetail.fromJson(json as Map<String, dynamic>))
          .toList();
      
      // Map SearchTable from summary
      final searchTables = SearchTable.fromSummaryList(summary);
      
      return (chartDetails, searchTables);
      
    } catch (e) {
      print('Error in getFilteringChartDetails: $e');
      return (const <ChartDetail>[], const <SearchTable>[]);
    }
  }

  Future<ControlChartStats> getControlChartStat(ChartFilterQuery query) async {
    try {
      final response = await ApiConfig().getQueryParam<Map<String, dynamic>>(
        '/chart-details/calculate',
        queryParameters: query.toQueryParams(),
      );
      
      // Handle null response or null data
      if (response.isEmpty || response['data'] == null) {
        throw Exception('No data available for chart statistics');
      }
      
      final data = response['data'] as Map<String, dynamic>;
      final stats = ControlChartStats.fromJson(data);

      // print(stats.yAxisRange?.maxYsurfaceHardnessControlChart.toString());   
         
      return stats;
    } catch (e) {
      print('Error in getControlChartStat: $e');
      throw Exception('ต้องการข้อมูลอย่างน้อย 5 รายการ เพื่อแสดงแผนภูมิควบคุม');
    }
  }

  Future<ControlChartStats> getTvControlChartStat(TvQuery query) async {
    try {
      final response = await ApiConfig().getQueryParam<Map<String, dynamic>>(
        '/chart-details/calculate',
        queryParameters: query.toQueryParams(),
      );
      
      // Handle null response or null data
      if (response.isEmpty || response['data'] == null) {
        throw Exception('No data available for chart statistics');
      }
      
      final data = response['data'] as Map<String, dynamic>;
      final stats = ControlChartStats.fromJson(data);

      // print(stats.yAxisRange?.maxYsurfaceHardnessControlChart.toString());   
         
      return stats;
    } catch (e) {
      print('Error in getControlChartStat: $e');
      throw Exception('ต้องการข้อมูลอย่างน้อย 5 รายการ เพื่อแสดงแผนภูมิควบคุม');
    }
  }
}