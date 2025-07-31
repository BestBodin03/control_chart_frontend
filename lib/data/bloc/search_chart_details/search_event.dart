// search_event.dart
part of 'search_bloc.dart';

sealed class SearchEvent extends Equatable {
  const SearchEvent();
}

final class LoadFilteredChartData extends SearchEvent {
  const LoadFilteredChartData({
    this.startDate,
    this.endDate,
    this.furnaceNo,
    this.materialNo,
    this.page,
    this.limit,
  });

  final DateTime? startDate;
  final DateTime? endDate;
  final String? furnaceNo;
  final String? materialNo;
  final int? page;
  final int? limit;

  @override
  List<Object?> get props => [
    startDate,
    endDate,
    furnaceNo,
    materialNo,
    page,
    limit,
  ];
}

final class UpdateFurnaceNo extends SearchEvent {
  const UpdateFurnaceNo(this.furnaceNo);

  final String? furnaceNo;

  @override
  List<Object?> get props => [furnaceNo];
}

final class UpdatePeriodStartDate extends SearchEvent {
  const UpdatePeriodStartDate({
    this.startDate,
    this.startDateLabel,
  });

  final DateTime? startDate;
  final String? startDateLabel;

  @override
  List<Object?> get props => [startDate, startDateLabel];
}

final class UpdatePeriodEndDate extends SearchEvent {
  const UpdatePeriodEndDate({
    this.endDate,
    this.endDateLabel,
  });

  final DateTime? endDate;
  final String? endDateLabel;

  @override
  List<Object?> get props => [endDate, endDateLabel];
}

final class UpdateMaterialNo extends SearchEvent {
  const UpdateMaterialNo(this.materialNo);

  final String? materialNo;

  @override
  List<Object?> get props => [materialNo];
}

final class ClearFilters extends SearchEvent {
  const ClearFilters();

  @override
  List<Object> get props => [];
}

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


// import 'package:control_chart/utils/date_autocomplete.dart';

// abstract class SearchEvent {}

// class LoadFilteredChartData extends SearchEvent {
//   final DateTime? startDate;
//   final DateTime? endDate;
//   final String? furnaceNo;
//   final String? materialNo;
//   final int? page;
//   final int? limit;

//   LoadFilteredChartData({
//     this.startDate,
//     this.endDate,
//     this.furnaceNo,
//     this.materialNo,
//     this.page,
//     this.limit,
//   });
// }

// class UpdateFurnaceNo extends SearchEvent {
//   final String? furnaceNo;

//   UpdateFurnaceNo(this.furnaceNo);
// }

// class UpdatePeriodStartDate extends SearchEvent {
//   final DateTime? startDate;
//   final String? startDateLabel;

//   UpdatePeriodStartDate({
//     this.startDate,
//     this.startDateLabel
//   });
// }

// class UpdatePeriodEndDate extends SearchEvent {
//   final DateTime? endDate;
//   final String? endDateLabel;

//   UpdatePeriodEndDate({
//     this.endDate,
//     this.endDateLabel
//   });
// }

// class UpdateMaterialNo extends SearchEvent {
//   final String? materialNo;

//   UpdateMaterialNo(this.materialNo);

// }

// class ClearFilters extends SearchEvent {}

// class UpdateDateRange extends SearchEvent {
//   final DateTime startDate;
//   final DateTime endDate;

//   UpdateDateRange({
//     required this.startDate,
//     required this.endDate,
//   });
// }