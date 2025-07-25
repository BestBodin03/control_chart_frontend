import 'package:control_chart/config/api_config.dart';
import 'package:control_chart/domain/models/chart_detail.dart';
import 'package:control_chart/domain/types/chart_filter_query.dart';

class SearchChartDetailsApis {
  Future<List<ChartDetail>> getFilteringChartDetails(ChartFilterQuery query) async {
    try {
      final response = await ApiConfig().getQueryParam<Map<String, dynamic>>(
        '/chart-details/filter',
        queryParameters: query.toQueryParams(),
      );

      if (response.containsKey('chartDetails') || response.containsKey('data')) {
        final List<dynamic> data = response['chartDetails'] ?? response['data'] ?? [];
        return data.map((json) => ChartDetail.fromJson(json)).toList();
      }
      
      return [];
      
    } catch (e) {
      throw Exception('Failed to get filtering chart details: $e');
    }
  }
}