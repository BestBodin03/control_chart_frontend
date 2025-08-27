import 'dart:convert';
import 'dart:core';
import 'package:control_chart/apis/api_response.dart';
import 'package:control_chart/config/api_config.dart';
import 'package:control_chart/data/cubit/setting_form/extension/setting_form_state_to_request.dart';
import 'package:control_chart/data/cubit/setting_form/setting_form_state.dart';
import 'package:control_chart/domain/models/chart_detail.dart';
import 'package:control_chart/domain/models/customer_product.dart';
import 'package:control_chart/domain/models/furnace.dart';
import 'package:control_chart/domain/models/setting.dart';
import 'package:control_chart/domain/models/setting_request.dart';
import 'package:control_chart/utils/count_extractor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class SettingApis {
  Future<int> getChartDetailCount() async {
    try {
      final response = await ApiConfig().get<Response<dynamic>>('/all-chart-details');
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
      final response = await ApiConfig().get<List<dynamic>>('/all-chart-details');
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
        'data': [],
      };
    }
  }

  Future<ApiResponse<Setting>> getAllProfileSettings() async {
    try {
      final Response res = await ApiConfig().get('/setting/all-profiles');
      return ApiResponse.fromResponse<Setting>(res, Setting.fromJson);
    } catch (e) {
      return ApiResponse<Setting>(
        success: false,
        data: const [],
        error: 'Failed to get settings: $e',
      );
    }
  }

  // Future<Response<dynamic>> getOneProfileSettingsById() async {
  //   try {
  //     final Response res = await ApiConfig().get('/setting/one-profile/$id', body);
  //     return ApiResponse.fromResponse<Setting>(res, Setting.fromJson);
  //   } catch (e) {
  //     return ApiResponse<Setting>(
  //       success: false,
  //       data: const [],
  //       error: 'Failed to get settings: $e',
  //     );
  //   }
  // }

  Future<Response<dynamic>> addNewSettingProfile(
    SettingFormState form, {
    Map<int, String>? ruleNameById,
  }) async {
    final req = form.toRequest(ruleNameById: ruleNameById);
    final body = req.toJson();
    return await ApiConfig().post('/setting/create', body);
  }

  Future<Response<dynamic>> updateSettingProfile(
    String id,
    SettingFormState form, {
    Map<int, String>? ruleNameById,
  }) async {
    final req = form.toRequest(ruleNameById: ruleNameById);
    final body = req.toJson();

    print(body);

    // Match your controller: req.params.id → PUT/PATCH '/setting/:id'
    return await ApiConfig().patch('/setting/update/$id', body);
    // or: return await ApiConfig().patch('/setting/$id', body);
  }
}