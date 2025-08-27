import 'package:control_chart/data/cubit/setting_form/setting_form_state.dart';

class SettingRequest {
  final String settingProfileName;
  final bool isUsed;
  final DisplayTypeReq displayType;
  final int chartChangeInterval;
  final List<NelsonRuleReq> nelsonRule;
  final List<SpecificReq> specificSetting;

  SettingRequest({
    required this.settingProfileName,
    required this.isUsed,
    required this.displayType,
    required this.chartChangeInterval,
    required this.nelsonRule,
    required this.specificSetting,
  });

  Map<String, dynamic> toJson() => {
        "settingProfileName": settingProfileName,
        "isUsed": isUsed,
        "displayType": displayType.name, // "FURNACE" | "FURNACE_CP" | "CP"
        "generalSetting": {
          "chartChangeInterval": chartChangeInterval,
          "nelsonRule": nelsonRule.map((e) => e.toJson()).toList(),
        },
        "specificSetting": specificSetting.map((e) => e.toJson()).toList(),
      };
}

class NelsonRuleReq {
  final int ruleId;
  final String ruleName;
  final bool isUsed;

  NelsonRuleReq({
    required this.ruleId,
    required this.ruleName,
    required this.isUsed,
  });

  Map<String, dynamic> toJson() => {
        "ruleId": ruleId,
        "ruleName": ruleName,
        "isUsed": isUsed,
      };
}

class SpecificReq {
  final PeriodTypeReq type;
  final DateTime startDate; // Use UTC or convert in toJson()
  final DateTime endDate;   // Use UTC or convert in toJson()
  final int? furnaceNo;
  final String? cpNo;

  SpecificReq({
    required this.type,
    required this.startDate,
    required this.endDate,
    this.furnaceNo,
    this.cpNo,
  });

  Map<String, dynamic> toJson() => {
        "period": {
          "type": type.name, // e.g. "THREE_MONTHS"
          "startDate": startDate.toUtc().toIso8601String(),
          "endDate": endDate.toUtc().toIso8601String(),
        },
        "furnaceNo": furnaceNo,
        "cpNo": cpNo,
      };
}
