import 'dart:core';
import 'package:control_chart/apis/api_response.dart';
import 'package:control_chart/config/api_config.dart';
import 'package:control_chart/data/cubit/setting_form/extension/setting_form_state_to_request.dart';
import 'package:control_chart/data/cubit/setting_form/setting_form_state.dart';
import 'package:control_chart/domain/models/chart_detail.dart';
import 'package:control_chart/domain/models/customer_product.dart';
import 'package:control_chart/domain/models/furnace.dart';
import 'package:control_chart/domain/models/setting.dart';
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

      if (res.statusCode == 200) {
        return ApiResponse.fromResponse<Setting>(res, Setting.fromJson);
      } else {
        return ApiResponse<Setting>(
          success: false,
          data: const [],
          error: 'ไม่สามารถโหลดข้อมูลได้ (รหัส ${res.statusCode})',
        );
      }
    } on DioException catch (e) {
      String message = 'เกิดข้อผิดพลาดในการเชื่อมต่อ';
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        message = 'การเชื่อมต่อล้มเหลว กรุณาลองใหม่';
      } else if (e.type == DioExceptionType.badResponse) {
        message = 'เซิร์ฟเวอร์ไม่ตอบสนอง กรุณาลองใหม่ภายหลัง';
      }
      return ApiResponse<Setting>(success: false, data: const [], error: message);
    }
  }

  Future<ApiResponse<Setting>> getTvProfileSettings() async {
    try {
      final Response res = await ApiConfig().get('/setting/setting-profile-for-tv');
      final result = ApiResponse.fromResponse<Setting>(res, Setting.fromJson);
      // debugPrint('In API: $result');
      return result;
    } catch (e) {
      return ApiResponse<Setting>(
        success: false,
        data: const [],
        error: 'Failed to get TV setting profile: $e',
      );
    }
  }

Future<Map<String, dynamic>> getSettingFormDropdown({
  String? furnaceNo,
  String? cpNo,
}) async {
  // ถ้าส่งทั้งคู่ → ไม่ส่ง query เลย
final query = <String, dynamic>{ if (furnaceNo?.isNotEmpty ?? false) 'furnaceNo': furnaceNo, if (cpNo?.isNotEmpty ?? false) 'cpNo': cpNo, };

  debugPrint('[API] GET /furnace-cache/search query=$query');

  final res = await ApiConfig().getQueryParam<Map<String, dynamic>>(
    '/furnace-cache/search',
    queryParameters: query,
  );

  debugPrint("🟡 In the API SEARCH: $res");

  // ✅ Transform cpName to a flat list of strings
  final cpNames = (res['cpName'] as List<dynamic>?)
          ?.map((e) => (e as List<dynamic>)[1].toString())
          .toList() ??
      [];

  // ✅ Return the same structure but with cpName cleaned up
  return {
    ...res,
    'cpName': cpNames,
  };
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

  Future<Map<String, dynamic>> addNewSettingProfile(
    SettingFormState form, {
    Map<int, String>? ruleNameById,
  }) async {
    final req = form.toRequest(ruleNameById: ruleNameById);
    final body = req.toJson();
    debugPrint('ADD NEW SETTING PROFILE');
    return await ApiConfig().post<Map<String, dynamic>>('/setting/create', body);
  }

  Future<Map<String, dynamic>> updateSettingProfile(
    String id,
    SettingFormState form, {
    Map<int, String>? ruleNameById,
  }) async {
    final req = form.toRequest(ruleNameById: ruleNameById);
    final body = req.toJson();
    debugPrint('UPDATE NEW SETTING PROFILE');
    print('/setting/update/$id');
    return await ApiConfig().patch<Map<String, dynamic>>(
      '/setting/update/$id',
      data: body,
    );
  }

  Future<Map<String, dynamic>?> removeSettingProfiles({
    required List<String> ids,
  }) {
    return ApiConfig().delete<Map<String, dynamic>>(
      '/setting/delete/',                     // 👈 ใช้ DELETE จริง (RESTful)
      data: {'ids': ids},             // 👈 body ที่ต้องการ
    );
  }
}