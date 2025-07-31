// setting_event.dart
part of 'setting_bloc.dart';

sealed class SettingEvent extends Equatable {
  const SettingEvent();
}

// Data Loading Events
final class LoadChartDetailCount extends SettingEvent {
  const LoadChartDetailCount();

  @override
  List<Object> get props => [];
}

final class LoadAllFurnaces extends SettingEvent {
  const LoadAllFurnaces();

  @override
  List<Object> get props => [];
}

final class LoadAllMatNo extends SettingEvent {
  const LoadAllMatNo();

  @override
  List<Object> get props => [];
}

final class LoadAllData extends SettingEvent {
  const LoadAllData();

  @override
  List<Object> get props => [];
}

// Form Events
final class InitializeForm extends SettingEvent {
  const InitializeForm();

  @override
  List<Object> get props => [];
}

final class SaveFormData extends SettingEvent {
  const SaveFormData();

  @override
  List<Object> get props => [];
}

// Search Events
final class FilterChartDetailLoading extends SettingEvent {
  const FilterChartDetailLoading();

  @override
  List<Object> get props => [];
}

// Form Update Events
final class UpdatePeriodS extends SettingEvent {
  const UpdatePeriodS(this.period);

  final String period;

  @override
  List<Object> get props => [period];
}

final class UpdateStartDate extends SettingEvent {
  const UpdateStartDate({
    required this.startDate,
  });

  final DateTime startDate;

  @override
  List<Object> get props => [startDate];
}

final class UpdateEndDate extends SettingEvent {
  const UpdateEndDate({
    required this.endDate,
  });

  final DateTime endDate;

  @override
  List<Object> get props => [endDate];
}