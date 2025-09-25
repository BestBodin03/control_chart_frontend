// utils/app_route.dart
import 'package:flutter/foundation.dart';
import 'package:control_chart/ui/screen/screen_content/home_screen_content/home_content_var.dart';

class AppRoute {
  static final instance = AppRoute._();
  AppRoute._();

  // ใช้สลับแท็บเหมือนเดิม
  final ValueNotifier<int> navIndex = ValueNotifier<int>(0);

  // ✅ ช่องทางส่งค่า snapshot ข้ามหน้า (one-shot)
  final ValueNotifier<HomeContentVar?> searchSnapshot =
      ValueNotifier<HomeContentVar?>(null);
}
