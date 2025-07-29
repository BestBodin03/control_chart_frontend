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
      
      // Extract the actual data from the Response object
      final List<dynamic> data = response.data; // or whatever property contains the list
      
      return data.map((json) => Furnace.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get all furnaces: $e');
    }
  }

  Future<List<CustomerProduct>> getAllMatNo() async {
    try {
      final response = await ApiConfig().get<Response<dynamic>>('/all-material-no');
      final List<dynamic> data = response.data;
      return data.map((json) => CustomerProduct.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get all material no: $e');
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

  Future<List<ChartDetail>> getChartDetails() async {
    try {
      final response = await ApiConfig().get<List<dynamic>>('/test/chart-details');
      return response.map((json) => ChartDetail.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get chart status: $e');
    }
  }

}
  