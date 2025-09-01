import 'package:dio/dio.dart';

class ApiConfig {
  final Dio _dio = Dio(BaseOptions(baseUrl: "ไม่บอกหรอก"));

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

  Future<T> post<T>(String endpoint, Map<String, dynamic> data) async {
    try {
      final res = await _dio.post(
        endpoint,
        data: data,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (_) => true, // <-- let us inspect body for 4xx/5xx
        ),
      );

      // log for debugging
      // ignore: avoid_print
      print('POST $endpoint -> ${res.statusCode}\n${res.data}');

      if (res.statusCode != null && res.statusCode! >= 200 && res.statusCode! < 300) {
        return res.data as T;
      }

      // throw with body so you can see server message (stack/validation details)
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        type: DioExceptionType.badResponse,
        error: 'HTTP ${res.statusCode}: ${res.data}',
      );
    } on DioException catch (e) {
      // ignore: avoid_print
      print('DioException: ${e.response?.statusCode} ${e.response?.data}');
      rethrow;
    }
  }

  Future<T> put<T>(String endpoint, dynamic data) async {
    final response = await _dio.put(endpoint, data: data);
    return response.data as T;
  }

  Future<Response<T>> patch<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.patch<T>(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      options: options ?? Options(contentType: Headers.jsonContentType),
    );
  }

  Future<T> delete<T>(String endpoint) async {
    final response = await _dio.delete(endpoint);
    return response.data as T;
  }
} 