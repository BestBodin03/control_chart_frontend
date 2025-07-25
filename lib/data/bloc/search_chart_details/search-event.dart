import 'package:control_chart/domain/types/chart_filter_query.dart';

abstract class SearchEvent {}

class SearchQueryChanged extends SearchEvent {
  final ChartFilterQuery query;
  SearchQueryChanged(this.query);
}

class SearchPeriodChanged extends SearchEvent {
  final String startDate;
  final String endDate;
  SearchPeriodChanged(this.startDate, this.endDate);
}

class SearchFurnaceNoChanged extends SearchEvent {
  final String furnaceNo;
  SearchFurnaceNoChanged(this.furnaceNo);
}

class SearchMatNoChanged extends SearchEvent {
  final String matNo;
  SearchMatNoChanged(this.matNo);
}

class SearchCleared extends SearchEvent {}