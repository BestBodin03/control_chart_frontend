// file: home_content_var.dart
import 'package:flutter/foundation.dart';

class HomeContentVar {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? furnaceNo;
  final String? materialNo; // cpNo
  final String? displayType;
  final int interval;
  final List<NelsonRuleVar> nelsonRule;

  const HomeContentVar({
    this.startDate,
    this.endDate,
    this.furnaceNo,
    this.materialNo,
    this.displayType,
    this.interval = 10,
    this.nelsonRule = const [],
  });

  HomeContentVar copyWith({
    DateTime? startDate,
    DateTime? endDate,
    String? furnaceNo,
    String? materialNo,
    String? displayType,
    int? interval,
    List<NelsonRuleVar>? nelsonRule,
  }) {
    return HomeContentVar(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      furnaceNo: furnaceNo ?? this.furnaceNo,
      materialNo: materialNo ?? this.materialNo,
      displayType: displayType ?? this.displayType,
      interval: interval ?? this.interval,
      nelsonRule: nelsonRule ?? this.nelsonRule,
    );
  }

  // ---------- Helpers ----------
  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString().trim());
  }

  static DateTime? _parseDT(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  static List<NelsonRuleVar> _parseNelsonRules(Map<String, dynamic> p) {
    List<dynamic>? raw() {
      final gen = p['generalSetting'];
      if (gen is Map && gen['nelsonRule'] is List) return gen['nelsonRule'] as List;
      if (p['nelsonRule'] is List) return p['nelsonRule'] as List;
      return null;
    }

    final list = raw() ?? const [];
    final out = <NelsonRuleVar>[];
    for (final e in list) {
      if (e is Map) {
        out.add(NelsonRuleVar(
          id: _asInt(e['ruleId'] ?? e['id']),
          name: e['ruleName']?.toString(),
          isUsed: e['isUsed'] == true ||
              (e['isUsed'] is String && (e['isUsed'] as String).toLowerCase() == 'true'),
        ));
      } else {
        // id ล้วน
        out.add(NelsonRuleVar(id: _asInt(e), name: null, isUsed: true));
      }
    }
    return out;
  }

  // ---------- Factory: สร้าง "รายการ" สำหรับ Carousel ----------
  /// แตก 1 HomeContentVar ต่อ 1 SpecificSetting
  static List<HomeContentVar> listFromPrefs(Map<String, dynamic> p) {
    final displayType = p['displayType']?.toString();
    final interval = () {
      final v = p['chartChangeInterval'];
      if (v is num) return v.toInt();
      return int.tryParse('${v ?? ''}') ?? 10;
    }();

    final rules = _parseNelsonRules(p);

    final specs = (p['SpecificSetting'] as List?) ?? const [];
    final items = <HomeContentVar>[];

    for (final s in specs) {
      if (s is! Map) continue;
      final start = _parseDT(s['startDate']);
      final end = _parseDT(s['endDate']);
      final fn = s['furnaceNo']?.toString();
      final cp = s['cpNo']?.toString();

      items.add(HomeContentVar(
        startDate: start,
        endDate: end,
        furnaceNo: fn,
        materialNo: (cp == null || cp.trim().isEmpty) ? null : cp.trim(),
        displayType: displayType,
        interval: interval,
        nelsonRule: rules,
      ));
    }

    // debug
    for (var i = 0; i < items.length; i++) {
      debugPrint('Carousel item #$i -> ${items[i]}');
    }
    return items;
  }

  @override
  String toString() {
    return '''
HomeContentVar(
  startDate  : $startDate,
  endDate    : $endDate,
  furnaceNo  : $furnaceNo,
  materialNo : $materialNo,
  displayType: $displayType,
  interval   : $interval,
  nelsonRule : $nelsonRule
)''';
  }

  // static fromPrefs(Map<String, dynamic> data) {}
}

class NelsonRuleVar {
  final int? id;
  final String? name;
  final bool isUsed;

  const NelsonRuleVar({
    this.id,
    this.name,
    this.isUsed = false,
  });

  Map<String, dynamic> toJson() => {
        'ruleId': id?.toString(),
        'ruleName': name,
        'isUsed': isUsed,
      };

  @override
  String toString() => '{id: $id, name: $name, isUsed: $isUsed}';
}
