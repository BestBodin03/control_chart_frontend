import 'package:dio/dio.dart';

import 'constant.dart';

class ApiConfig {
  final Dio _dio = Dio(BaseOptions(baseUrl: serverUrl));

  Future<T> get<T>(String endpoint) async {
    final response = await _dio.get(endpoint);
      return response as T;
  }

  Future<T> getQueryParam<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data as T;
    } catch (e) {
      throw Exception('GET request failed: $e');
    }
  }

  Future<T> post<T>(String endpoint, dynamic data) async {
    try {
      final res = await _dio.post(
        endpoint,
        data: data,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (_) => true,
        ),
      );

      print('POST $endpoint -> ${res.statusCode}\n${res.data}');

      if (res.statusCode != null && res.statusCode! >= 200 && res.statusCode! < 300) {
        return res.data as T; // <-- คืน JSON (data) ไม่ใช่ Response
      }

      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        type: DioExceptionType.badResponse,
        error: 'HTTP ${res.statusCode}: ${res.data}',
      );
    } on DioException catch (e) {
      print('DioException: ${e.response?.statusCode} ${e.response?.data}');
      rethrow;
    }
  }

  Future<T> patch<T>(String endpoint, {dynamic data}) async {
    final res = await _dio.patch(
      endpoint,
      data: data,
      options: Options(
        headers: {'Content-Type': 'application/json'},
        validateStatus: (_) => true,
      ),
    );

    print('PATCH $endpoint -> ${res.statusCode}\n${res.data}');

    if (res.statusCode != null && res.statusCode! >= 200 && res.statusCode! < 300) {
      return res.data as T;
    }

    throw DioException(
      requestOptions: res.requestOptions,
      response: res,
      type: DioExceptionType.badResponse,
      error: 'HTTP ${res.statusCode}: ${res.data}',
    );
  }

  Future<T> put<T>(String endpoint, dynamic data) async {
    final response = await _dio.put(endpoint, data: data);
    return response.data as T;
  }

// ApiConfig.dart
Future<T> delete<T>(
  String endpoint, {
  Map<String, dynamic>? queryParameters,
  dynamic data,                 // 👈 รองรับ body ใน DELETE
  Options? options,
}) async {
  try {
    final res = await _dio.delete(
      endpoint,
      queryParameters: queryParameters,
      data: data,
      options: options ??
          Options(
            headers: const {
              'Content-Type': 'application/json', // สำหรับ JSON body
            },
          ),
    );

    return res.data as T;
  } on DioException catch (e) {
    // ส่งข้อความจาก server ออกไปให้ชัดเจน
    final data = e.response?.data;
    final msg = (data is Map && (data['message'] ?? data['error']) != null)
        ? (data['message'] ?? data['error']).toString()
        : (e.message ?? 'Network error');
    throw DioException(
      requestOptions: e.requestOptions,
      response: e.response,
      type: e.type,
      error: msg,
    );
  }
}

} 