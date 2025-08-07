import 'package:control_chart/config/api_config.dart';
import 'package:control_chart/domain/models/chart_detail.dart';
import 'package:control_chart/domain/models/control_chart_stats.dart';
import 'package:control_chart/domain/types/chart_filter_query.dart';
import 'package:dio/dio.dart';

class SearchChartDetailsApis {
  Future<List<ChartDetail>> getFilteringChartDetails(ChartFilterQuery query) async {
    try {
      final response = await ApiConfig().getQueryParam<Map<String, dynamic>>(
        '/chart-details/filter',
        queryParameters: query.toQueryParams(),
      );
      print('QUERY PARAMS IS ${query.toQueryParams()}');

      // Get the array of chart details
      final List<dynamic> data = response['data'] ?? [];
      print('✅ Found ${data.length} items');
      print(data);
      
      // Access the separate summary data (not part of the array)
      if (response['machanicDetail'] != null && response['chartGeneralDetail'] != null) {
        print('====== Spots =====');
        print('Value: ${response['machanicDetail']['surfaceHardnessMean']}');
        print('Date Label: ${response['chartGeneralDetail']['collectedDate']}');
      }
      
      return data.map((json) => ChartDetail.fromJson(json)).toList();
      
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
      final stats = ControlChartStats.fromJson(response);
      
      return stats;
    } catch (e) {
      print('Unexpected error: $e');
      throw Exception('ต้องการข้อมูลอย่างน้อย 2 รายการเพื่อคำนวณแสดงแผนภูมิควบคุม');
    }
  }
}