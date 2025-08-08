
import 'package:control_chart/apis/settings/setting_apis.dart';
import 'package:control_chart/ui/core/shared/gradient_background.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/setting_content.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    // return RepositoryProvider<SettingApis>(
    //   create: (context) => SettingApis(),
    //   child: SettingScreenBody(),
    // );
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