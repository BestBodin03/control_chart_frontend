import 'package:control_chart/config/api_config.dart';
import 'package:control_chart/domain/models/chart_detail.dart';
import 'package:control_chart/domain/models/control_chart_stats.dart';
import 'package:control_chart/domain/types/chart_filter_query.dart';

class SearchChartDetailsApis {
  Future<List<ChartDetail>> getFilteringChartDetails(ChartFilterQuery query) async {
    try {
      final response = await ApiConfig().getQueryParam<Map<String, dynamic>>(
        '/chart-details/filter',
        queryParameters: query.toQueryParams(),
      );
      print('QUERY PARAMS IS ${query.toQueryParams()}');

      if (response.containsKey('chartDetails') || response.containsKey('data')) {
        final List<dynamic> data = response['chartDetails'] ?? response['data'] ?? [];
        print('✅ Found ${data.length} items');
        return data.map((json) => ChartDetail.fromJson(json)).toList();
      }
      
      return [];
      
      
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
      print('📈 QUERY PARAMS IS ${query.toQueryParams()}');
      print(response);

      // if (response.containsKey('chartDetails') || response.containsKey('data')) {
      //   final List<dynamic> data = response['chartDetails'] ?? response['data'] ?? [];
      //   print('✅ Found ${data.length} items');
      //   return data.map((json) => ChartDetail.fromJson(json)).toList();
      // }
          // Check specific fields
    print('📋 Attempting to parse response...');
    final stats = ControlChartStats.fromJson(response);
    print('✅ Parsing successful!');
    print('📋 UCL: ${stats.controlLimitIChart?.ucl}');
    print('📋 Average: ${stats.average}');
    
    return stats;
      
    } catch (e) {
      throw Exception('Failed to get filtering chart detailsssssssssssss: $e');
    }
  }
}