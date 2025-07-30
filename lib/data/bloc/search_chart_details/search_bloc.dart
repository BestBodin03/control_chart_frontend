import 'package:control_chart/apis/search_chart_details/search_chart_details_apis.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_event.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_state.dart';
import 'package:control_chart/domain/models/control_chart_stat.dart';
import 'package:control_chart/domain/types/chart_filter_query.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchChartDetailsApis _searchApiService = SearchChartDetailsApis();
  
  // เก็บ current filter state
  ChartFilterQuery _currentQuery = const ChartFilterQuery();

  SearchBloc() : super(SearchInitial()) {
    on<LoadFilteredChartData>(_onLoadFilteredChartData);
    on<UpdateFurnaceNo>(_onUpdateFurnaceNo);
    // on<UpdatePeriod>(_onUpdatePeriod);
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
    emit(SearchLoading());

    try {
      _currentQuery = ChartFilterQuery(
        startDate: event.startDate,
        endDate: event.endDate,
        furnaceNo: event.furnaceNo,
        materialNo: event.materialNo,
        page: event.page ?? 1,
        limit: event.limit ?? 50,
      );

      final chartDetails = await _searchApiService.getFilteringChartDetails(_currentQuery);
      final chartStatistics = await _searchApiService.getControlChartStat(_currentQuery);
      emit(SearchLoaded(chartDetails, chartStatistics, _currentQuery));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  Future<void> _onUpdateFurnaceNo(
    UpdateFurnaceNo event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading());
    print(event.furnaceNo);


    try {
      _currentQuery = _currentQuery.copyWith(
        furnaceNo: event.furnaceNo,
        page: 1, // reset to first page
      );

      final chartDetails = await _searchApiService.getFilteringChartDetails(_currentQuery);
      final chartStatistics = await _searchApiService.getControlChartStat(_currentQuery);
      emit(SearchLoaded(chartDetails, chartStatistics, _currentQuery));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  Future<void> _onUpdatePeriodStartDate(
    UpdatePeriodStartDate event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading());
    // print('QUERY: $event.startDate');

    try {
      _currentQuery = _currentQuery.copyWith(
        startDate: event.startDate,
        page: 1, // reset to first page
      );

      final chartDetails = await _searchApiService.getFilteringChartDetails(_currentQuery);
      final chartStatistics = await _searchApiService.getControlChartStat(_currentQuery);
      emit(SearchLoaded(chartDetails, chartStatistics, _currentQuery));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  Future<void> _onUpdatePeriodEndDate(
    UpdatePeriodEndDate event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading());
    // print('QUERY: $event.endDate');

    try {
      _currentQuery = _currentQuery.copyWith(
        endDate: event.endDate,
        page: 1, // reset to first page
      );

      final chartDetails = await _searchApiService.getFilteringChartDetails(_currentQuery);
      final chartStatistics = await _searchApiService.getControlChartStat(_currentQuery);
      emit(SearchLoaded(chartDetails, chartStatistics, _currentQuery));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  Future<void> _onUpdateMaterialNo(
    UpdateMaterialNo event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading());

    try {
      _currentQuery = _currentQuery.copyWith(
        materialNo: event.materialNo,
        page: 1, // reset to first page
      );

      final chartDetails = await _searchApiService.getFilteringChartDetails(_currentQuery);
      final chartStatistics = await _searchApiService.getControlChartStat(_currentQuery);
      emit(SearchLoaded(chartDetails, chartStatistics, _currentQuery));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  Future<void> _onClearFilters(
    ClearFilters event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading());

    try {
      _currentQuery = const ChartFilterQuery(page: 1, limit: 50);
      final chartDetails = await _searchApiService.getFilteringChartDetails(_currentQuery);
      final chartStatistics = await _searchApiService.getControlChartStat(_currentQuery);
      emit(SearchLoaded(chartDetails, chartStatistics, _currentQuery));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

    Future<void> _onUpdateDateRange(
    UpdateDateRange event,
    Emitter<SearchState> emit,
  ) async {
  print('🔄 SearchBloc received UpdateDateRange');
  print('Start: ${event.startDate}');
  print('End: ${event.endDate}');
  
    emit(SearchLoading());

    try {
      _currentQuery = _currentQuery.copyWith(
        startDate: event.startDate,
        endDate: event.endDate,
        page: 1,
      );
    
    print('📋 Updated _currentQuery: $_currentQuery');
    print('Query params: ${_currentQuery.toQueryParams()}');

      final chartDetails = await _searchApiService.getFilteringChartDetails(_currentQuery);
      final chartStatistics = await _searchApiService.getControlChartStat(_currentQuery);
    
    print('✅ API call successful, emitting SearchLoaded');
      emit(SearchLoaded(chartDetails, chartStatistics, _currentQuery));
    } catch (e) {
    print('❌ API call failed: $e');
      emit(SearchError(e.toString()));
    }
  }

}