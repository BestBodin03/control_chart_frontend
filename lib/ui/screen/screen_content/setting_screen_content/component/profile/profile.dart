import 'package:control_chart/data/cubit/setting_form/setting_form_state.dart';
import 'package:control_chart/domain/models/setting.dart';

class Profile {
  final String id;
  final String name;
  final String displayType;
  final DateTime createdAt;
  final bool active;
  final DisplayType? profileDisplayType;
  final int? chartChangeInterval;
  final List<RuleSelected>? ruleSelected;
  final List<SpecificSettingState>? specifics;
  final SubmitStatus? status;
  final String? error;

  const Profile({
    required this.id,
    required this.name,
    required this.displayType,
    required this.createdAt,
    required this.active,
     this.profileDisplayType,
     this.chartChangeInterval,
     this.ruleSelected,
     this.specifics,
     this.status,
    this.error,
  });

  @override
  String toString() {
    return 'Profile('
        'id: $id, '
        'name: $name, '
        'displayType: $displayType, '
        'createdAt: $createdAt, '
        'active: $active, '
        'profileDisplayType: $profileDisplayType, '
        'chartChangeInterval: $chartChangeInterval, '
        'ruleSelected: $ruleSelected, '
        'specifics: $specifics, '
        'status: $status, '
        'error: $error'
        ')';
  }
}
