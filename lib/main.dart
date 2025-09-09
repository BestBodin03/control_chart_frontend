import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:control_chart/apis/settings/setting_apis.dart';
import 'package:control_chart/bootstrap.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/data/shared_preference/tv_setting_profile_pref.dart';
import 'package:control_chart/data/shared_preference/tv_setting_profile_state.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';

// POJO ของคุณ
import 'package:control_chart/ui/screen/screen_content/home_screen_content/home_content_var.dart';
// หน้าหลักที่มี HomeContent อยู่ข้างใน
import 'package:control_chart/ui/screen/home_screen.dart';
// หรือถ้าคุณจะเรียก HomeContent ตรง ๆ:
// import 'package:control_chart/ui/screen/screen_content/home_screen_content/home_content.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = TvSettingProfilePref();
  final api = SettingApis();

  // bootstrap -> ได้ prefs; ถ้าไม่มีจะโหลดจาก API แล้วเซฟ
  final state = await bootstrap(prefs: prefs, api: api);
  if (state is TvSettingProfileLoaded) {
    debugPrint('In Main\n${const JsonEncoder.withIndent('  ').convert(state.data)}');
  }

  // แปลง prefs -> POJO สำหรับจอแรก
  final initialParams = (state is TvSettingProfileLoaded)
      ? HomeContentVar.listFromPrefs(state.data)
      : const HomeContentVar();

  runApp(MyApp(initialParams: initialParams)); // <-- ส่งค่าเข้า MyApp
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    this.initialParams, 
    }); // <- รับค่าไว้
  final dynamic initialParams;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SearchBloc>(create: (_) => SearchBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.colorBgGrey,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.colorBgGrey,
            toolbarHeight: 64.0,
            systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
        ),
        home: MyHomeScreen(initialParams: initialParams), // <-- ส่งต่อให้ HomeScreen
      ),
    );
  }
}
