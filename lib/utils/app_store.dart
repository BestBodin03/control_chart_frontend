// app_store.dart the port between main class and others to prevent reload App for new shared pref
import 'package:flutter/foundation.dart';
import 'package:control_chart/ui/screen/screen_content/home_screen_content/home_content_var.dart';

class AppStore {
  AppStore._();
  static final instance = AppStore._();

  final ValueNotifier<List<HomeContentVar>> homeProfiles =
      ValueNotifier<List<HomeContentVar>>(<HomeContentVar>[]);
}


