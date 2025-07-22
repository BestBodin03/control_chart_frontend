import 'package:control_chart/ui/core/shared/gradient_background.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/setting_content.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; // เพิ่ม import

class SettingScreen extends StatefulWidget { // เปลี่ยนเป็น StatefulWidget
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return SettingScreenBody();
  }
}

class SettingScreenBody extends StatelessWidget {
  const SettingScreenBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SettingContent(),
    );
  }
}