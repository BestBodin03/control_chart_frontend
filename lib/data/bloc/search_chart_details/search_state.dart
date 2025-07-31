// search_state.dart
part of 'search_bloc.dart';

enum SearchStatus { initial, loading, success, failure }

final class SearchState extends Equatable {
  const SearchState({
    this.status = SearchStatus.initial,
    this.chartDetails = const [],
    this.controlChartStats,
    this.currentQuery = const ChartFilterQuery(),
    this.errorMessage,
  });

  final SearchStatus status;
  final List<ChartDetail> chartDetails;
  final ControlChartStats? controlChartStats;
  final ChartFilterQuery currentQuery;
  final String? errorMessage;

  // Computed properties for convenience
  bool get isInitial => status == SearchStatus.initial;
  bool get isLoading => status == SearchStatus.loading;
  bool get isSuccess => status == SearchStatus.success;
  bool get hasError => status == SearchStatus.failure;
  bool get hasData => chartDetails.isNotEmpty;

  SearchState copyWith({
    SearchStatus Function()? status,
    List<ChartDetail> Function()? chartDetails,
    ControlChartStats Function()? controlChartStats,
    ChartFilterQuery Function()? currentQuery,
    String? Function()? errorMessage,
  }) {
    return SearchState(
      status: status != null ? status() : this.status,
      chartDetails: chartDetails != null ? chartDetails() : this.chartDetails,
      controlChartStats: controlChartStats != null ? controlChartStats() : this.controlChartStats,
      currentQuery: currentQuery != null ? currentQuery() : this.currentQuery,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    chartDetails,
    controlChartStats,
    currentQuery,
    errorMessage,
  ];
}



// import 'package:control_chart/domain/models/chart_detail.dart';
// import 'package:control_chart/domain/models/control_chart_stat.dart';
// import 'package:control_chart/domain/types/chart_filter_query.dart';

// abstract class SearchState {}

// class SearchInitial extends SearchState {}

// class SearchLoading extends SearchState {}

// class SearchLoaded extends SearchState {
//   final List<ChartDetail> chartDetails;
//   final List<ControlChartStat> controlChartStat;
//   final ChartFilterQuery currentQuery; // เพิ่มเพื่อให้ UI รู้ current filter

//   SearchLoaded(this.chartDetails, this.controlChartStat, this.currentQuery);
// }

// class SearchError extends SearchState {
//   final String message;
//   SearchError(this.message);
// }



