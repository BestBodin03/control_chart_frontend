import 'dart:core';
import 'package:control_chart/config/api_config.dart';
import 'package:control_chart/domain/models/chart_detail.dart';
import 'package:control_chart/domain/models/customer_product.dart';
import 'package:control_chart/domain/models/furnace.dart';
import 'package:control_chart/utils/count_extractor.dart';
import 'package:dio/dio.dart';

class SettingApis {
Future<int> getChartDetailCount() async {
    try {
      final response = await ApiConfig().get<Response<dynamic>>('/test/chart-details');
      return CountExtractor.extractCountFromResponse(response);
    } catch (e) {
      throw Exception('Failed to get chart status: $e');
    }
  }

  Future<List<Furnace>> getAllFurnaces() async {
    try {
      final response = await ApiConfig().get<Response<dynamic>>('/all-furnaces');
      final Map<String, dynamic> responseData = response.data;
      final List<dynamic> data = responseData['data']; // Access the 'data' key
      final result = data.map((item) => Furnace.fromJson(item)).toList();
      
      return result;
    } catch (e) {
      throw Exception('Failed to get all furnaces: $e');
    }
  }

  Future<List<CustomerProduct>> getAllMatNo() async {
    try {
      final response = await ApiConfig().get<Response<dynamic>>('/all-material-no');
      final Map<String, dynamic> responseData = response.data;
      final List<dynamic> data = responseData['data'];
      final result = data.map((item) => CustomerProduct.fromJson(item)).toList();
      
      return result;
    } catch (e) {
      throw Exception('Failed to get material number: $e');
    }
  }

  Future<Map<String, dynamic>> getFilteringChartDetails({
     int? furnaceNo,
     String? matNo,
     DateTime? startDate,
     DateTime? endDate,
  }) async {
    return await ApiConfig().getQueryParam<Map<String, dynamic>>(
      '/chart-details/filter',
      queryParameters: {
        'startDate': startDate!.toIso8601String(),
        'endDate': endDate!.toIso8601String(),
        'furnaceNo': furnaceNo,
        'matNo': matNo,
      },
    );
  }

  Future<Map<String, dynamic>> getChartDetails() async {
    try {
      final response = await ApiConfig().get<List<dynamic>>('/test/chart-details');
      final List<ChartDetail> chartDetails = response.map((json) => ChartDetail.fromJson(json)).toList();
      
      return {
        'success': true,
        'data': chartDetails.map((chart) => chart.toJson()).toList(),
        'count': chartDetails.length,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to get chart status: $e',
        'data': null,
      };
    }
  }

}
  