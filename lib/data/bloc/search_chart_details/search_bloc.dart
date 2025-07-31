// search_bloc.dart
import 'package:control_chart/apis/search_chart_details/search_chart_details_apis.dart';
import 'package:control_chart/domain/models/chart_detail.dart';
import 'package:control_chart/domain/models/control_chart_stats.dart';
import 'package:control_chart/domain/types/chart_filter_query.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchChartDetailsApis _searchApiService;

  SearchBloc({
    SearchChartDetailsApis? searchApiService,
  }) : _searchApiService = searchApiService ?? SearchChartDetailsApis(),
       super(const SearchState()) {
    
    on<LoadFilteredChartData>(_onLoadFilteredChartData);
    on<UpdateFurnaceNo>(_onUpdateFurnaceNo);
    on<UpdatePeriodStartDate>(_onUpdatePeriodStartDate);
    on<UpdatePeriodEndDate>(_onUpdatePeriodEndDate);
    on<UpdateMaterialNo>(_onUpdateMaterialNo);
    on<ClearFilters>(_onClearFilters);
    on<UpdateDateRange>(_onUpdateDateRange);
  }

  Future<void> _onLoadFilteredChartData(
    LoadFilteredChartData event,
    Emitter<SearchState> emit,
  ) async {
    emit(state.copyWith(status: () => SearchStatus.loading));

    try {
      final newQuery = ChartFilterQuery(
        startDate: event.startDate,
        endDate: event.endDate,
        furnaceNo: event.furnaceNo,
        materialNo: event.materialNo,
        page: event.page ?? 1,
        limit: event.limit ?? 50,
      );

      final results = await Future.wait([
        _searchApiService.getFilteringChartDetails(newQuery),
        _searchApiService.getControlChartStat(newQuery),
      ]);

      final chartDetails = results[0] as List<ChartDetail>;
      final chartStatistics = results[1] as ControlChartStats;

      emit(state.copyWith(
        status: () => SearchStatus.success,
        chartDetails: () => chartDetails,
        controlChartStats: () => chartStatistics,
        currentQuery: () => newQuery,
        errorMessage: () => null, // Clear any previous errors
      ));
    } catch (e) {
      emit(state.copyWith(
        status: () => SearchStatus.failure,
        errorMessage: () => e.toString(),
      ));
    }
  }

  Future<void> _onUpdateFurnaceNo(
    UpdateFurnaceNo event,
    Emitter<SearchState> emit,
  ) async {
    print('🔄 Updating furnace no: ${event.furnaceNo}');
    
    await _updateQueryAndFetch(
      emit,
      state.currentQuery.copyWith(
        furnaceNo: event.furnaceNo,
        page: 1, // Reset to first page
      ),
    );
  }

  Future<void> _onUpdatePeriodStartDate(
    UpdatePeriodStartDate event,
    Emitter<SearchState> emit,
  ) async {
    print('🔄 Updating start date: ${event.startDate}');
    
    await _updateQueryAndFetch(
      emit,
      state.currentQuery.copyWith(
        startDate: event.startDate,
        page: 1,
      ),
    );
  }

  Future<void> _onUpdatePeriodEndDate(
    UpdatePeriodEndDate event,
    Emitter<SearchState> emit,
  ) async {
    print('🔄 Updating end date: ${event.endDate}');
    
    await _updateQueryAndFetch(
      emit,
      state.currentQuery.copyWith(
        endDate: event.endDate,
        page: 1,
      ),
    );
  }

  Future<void> _onUpdateMaterialNo(
    UpdateMaterialNo event,
    Emitter<SearchState> emit,
  ) async {
    print('🔄 Updating material no: ${event.materialNo}');
    
    await _updateQueryAndFetch(
      emit,
      state.currentQuery.copyWith(
        materialNo: event.materialNo,
        page: 1,
      ),
    );
  }

  Future<void> _onClearFilters(
    ClearFilters event,
    Emitter<SearchState> emit,
  ) async {
    print('🔄 Clearing all filters');
    
    await _updateQueryAndFetch(
      emit,
      const ChartFilterQuery(page: 1, limit: 50),
    );
  }

  Future<void> _onUpdateDateRange(
    UpdateDateRange event,
    Emitter<SearchState> emit,
  ) async {
    print('🔄 SearchBloc received UpdateDateRange');
    print('Start: ${event.startDate}');
    print('End: ${event.endDate}');
    
    await _updateQueryAndFetch(
      emit,
      state.currentQuery.copyWith(
        startDate: event.startDate,
        endDate: event.endDate,
        page: 1,
      ),
    );
  }

  // 🔥 Helper method to reduce code duplication
  Future<void> _updateQueryAndFetch(
    Emitter<SearchState> emit,
    ChartFilterQuery newQuery,
  ) async {
    // Keep existing data while loading (smooth UX)
    emit(state.copyWith(status: () => SearchStatus.loading));

    try {
      print('📋 Updated query: $newQuery');
      print('Query params: ${newQuery.toQueryParams()}');

      final results = await Future.wait([
        _searchApiService.getFilteringChartDetails(newQuery),
        _searchApiService.getControlChartStat(newQuery),
      ]);

      final chartDetails = results[0] as List<ChartDetail>;
      final chartStatistics = results[1] as ControlChartStats;

      print('✅ API call successful, emitting success state $chartStatistics');
      
      emit(state.copyWith(
        status: () => SearchStatus.success,
        chartDetails: () => chartDetails,
        controlChartStats: () => chartStatistics,
        currentQuery: () => newQuery,
        errorMessage: () => null,
      ));
    } catch (e) {
      print('❌ API call failed: $e');
      
      emit(state.copyWith(
        status: () => SearchStatus.failure,
        errorMessage: () => e.toString(),
        currentQuery: () => newQuery, // Keep new query even on error
      ));
    }
  }
}


// import 'package:control_chart/apis/search_chart_details/search_chart_details_apis.dart';
// import 'package:control_chart/data/bloc/search_chart_details/search_event.dart';
// import 'package:control_chart/data/bloc/search_chart_details/search_state.dart';
// import 'package:control_chart/domain/models/control_chart_stat.dart';
// import 'package:control_chart/domain/types/chart_filter_query.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class SearchBloc extends Bloc<SearchEvent, SearchState> {
//   final SearchChartDetailsApis _searchApiService = SearchChartDetailsApis();
  
//   // เก็บ current filter state
//   ChartFilterQuery _currentQuery = const ChartFilterQuery();

//   SearchBloc() : super(SearchInitial()) {
//     on<LoadFilteredChartData>(_onLoadFilteredChartData);
//     on<UpdateFurnaceNo>(_onUpdateFurnaceNo);
//     // on<UpdatePeriod>(_onUpdatePeriod);
//     on<UpdatePeriodStartDate>(_onUpdatePeriodStartDate);
//     on<UpdatePeriodEndDate>(_onUpdatePeriodEndDate);
//     on<UpdateMaterialNo>(_onUpdateMaterialNo);
//     on<ClearFilters>(_onClearFilters);
//     on<UpdateDateRange>(_onUpdateDateRange);
//   }

//   Future<void> _onLoadFilteredChartData(
//     LoadFilteredChartData event,
//     Emitter<SearchState> emit,
//   ) async {
//     emit(SearchLoading());

//     try {
//       _currentQuery = ChartFilterQuery(
//         startDate: event.startDate,
//         endDate: event.endDate,
//         furnaceNo: event.furnaceNo,
//         materialNo: event.materialNo,
//         page: event.page ?? 1,
//         limit: event.limit ?? 50,
//       );

//       final chartDetails = await _searchApiService.getFilteringChartDetails(_currentQuery);
//       final chartStatistics = await _searchApiService.getControlChartStat(_currentQuery);
//       emit(SearchLoaded(chartDetails, chartStatistics, _currentQuery));
//     } catch (e) {
//       emit(SearchError(e.toString()));
//     }
//   }

//   Future<void> _onUpdateFurnaceNo(
//     UpdateFurnaceNo event,
//     Emitter<SearchState> emit,
//   ) async {
//     emit(SearchLoading());
//     print(event.furnaceNo);


//     try {
//       _currentQuery = _currentQuery.copyWith(
//         furnaceNo: event.furnaceNo,
//         page: 1, // reset to first page
//       );

//       final chartDetails = await _searchApiService.getFilteringChartDetails(_currentQuery);
//       final chartStatistics = await _searchApiService.getControlChartStat(_currentQuery);
//       emit(SearchLoaded(chartDetails, chartStatistics, _currentQuery));
//     } catch (e) {
//       emit(SearchError(e.toString()));
//     }
//   }

//   Future<void> _onUpdatePeriodStartDate(
//     UpdatePeriodStartDate event,
//     Emitter<SearchState> emit,
//   ) async {
//     emit(SearchLoading());
//     // print('QUERY: $event.startDate');

//     try {
//       _currentQuery = _currentQuery.copyWith(
//         startDate: event.startDate,
//         page: 1, // reset to first page
//       );

//       final chartDetails = await _searchApiService.getFilteringChartDetails(_currentQuery);
//       final chartStatistics = await _searchApiService.getControlChartStat(_currentQuery);
//       emit(SearchLoaded(chartDetails, chartStatistics, _currentQuery));
//     } catch (e) {
//       emit(SearchError(e.toString()));
//     }
//   }

//   Future<void> _onUpdatePeriodEndDate(
//     UpdatePeriodEndDate event,
//     Emitter<SearchState> emit,
//   ) async {
//     emit(SearchLoading());
//     // print('QUERY: $event.endDate');

//     try {
//       _currentQuery = _currentQuery.copyWith(
//         endDate: event.endDate,
//         page: 1, // reset to first page
//       );

//       final chartDetails = await _searchApiService.getFilteringChartDetails(_currentQuery);
//       final chartStatistics = await _searchApiService.getControlChartStat(_currentQuery);
//       emit(SearchLoaded(chartDetails, chartStatistics, _currentQuery));
//     } catch (e) {
//       emit(SearchError(e.toString()));
//     }
//   }

//   Future<void> _onUpdateMaterialNo(
//     UpdateMaterialNo event,
//     Emitter<SearchState> emit,
//   ) async {
//     emit(SearchLoading());

//     try {
//       _currentQuery = _currentQuery.copyWith(
//         materialNo: event.materialNo,
//         page: 1, // reset to first page
//       );

//       final chartDetails = await _searchApiService.getFilteringChartDetails(_currentQuery);
//       final chartStatistics = await _searchApiService.getControlChartStat(_currentQuery);
//       emit(SearchLoaded(chartDetails, chartStatistics, _currentQuery));
//     } catch (e) {
//       emit(SearchError(e.toString()));
//     }
//   }

//   Future<void> _onClearFilters(
//     ClearFilters event,
//     Emitter<SearchState> emit,
//   ) async {
//     emit(SearchLoading());

//     try {
//       _currentQuery = const ChartFilterQuery(page: 1, limit: 50);
//       final chartDetails = await _searchApiService.getFilteringChartDetails(_currentQuery);
//       final chartStatistics = await _searchApiService.getControlChartStat(_currentQuery);
//       emit(SearchLoaded(chartDetails, chartStatistics, _currentQuery));
//     } catch (e) {
//       emit(SearchError(e.toString()));
//     }
//   }

//     Future<void> _onUpdateDateRange(
//     UpdateDateRange event,
//     Emitter<SearchState> emit,
//   ) async {
//   print('🔄 SearchBloc received UpdateDateRange');
//   print('Start: ${event.startDate}');
//   print('End: ${event.endDate}');
  
//     emit(SearchLoading());

//     try {
//       _currentQuery = _currentQuery.copyWith(
//         startDate: event.startDate,
//         endDate: event.endDate,
//         page: 1,
//       );
    
//     print('📋 Updated _currentQuery: $_currentQuery');
//     print('Query params: ${_currentQuery.toQueryParams()}');

//       final chartDetails = await _searchApiService.getFilteringChartDetails(_currentQuery);
//       final chartStatistics = await _searchApiService.getControlChartStat(_currentQuery);
    
//     print('✅ API call successful, emitting SearchLoaded');
//       emit(SearchLoaded(chartDetails, chartStatistics, _currentQuery));
//     } catch (e) {
//     print('❌ API call failed: $e');
//       emit(SearchError(e.toString()));
//     }
//   }

// }