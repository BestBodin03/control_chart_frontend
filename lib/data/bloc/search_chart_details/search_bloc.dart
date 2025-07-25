import 'package:bloc/bloc.dart';
import 'package:control_chart/apis/search_chart_details/search_chart_details_apis.dart';
import 'package:control_chart/data/bloc/search_chart_details/search-event.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_state.dart';
import 'package:control_chart/domain/models/chart_detail.dart';
import 'package:control_chart/domain/types/chart_filter_query.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchChartDetailsApis _apis;
  ChartFilterQuery _currentQuery = const ChartFilterQuery();

  SearchBloc(this._apis) : super(SearchInitial()) {
    // ใช้ debounce เพื่อป้องกันการเรียก API บ่อยเกินไป
    on<SearchQueryChanged>(
      _onSearchQueryChanged
    );
    
    on<SearchPeriodChanged>(_onSearchPeriodChanged);
    on<SearchFurnaceNoChanged>(_onSearchFurnaceNoChanged);
    on<SearchMatNoChanged>(_onSearchMatNoChanged);
    on<SearchCleared>(_onSearchCleared);
  }

  void _onSearchPeriodChanged(
    SearchPeriodChanged event,
    Emitter<SearchState> emit,
  ) {
    _currentQuery = _currentQuery.copyWith(startDate: event.startDate, endDate: event.endDate );
    add(SearchQueryChanged(_currentQuery));
  }

  void _onSearchFurnaceNoChanged(
    SearchFurnaceNoChanged event,
    Emitter<SearchState> emit,
  ) {
    _currentQuery = _currentQuery.copyWith(
      furnaceNo: event.furnaceNo,
    );
    add(SearchQueryChanged(_currentQuery));
  }

  void _onSearchMatNoChanged(
    SearchMatNoChanged event,
    Emitter<SearchState> emit,
  ) {
    _currentQuery = _currentQuery.copyWith(
      matNo: event.matNo,
    );
    add(SearchQueryChanged(_currentQuery));
  }

  void _onSearchCleared(
    SearchCleared event,
    Emitter<SearchState> emit,
  ) {
    _currentQuery = const ChartFilterQuery();
    emit(SearchInitial());
  }

  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    // แสดง loading state พร้อมข้อมูลเก่า (ถ้ามี)
    final previousResults = state is SearchSuccess 
        ? (state as SearchSuccess).filterdChartDetails 
        : <ChartDetail>[];
    
    emit(SearchLoading(previousResults: previousResults));

    try {
      final filterdChartDetails = await _apis.getFilteringChartDetails(event.query);
      emit(SearchSuccess(filterdChartDetails: filterdChartDetails, query: event.query));
    } catch (e) {
      emit(SearchError(
        message: e.toString(),
        previousResults: previousResults,
      ));
    }
  }
}