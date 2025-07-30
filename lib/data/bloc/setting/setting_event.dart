// data/bloc/setting/setting_event.dart
import 'package:control_chart/domain/types/chart_filter_query.dart';
import 'package:control_chart/domain/types/form_state.dart';
import 'package:control_chart/utils/date_autocomplete.dart';
import 'package:flutter/src/widgets/framework.dart';

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
  // final String startDateLabel;
  final DateTime startDate;
  
  UpdateStartDate({
    required this.startDate,
    // required this.startDateLabel
    });
}

class UpdateEndDate extends SettingEvent {
  final DateTime endDate;
  // final String endDateLabel;
  UpdateEndDate({
    required this.endDate,
    // required this.endDateLabel
    });
}