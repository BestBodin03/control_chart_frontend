import 'package:control_chart/domain/models/chart_detail.dart';
import 'package:control_chart/domain/types/chart_filter_query.dart';

abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<ChartDetail> chartDetails;
  final ChartFilterQuery currentQuery; // เพิ่มเพื่อให้ UI รู้ current filter

  SearchLoaded(this.chartDetails, this.currentQuery);
}

class SearchError extends SearchState {
  final String message;
  SearchError(this.message);
}



