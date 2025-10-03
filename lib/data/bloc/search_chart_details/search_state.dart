// search_state.dart
part of 'search_bloc.dart';

enum SearchStatus { initial, loading, success, failure }

final class SearchState extends Equatable {
  const SearchState({
    this.status = SearchStatus.initial,
    this.chartDetails = const [],
    this.searchTable = const [],
    this.controlChartStats,
    this.currentQuery = const ChartFilterQuery(),
    this.tvQuery = const TvQuery(),
    this.errorMessage,

    // ▼ NEW: dropdown state
    this.furnaceOptions = const ["0"],                   // "0" = All Furnaces (UI value)
    this.materialOptions = const ["All Material No."],   // "All Material No." = All (UI value)
    this.optionsLoading = false,
    this.optionsError,
  });

  final SearchStatus status;
  final List<ChartDetail> chartDetails;
  final List<SearchTable>? searchTable;
  final ControlChartStats? controlChartStats;
  final ChartFilterQuery currentQuery;
  final TvQuery tvQuery;
  final String? errorMessage;

  // ▼ NEW: dropdown state
  final List<String> furnaceOptions;
  final List<String> materialOptions;
  final bool optionsLoading;
  final String? optionsError;

  // Computed properties for convenience
  bool get isInitial => status == SearchStatus.initial;
  bool get isLoading => status == SearchStatus.loading;
  bool get isSuccess => status == SearchStatus.success;
  bool get hasError => status == SearchStatus.failure;
  bool get hasData => chartDetails.isNotEmpty;

  /// ▼ Convenience getters for binding UI values
  /// UI expects "0" for All furnaces and "All Material No." for All materials.
  String get currentFurnaceUiValue =>
      (currentQuery.furnaceNo == null || currentQuery.furnaceNo!.isEmpty)
          ? ""
          : currentQuery.furnaceNo!;

  String get currentMaterialUiValue =>
      (currentQuery.materialNo == null || currentQuery.materialNo!.isEmpty)
          ? ""
          : currentQuery.materialNo!;

  SearchState copyWith({
    SearchStatus Function()? status,
    List<ChartDetail> Function()? chartDetails,
    List<SearchTable> Function()? searchTable,
    ControlChartStats Function()? controlChartStats,
    ChartFilterQuery Function()? currentQuery,
    TvQuery Function()? tvQuery,
    String? Function()? errorMessage,

    // ▼ NEW: dropdown state
    List<String> Function()? furnaceOptions,
    List<String> Function()? materialOptions,
    bool Function()? optionsLoading,
    String? Function()? optionsError,
  }) {
    return SearchState(
      status: status != null ? status() : this.status,
      chartDetails: chartDetails != null ? chartDetails() : this.chartDetails,
      searchTable: searchTable != null ? searchTable() : this.searchTable,
      controlChartStats: controlChartStats != null ? controlChartStats() : this.controlChartStats,
      currentQuery: currentQuery != null ? currentQuery() : this.currentQuery,
      tvQuery: tvQuery != null ? tvQuery() : this.tvQuery,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,

      // ▼ NEW
      furnaceOptions: furnaceOptions != null ? furnaceOptions() : this.furnaceOptions,
      materialOptions: materialOptions != null ? materialOptions() : this.materialOptions,
      optionsLoading: optionsLoading != null ? optionsLoading() : this.optionsLoading,
      optionsError: optionsError != null ? optionsError() : this.optionsError,
    );
  }

  @override
  List<Object?> get props => [
        status,
        chartDetails,
        searchTable,
        controlChartStats,
        currentQuery,
        tvQuery,
        errorMessage,

        // ▼ NEW
        furnaceOptions,
        materialOptions,
        optionsLoading,
        optionsError,
      ];
}
