import 'dart:async';

import 'package:control_chart/apis/api_response.dart';
import 'package:control_chart/config/api_config.dart';
import 'package:dio/dio.dart';

class ImportDataApis {
  final ApiConfig _api;
  ImportDataApis({ApiConfig? api}) : _api = api ?? ApiConfig();

  /// เริ่มกระบวนการ import (bulk call)
  Future<ApiResponse<Map<String, dynamic>>> process() async {
    print('CALL CURRENT DATA');
    try {
      // debugPrint('CALL CURRENT DATA');
      final Response res = await _api.get('/current-chart-details/process');

      if (res.statusCode == 200) {
        // เซิร์ฟเวอร์ส่ง { status, data: { ...progress } }
        final body = res.data as Map<String, dynamic>? ?? {};
        final data = body['data'] as Map<String, dynamic>? ?? {};
        return ApiResponse<Map<String, dynamic>>(success: true, data: [data]);
      }
      return ApiResponse.fail<Map<String, dynamic>>('ไม่สามารถเริ่มการประมวลผลได้ (รหัส ${res.statusCode})');
    } on DioException catch (e) {
      return ApiResponse.fail<Map<String, dynamic>>(_mapDioError(e));
    } catch (e) {
      return ApiResponse.fail<Map<String, dynamic>>('เกิดข้อผิดพลาดที่ไม่คาดคิด: $e');
    }
  }


 Future<ApiResponse<Map<String, dynamic>>> addNewMaterial(String matcp) async {
    try {
      final Response res = await _api.post(
        '/master/process-master-data',
        {'MATCP': matcp},
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = (res.data is Map<String, dynamic>) ? res.data as Map<String, dynamic> : <String, dynamic>{};
        return ApiResponse<Map<String, dynamic>>(success: true, data: [data]);
      }
      return ApiResponse.fail<Map<String, dynamic>>('ส่งข้อมูลไม่สำเร็จ (รหัส ${res.statusCode})');
    } on DioException catch (e) {
      // ใช้ตัว map error เดิมของคุณถ้ามี
      final msg = e.message ?? 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้';
      return ApiResponse.fail<Map<String, dynamic>>(msg);
    } catch (e) {
      return ApiResponse.fail<Map<String, dynamic>>('เกิดข้อผิดพลาด: $e');
    }
  }

  /// ดึงความคืบหน้าปัจจุบัน
  Future<ApiResponse<Map<String, dynamic>>> progress() async {
    try {
      final Response res = await _api.get('/current-chart-details/progress');

      if (res.statusCode == 200) {
        final body = res.data as Map<String, dynamic>? ?? {};
        final data = body['data'] as Map<String, dynamic>? ?? {};
        return ApiResponse<Map<String, dynamic>>(success: true, data: [data]);
      }
      return ApiResponse.fail<Map<String, dynamic>>('ไม่สามารถดึงความคืบหน้าได้ (รหัส ${res.statusCode})');
    } on DioException catch (e) {
      return ApiResponse.fail<Map<String, dynamic>>(_mapDioError(e));
    } catch (e) {
      return ApiResponse.fail<Map<String, dynamic>>('เกิดข้อผิดพลาดที่ไม่คาดคิด: $e');
    }
  }


  

  /// สร้าง Stream สำหรับ polling เปอร์เซ็นต์ (สำหรับ ProgressBar)
  /// จะ complete เองเมื่อ status เป็น done/error/cancelled
  Stream<int> pollProgress({Duration interval = const Duration(seconds: 1)}) async* {
    final controller = StreamController<int>();
    Timer? timer;

    Future<void> tick() async {
      final resp = await progress();
      if (!resp.success || resp.data.isEmpty) {
        controller.addError(resp.error ?? 'ดึงความคืบหน้าไม่ได้');
        return;
      }
      final m = resp.data.first;
      final percent = (m['percent'] ?? 0) as int;
      final status = (m['status'] ?? 'idle') as String;

      controller.add(percent);

      if (status == 'done' || status == 'error' || status == 'cancelled') {
        timer?.cancel();
        await controller.close();
      }
    }

    // start interval
    timer = Timer.periodic(interval, (_) => tick());
    // fire immediately
    unawaited(tick());

    yield* controller.stream;
  }

  String _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
      return 'การเชื่อมต่อล้มเหลว กรุณาลองใหม่';
    }
    if (e.type == DioExceptionType.badResponse) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        return (data['error'] ?? data['message'] ?? 'เซิร์ฟเวอร์ไม่ตอบสนอง').toString();
      }
      return 'เซิร์ฟเวอร์ไม่ตอบสนอง กรุณาลองใหม่ภายหลัง';
    }
    if (e.type == DioExceptionType.cancel) {
      return 'การร้องขอถูกยกเลิก';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'ไม่สามารถเชื่อมต่อเครือข่ายได้';
    }
    return 'เกิดข้อผิดพลาด: ${e.message}';
  }
}