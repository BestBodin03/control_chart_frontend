import 'package:control_chart/domain/types/search_request.dart';

abstract class SettingEvent {}
class LoadChartDetailCount extends SettingEvent {}

class LoadAllFurnaces extends SettingEvent {}

class LoadAllMatNo extends SettingEvent {}

class LoadAllData extends SettingEvent {}

class SearchChartData extends SettingEvent {
  final SearchRequest request;
  SearchChartData(this.request);
}


class UpdatePeriod extends SettingEvent {
  final String period;
  UpdatePeriod(this.period);
}

class UpdateStartDate extends SettingEvent {
  final DateTime date;
  UpdateStartDate(this.date);
}

class UpdateEndDate extends SettingEvent {
  final DateTime date;
  UpdateEndDate(this.date);
}

class UpdateSelectedItem extends SettingEvent {
  final String item;
  UpdateSelectedItem(this.item);
}

class UpdateSelectedMatNo extends SettingEvent {
  final String matNo;
  UpdateSelectedMatNo(this.matNo);
}

class UpdateSelectedConditions extends SettingEvent {
  final List<String> conditions;
  UpdateSelectedConditions(this.conditions);
}

class UpdateLimitValue extends SettingEvent {
  final String value;
  UpdateLimitValue(this.value);
}

class SaveFormData extends SettingEvent {}
