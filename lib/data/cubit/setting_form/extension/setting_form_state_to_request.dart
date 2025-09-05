// setting_form_state_mapper.dart
import 'package:control_chart/data/cubit/setting_form/setting_form_state.dart';
import 'package:control_chart/domain/models/setting.dart';
import 'package:control_chart/domain/models/setting_request.dart';

// Assumes these exist in your codebase:
// - class SettingFormState { ... }
// - class RuleSelected { int? ruleId; String? ruleName; bool? isUsed; }
// - class SpecificSetting { PeriodTypeReq? periodType; DateTime? startDate; DateTime? endDate; int? furnaceNo; String? cpNo; }

extension SettingFormStateToRequest on SettingFormState {
  /// Map SettingFormState -> SettingRequest
  /// Use ruleNameById to ensure each ruleId has a ruleName for the API payload.
  SettingRequest toRequest({
    Map<int, String>? ruleNameById,
  }) {
    // ---- Nelson rules (dedupe by ruleId, keep last) ----
    final Map<int, NelsonRuleReq> rulesById = {};
    for (final r in ruleSelected) {
      final id = r.ruleId;
      final used = r.isUsed;
      if (id == null || used == null) continue;
      final name = (r.ruleName?.trim().isNotEmpty ?? false)
          ? r.ruleName!.trim()
          : (ruleNameById?[id] ?? 'RULE_$id');
      rulesById[id] = NelsonRuleReq(ruleId: id, ruleName: name, isUsed: used);
    }
    final List<NelsonRuleReq> rules = rulesById.values.toList(growable: false);

    // ---- Specific settings ----
    final List<SpecificReq> specificsReq = specifics.map((sp) {
      final PeriodType type =
          sp.periodType ?? (throw StateError('specific.periodType is null'));
      DateTime start =
          sp.startDate ?? (throw StateError('specific.startDate is null'));
      DateTime end =
          sp.endDate ?? (throw StateError('specific.endDate is null'));

      // Normalize: swap if reversed
      if (start.isAfter(end)) {
        final tmp = start;
        start = end;
        end = tmp;
      }

      // Enforce fields based on displayType
      late final int? furnaceNoVal;
      late final String? cpNoVal;

      if (displayType == DisplayType.CP) {
        // furnaceNo not required by API for CP; send 0
        furnaceNoVal = null;
      } else {
        final f = sp.furnaceNo;
        if (f == null) {
          throw StateError('specific.furnaceNo is null for $displayType');
        }
        furnaceNoVal = f;
      }

      if (displayType == DisplayType.FURNACE) {
        // cpNo not required by API for FURNACE; send empty
        cpNoVal = null;
      } else {
        final c = (sp.cpNo);
        if (c!.isEmpty) {
          throw StateError('specific.cpNo is empty for $displayType');
        }
        cpNoVal = c;
      }

      return SpecificReq(
        type: type,
        startDate: start.toUtc(),
        endDate: end.toUtc(),
        furnaceNo: furnaceNoVal,
        cpNo: cpNoVal,
      );
    }).toList(growable: false);

    // ---- Final request ----
    return SettingRequest(
      settingProfileName: settingProfileName.trim(),
      isUsed: isUsed,
      displayType: displayType,
      chartChangeInterval: chartChangeInterval,
      nelsonRule: rules,
      specificSetting: specificsReq,
    );
  }
}
