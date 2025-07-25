// data/bloc/setting/setting_event.dart
import 'package:control_chart/domain/types/chart_filter_query.dart';
import 'package:control_chart/domain/types/form_state.dart';

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