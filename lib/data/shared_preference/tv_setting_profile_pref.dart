// lib/core/prefs/tv_setting_profile_pref.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'tv_setting_profile_state.dart';

const kTvProfilePrefsKey = 'tvProfile.v1.prefs';

class TvSettingProfilePref {
  Future<TvSettingProfileState> load() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(kTvProfilePrefsKey);
    if (s == null) {
      return const TvSettingProfileEmpty();
    }

    try {
      final d = jsonDecode(s);
      if (d is Map<String, dynamic>) {
        return TvSettingProfileLoaded(d);
      }
      return const TvSettingProfileError("Invalid JSON format");
    } catch (e) {
      return TvSettingProfileError("Decode error: $e");
    }
  }

  Future<void> save(Map<String, dynamic> shape) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kTvProfilePrefsKey, jsonEncode(shape));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(kTvProfilePrefsKey);
  }
}
