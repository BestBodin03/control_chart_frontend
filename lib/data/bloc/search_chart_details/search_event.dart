// search_event.dart
part of 'search_bloc.dart';

sealed class SearchEvent extends Equatable {
  const SearchEvent();
}

/// -------- Existing events (unchanged) --------

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
  List<Object?> get props => [startDate, endDate, furnaceNo, materialNo];
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
  List<Object?> get props => [startDate, endDate, furnaceNo, materialNo];
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

/// -------- NEW: dropdown-related events --------

/// Load dropdown options (optionally filtered by current selections).
/// If you pass nulls, bloc will use values from state.currentQuery.
final class LoadDropdownOptions extends SearchEvent {
  const LoadDropdownOptions({this.furnaceNo, this.materialNo});

  /// UI value for furnace (use "0" for All) or null to use currentQuery.
  final String? furnaceNo;

  /// UI value for material (use "All Material No." for All) or null to use currentQuery.
  final String? materialNo;

  @override
  List<Object?> get props => [furnaceNo, materialNo];
}

/// User selected a furnace from the dropdown.
/// UI should pass "0" to mean "All".
final class SelectFurnace extends SearchEvent {
  const SelectFurnace(this.furnaceNo);

  final String? furnaceNo;

  @override
  List<Object?> get props => [furnaceNo];
}

/// User selected a material from the dropdown.
/// UI should pass "All Material No." to mean "All".
final class SelectMaterial extends SearchEvent {
  const SelectMaterial(this.materialNo);

  final String? materialNo;

  @override
  List<Object?> get props => [materialNo];
}
