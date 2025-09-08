import 'dart:convert';
import 'package:control_chart/apis/settings/setting_apis.dart';
import 'package:control_chart/data/shared_preference/tv_setting_profile_pref.dart';
import 'package:control_chart/data/shared_preference/tv_setting_profile_state.dart';
import 'package:flutter/foundation.dart';

Future<TvSettingProfileState> bootstrap({
  required TvSettingProfilePref prefs,
  required SettingApis api,
}) async {
  // 1) ถ้ามีพรีเฟอเรนซ์อยู่แล้ว ใช้เลย
  final cached = await prefs.load();
  if (cached is TvSettingProfileLoaded) return cached;

  // 2) ไม่มี → ดึงจาก API
  final res = await api.getTvProfileSettings();
  if (res.success != true || res.data.isEmpty) {
    return TvSettingProfileError(res.error ?? 'No TV setting profile');
  }

  // 3) เลือกโปรไฟล์ที่ isUsed == true ถ้าไม่มีใช้ตัวแรก
  dynamic chosen = res.data.first;
  for (final it in res.data) {
    try {
      final m = (it).generalSetting.nelsonRule.;
      if (m['isUsed'] == true) { chosen = it; break; }
    } catch (_) {}
  }
  final m = (chosen);

  // 4) Normalize: API → prefs shape ที่ HomeContentVar.fromPrefs ใช้ได้
  String? _normFurnace(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toInt() == 0 ? null : v.toInt().toString();
    final s = v.toString().trim();
    return (s.isEmpty || s == '0') ? null : s;
  }

  final general = (m['generalSetting'] as Map?) ?? const {};
  final specifics = (m['specificSetting'] as List?) ?? const [];
  final List<String> nelsonRuleIds = ((general['nelsonRule'] as List?) ?? const [])
    .whereType<Map>()                              // เอาเฉพาะ Map
    .where((m) => m['isUsed'] == true)             // ใช้งานจริงเท่านั้น
    .map((m) => (m['ruleId'])?.toString())   // แปลงเป็น int -> String
    .whereType<String>()                           // ตัด null
    .toList();


  final shape = <String, dynamic>{
    'displayType': m['displayType']?.toString(),
    'chartChangeInterval': (general['chartChangeInterval'] is num)
        ? (general['chartChangeInterval'] as num).toInt()
        : int.tryParse('${general['chartChangeInterval'] ?? ''}') ?? 10,
  'nelsonRule': (general['nelsonRule'])
      .whereType<Map>()
      .map((m) => {
            'ruleId'  : (m['ruleId'] is num)
                ? (m['ruleId'] as num).toInt()
                : int.tryParse('${m['ruleId']}'),
            'ruleName': m['ruleName']?.toString(),
            'isUsed'  : (m['isUsed']),
          })
      .toList(),
  'nelsonRuleId': extractNelsonRuleIds(general), 
    'SpecificSetting': specifics.whereType<Map>().map((sp) {
      final period = (sp['period'] as Map?) ?? const {};
      final cp = sp['cpNo']?.toString().trim();
      return {
        'startDate': period['startDate']?.toString(),
        'endDate'  : period['endDate']?.toString(),
        'furnaceNo': _normFurnace(sp['furnaceNo']),
        'cpNo'     : (cp == null || cp.isEmpty) ? null : cp,
      };
    }).toList(),
  };

  // 5) เซฟลง SharedPreferences แล้วคืน Loaded
  await prefs.save(shape);
  debugPrint('In Bootstrap: $shape');
  return TvSettingProfileLoaded(shape);
}

// GUARANTEED extractor: returns ["1","3",...]
List<String> extractNelsonRuleIds(dynamic generalSetting) {
  final general = (generalSetting);
  final rules = (general['nelsonRule']);

  final ids = <String>[];
  for (final r in rules) {
    if (r is! Map) continue;
    if (!(r['isUsed'])) continue;
    final id = r['ruleId'];
    if (id == null) continue;

    // normalize to string of an integer
    if (id is num) {
      ids.add(id.toInt().toString());
    } else {
      final s = id.toString().trim();
      final n = int.tryParse(s);
      if (n != null) ids.add(n.toString());
    }
  }
  return ids;
}
