import 'package:control_chart/domain/models/chart_detail.dart';
import 'package:control_chart/domain/types/chart_filter_query.dart';

abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {
  final List<ChartDetail> previousResults;
  SearchLoading({this.previousResults = const []});
}

class SearchSuccess extends SearchState {
  final List<ChartDetail> filterdChartDetails;
  final ChartFilterQuery query;
  
  SearchSuccess({
    required this.filterdChartDetails,
    required this.query,
  });
}

class SearchError extends SearchState {
  final String message;
  final List<ChartDetail> previousResults;
  
  SearchError({
    required this.message,
    this.previousResults = const [],
  });
}