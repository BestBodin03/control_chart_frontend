// core/api/api_response.dart
import 'package:dio/dio.dart';

class ApiResponse<T> {
  final bool success;
  final List<T> data;
  final String? error;

  const ApiResponse({
    required this.success,
    required this.data,
    this.error,
  });

  // ✅ success only if status == "success" (case-insensitive)
  static bool _isOk(dynamic status) =>
      status is String && status.toLowerCase() == 'success';

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final raw = json['data'];
    final items = (raw is List)
        ? raw.whereType<Map<String, dynamic>>().map(fromJsonT).toList()
        : <T>[];

    final success = _isOk(json['status']) ||
        (json['success'] == true);

    final error = json['error']?.toString() ?? json['message']?.toString();

    return ApiResponse<T>(
      success: success,
      data: items,
      error: error,
    );
  }

  /// Parse directly from Dio Response<dynamic>
  static ApiResponse<T> fromResponse<T>(
    Response res,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final body = res.data;

    if (body is Map<String, dynamic>) {
      // will look ONLY at "status"/"success"/"ok" inside JSON
      return ApiResponse<T>.fromJson(body, fromJsonT);
    }

    if (body is List) {
      // Fallback: raw list → treat as success (no status/statusCode checks)
      final items =
          body.whereType<Map<String, dynamic>>().map(fromJsonT).toList();
      return ApiResponse<T>(success: true, data: items);
    }

    return ApiResponse<T>(
      success: false,
      data: [],
      error: 'Unexpected response type',
    );
  }
}
