// search_event.dart
part of 'search_bloc.dart';

sealed class SearchEvent extends Equatable {
  const SearchEvent();
}

final class LoadTvChartData extends SearchEvent {
  const LoadTvChartData({
    this.startDate,
    this.endDate,
    this.furnaceNo,
    this.materialNo,
  });

  final DateTime? startDate;
  final DateTime? endDate;
  final String? furnaceNo;
  final String? materialNo;

  @override
  List<Object?> get props => [
    startDate,
    endDate,
    furnaceNo,
    materialNo,
  ];
}

final class LoadFilteredChartData extends SearchEvent {
  const LoadFilteredChartData({
    this.startDate,
    this.endDate,
    this.furnaceNo,
    this.materialNo,
  });

  final DateTime? startDate;
  final DateTime? endDate;
  final String? furnaceNo;
  final String? materialNo;

  @override
  List<Object?> get props => [
    startDate,
    endDate,
    furnaceNo,
    materialNo,
  ];
}

final class ClearFilters extends LoadFilteredChartData {}

final class UpdateDateRange extends SearchEvent {
  const UpdateDateRange({
    required this.startDate,
    required this.endDate,
  });

  final DateTime startDate;
  final DateTime endDate;

  @override
  List<Object> get props => [startDate, endDate];
}