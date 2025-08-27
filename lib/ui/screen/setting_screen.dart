import 'package:control_chart/apis/settings/setting_apis.dart';
import 'package:control_chart/data/bloc/setting_profile/setting_profile_bloc.dart';
import 'package:control_chart/data/cubit/setting_form/setting_form_cubit.dart';
import 'package:control_chart/ui/core/shared/gradient_background.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/setting_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  late final SettingApis _apis;

  @override
  void initState() {
    super.initState();
    _apis = SettingApis();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => SettingProfileBloc(settingApis: _apis)
            ..add(const LoadAllSettingProfiles()),
        ),
        BlocProvider(
          create: (_) => SettingFormCubit(_apis), // single source of truth
        ),
      ],
      child: const SettingContent(),
    );
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