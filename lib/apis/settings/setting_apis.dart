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
      final response = await ApiConfig().get<List<dynamic>>('/test/chart-details');
      return CountExtractor.extractCountFromResponse(response);
    } catch (e) {
      throw Exception('Failed to get chart status: $e');
    }
  }

  Future<List<Furnace>> getAllFurnaces() async {
    try {
      final response = await ApiConfig().get<List<dynamic>>('/all-furnaces');
      return response.map((json) => Furnace.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get all furnaces: $e');
    }
  }

  Future<List<CustomerProduct>> getAllMatNo() async {
    try {
      final response = await ApiConfig().get<List<dynamic>>('/all-material-no');
      return response.map((json) => CustomerProduct.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get all material no: $e');
    }
  }

  Future<Map<String, dynamic>> getFilteringChartDetails({
    required int furnaceNo,
    required String matNo,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await ApiConfig().get<Map<String, dynamic>>(
      '/chart-details/filter',
      queryParameters: {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'furnaceNo': furnaceNo,
        'matNo': matNo,
      },
    );
  }

  Future<List<ChartDetail>> getChartDetails() async {
    try {
      final response = await ApiConfig().get<List<dynamic>>('/test/chart-details');
      return response.map((json) => ChartDetail.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get chart status: $e');
    }
  }

}
  