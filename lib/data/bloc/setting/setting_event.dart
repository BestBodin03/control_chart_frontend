// data/bloc/setting/setting_event.dart
import 'package:control_chart/domain/types/chart_filter_query.dart';
import 'package:control_chart/domain/types/form_state.dart';
import 'package:control_chart/utils/date_autocomplete.dart';

abstract class SettingEvent {}

class LoadChartDetailCount extends SettingEvent {}
class LoadAllFurnaces extends SettingEvent {}
class LoadAllMatNo extends SettingEvent {}
class LoadAllData extends SettingEvent {}


// Form Events
class InitializeForm extends SettingEvent {}
class SaveFormData extends SettingEvent {}

//
class FilterChartDetailLoading extends SettingEvent {}

class UpdatePeriodS extends SettingEvent {
  final String period;
  UpdatePeriodS(this.period);
}

class UpdateStartDate extends SettingEvent {
  final DateTime startDate;
  
  UpdateStartDate({required this.startDate});
}

class UpdateEndDate extends SettingEvent {
  final DateTime endDate;
  UpdateEndDate({required this.endDate});
}