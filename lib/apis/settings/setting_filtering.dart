import 'package:control_chart/config/api_config.dart';
import 'package:control_chart/utils/count_extractor.dart';
import 'package:dio/dio.dart';

final dio = Dio();

void getHttp() async {
  try {
    Response response = await dio.get('${ApiConfig.baseURL}${ApiConfig.apiVersion}/test/chart-details');
    response.statusCode == 200 ? print('🍈 Endpoint founded') : print('🍎 Invalid endpoint');
    
  } catch (e) {
    print('Error: $e');
  }
}

class SettingFilteringApi {
    Future<int> getChartDetailCount() async {
    try {
      final response = await dio.get('${ApiConfig.baseURL}${ApiConfig.apiVersion}/test/chart-details');
      return CountExtractor.extractCountFromResponse(response);
    } catch (e) {
      throw Exception('Failed to get chart status: $e');
    }
  }
}
  