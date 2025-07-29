
import 'package:control_chart/utils/date_autocomplete.dart';

abstract class SearchEvent {}

class LoadFilteredChartData extends SearchEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? furnaceNo;
  final String? materialNo;
  final int? page;
  final int? limit;

  LoadFilteredChartData({
    this.startDate,
    this.endDate,
    this.furnaceNo,
    this.materialNo,
    this.page,
    this.limit,
  });
}

class UpdateFurnaceNo extends SearchEvent {
  final String? furnaceNo;

  UpdateFurnaceNo(this.furnaceNo);
}

class UpdatePeriodStartDate extends SearchEvent {
  final DateTime? startDate;
  final String? startDateLabel;

  UpdatePeriodStartDate({
    this.startDate,
    this.startDateLabel
  });
}

class UpdatePeriodEndDate extends SearchEvent {
  final DateTime? endDate;
  final String? endDateLabel;

  UpdatePeriodEndDate({
    this.endDate,
    this.endDateLabel
  });
}

class UpdateMaterialNo extends SearchEvent {
  final String? materialNo;

  UpdateMaterialNo(this.materialNo);
}

class ClearFilters extends SearchEvent {}