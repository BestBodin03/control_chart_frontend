import 'package:control_chart/apis/settings/setting_apis.dart';
import 'package:control_chart/data/shared_preference/tv_setting_profile_pref.dart';
import 'package:control_chart/data/shared_preference/tv_setting_profile_state.dart';
import 'package:control_chart/domain/models/setting.dart';
import 'package:flutter/foundation.dart';

Future<TvSettingProfileState> bootstrap({
  required TvSettingProfilePref prefs,
  required SettingApis api,
}) async {
  // 1) มี cache แล้วก็ใช้เลย
  final cached = await prefs.load();
  if (cached is TvSettingProfileLoaded) return cached;

  // 2) ดึงจาก API
  final res = await api.getTvProfileSettings();
  if (res.success != true || res.data.isEmpty) {
    return TvSettingProfileError(res.error ?? 'No TV setting profile');
  }

  // 3) เลือกโปรไฟล์ที่เปิดใช้งาน ถ้าไม่มี ใช้ตัวแรก
  final List<Setting> settings = res.data;
  final Setting chosen =
      settings.firstWhere((s) => s.isUsed, orElse: () => settings.first);

  // 4) ดึงค่าจากโมเดล (ไม่แปลงเป็น Map)
  final general = chosen.generalSetting;
  final specifics = chosen.specificSetting;

  // เลือกเฉพาะ rule ที่ isUsed == true แล้วเก็บเป็น ["1","3",...]
  final List<Map<String, dynamic>> nelsonRule= general.nelsonRule
      .map((r) => {
            'ruleId': r.ruleId.toString(),
            'ruleName': r.ruleName,
            'isUsed': r.isUsed,
          })
      .toList();



  // สร้าง shape สำหรับเก็บลง SharedPreferences
  final shape = <String, dynamic>{
    'displayType': chosen.displayType.name, // FURNACE / FURNACE_CP / CP
    'chartChangeInterval': general.chartChangeInterval,
    'nelsonRule': nelsonRule,
    'SpecificSetting': specifics.map((sp) {
      final p = sp.period;
      final cp = sp.cpNo?.trim();
      return {
        'startDate': p?.startDate?.toIso8601String(),
        'endDate': p?.endDate?.toIso8601String(),
        'furnaceNo': sp.furnaceNo,
        'cpNo': (cp == null || cp.isEmpty) ? null : cp,
      };
    }).toList(),
  };

  // 5) เซฟลง SharedPreferences แล้วคืน Loaded
  await prefs.save(shape);
  debugPrint('In Bootstrap: $shape');
  return TvSettingProfileLoaded(shape);
}
