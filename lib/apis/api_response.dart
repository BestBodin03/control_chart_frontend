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

  // success iff status == "success" (case-insensitive) or explicit success:true/ok:true
  static bool _isOk(dynamic statusOrFlag) {
    if (statusOrFlag is String) return statusOrFlag.toLowerCase() == 'success';
    if (statusOrFlag is bool) return statusOrFlag == true;
    return false;
  }

  // try to extract an error message from various shapes
  static String? _pickError(dynamic err, dynamic message) {
    if (err is String) return err;
    if (message is String) return message;

    if (err is Map) {
      final m = err as Map;
      final msg = m['message'] ?? m['error'] ?? m['detail'];
      if (msg is String) return msg;
    }
    return null;
  }

  /// Parse JSON into ApiResponse<List<T>>.
  /// - data as List -> map each item with fromJsonT
  /// - data as Map  -> treat as single item list
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final rawData = json['data'];
    List<T> items = const [];

    if (rawData is List) {
      items = rawData
          .whereType<Map<String, dynamic>>()
          .map(fromJsonT)
          .toList();
    } else if (rawData is Map<String, dynamic>) {
      // single object -> wrap into a list
      items = [fromJsonT(rawData)];
    }

    final success = _isOk(json['status']) ||
        _isOk(json['success']) ||
        _isOk(json['ok']);

    final error = _pickError(json['error'], json['message']);

    return ApiResponse<T>(
      success: success,
      data: items,
      error: error,
    );
  }

  /// Parse directly from Dio Response<dynamic>.
  static ApiResponse<T> fromResponse<T>(
    Response res,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final body = res.data;

    if (body is Map<String, dynamic>) {
      return ApiResponse<T>.fromJson(body, fromJsonT);
    }

    if (body is List) {
      final items =
          body.whereType<Map<String, dynamic>>().map(fromJsonT).toList();
      return ApiResponse<T>(success: true, data: items);
    }

    return ApiResponse<T>(
      success: false,
      data: const [],
      error: 'Unexpected response type',
    );
  }

  /// Quick helpers
  static ApiResponse<R> ok<R>(List<R> data) =>
      ApiResponse<R>(success: true, data: data);

  static ApiResponse<R> fail<R>(String message) =>
      ApiResponse<R>(success: false, data: const [], error: message);
}
