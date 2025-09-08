class HomeContentVar {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? furnaceNo;
  final String? materialNo; // cpNo
  final String? displayType;
  final int interval;
  final List<String> ruleIds;

  const HomeContentVar({
    this.startDate,
    this.endDate,
    this.furnaceNo,
    this.materialNo,
    this.displayType,
    this.interval = 10,
    this.ruleIds = const [],
  });

  HomeContentVar copyWith({
    DateTime? startDate,
    DateTime? endDate,
    String? furnaceNo,
    String? materialNo,
    String? displayType,
    int? interval,
    List<String>? ruleIds,
  }) {
    return HomeContentVar(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      furnaceNo: furnaceNo ?? this.furnaceNo,
      materialNo: materialNo ?? this.materialNo,
      displayType: displayType ?? this.displayType,
      interval: interval ?? this.interval,
      ruleIds: ruleIds ?? this.ruleIds,
    );
  }

factory HomeContentVar.fromPrefs(Map<String, dynamic> p) {
  int? asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString().trim());
  }

  DateTime? _parseDT(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  final specs = (p['SpecificSetting'] as List?) ?? const [];
  Map? first = (specs.isNotEmpty && specs.first is Map) ? specs.first as Map : null;

  // ---- Parse rules ให้ ruleId เป็น int? เสมอ ----
  List<Map<String, dynamic>> parsedRules = [];

  if (p['nelsonRule'] is List) {
    parsedRules = (p['nelsonRule'] as List)
        .whereType<Map>()
        .map((m) => {
              'ruleId'  : asInt(m['ruleId']),                 // << สำคัญ
              // 'ruleName': m['ruleName']?.toString(),
              'isUsed'  : m['isUsed'] == true,
            })
        .toList();
  } else if (p['generalSetting'] is Map &&
             (p['generalSetting']['nelsonRule'] is List)) {
    parsedRules = (p['generalSetting']['nelsonRule'] as List)
        .whereType<Map>()
        .map((m) => {
              'ruleId': asInt(m['ruleId']),               // << สำคัญ
              'ruleName': m['ruleName']?.toString(),
              'isUsed'  : m['isUsed'] == true,
            })
        .toList();
  } else if (p['nelsonRuleId'] is List) {
    // fallback: มีแค่ id → สร้าง map โดยบังคับ int
    parsedRules = (p['nelsonRuleId'] as List)
        .map((id) => {
              'ruleId'  : asInt(id),                          // << สำคัญ
              'ruleName': null,
              'isUsed'  : true,
            })
        .toList();
  }

  final derivedRuleIds = parsedRules
      .where((r) => r['isUsed'] == true)
      .map((r) => r['ruleId']?.toString())
      .whereType<String>()
      .toList();

  return HomeContentVar(
    startDate  : _parseDT(first?['startDate']),
    endDate    : _parseDT(first?['endDate']),
    furnaceNo  : first?['furnaceNo']?.toString(),
    materialNo : first?['cpNo']?.toString(),
    displayType: p['displayType']?.toString(),
    interval   : (() {
      final v = p['chartChangeInterval'];
      if (v is num) return v.toInt();
      return int.tryParse('$v') ?? 10;
    })(),  // ตอนนี้ ruleId เป็น int? แล้ว
    ruleIds: derivedRuleIds,  // เป็น String[] ตามเดิม
  );
}
}
