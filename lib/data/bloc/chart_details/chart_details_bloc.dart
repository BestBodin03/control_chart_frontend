
import 'package:bloc/bloc.dart';
import 'package:control_chart/apis/search_chart_details/search_chart_details_apis.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/domain/models/chart_detail.dart';
import 'package:control_chart/domain/models/control_chart_stats.dart';
import 'package:control_chart/domain/types/chart_filter_query.dart';
import 'package:equatable/equatable.dart';

part 'chart_details_event.dart';
part 'chart_details_state.dart';

class ChartDetailsBloc extends Bloc<ChartDetailsEvent, ChartDetailsState> {
  final SearchChartDetailsApis _chartApis;
  
  ChartDetailsBloc({required SearchChartDetailsApis chartApis})
  : _chartApis = chartApis,
  super(ChartDetailsState()) {
  on<LoadChartDetailsSpots>(_onLoadChartDetialsSpots);
  on<LoadControlChartStatistics>(_onLoadControlChartStatistics);
  on<RefreshControlChart>(_onRefreshControlChart);
  }

  Future<void> _onLoadChartDetialsSpots (
    LoadChartDetailsSpots event,
    Emitter<ChartDetailsState> emit,

  ) async {
    emit(state.copyWith(status: () => ChartDetailsStatus.loading));
  }

  Future<void> _onLoadControlChartStatistics(
    LoadControlChartStatistics event,
    Emitter<ChartDetailsState> emit,
  ) async {
    emit(state.copyWith(status: () => ChartDetailsStatus.loading));
    
    try {
      final controlChartStatistics = await _chartApis.getControlChartStat(event.query);
      
      emit(state.copyWith(
        status: () => ChartDetailsStatus.loaded,
        controlChartStats: () => controlChartStatistics,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: () => ChartDetailsStatus.error,
        errorMessage: () => e.toString(),
      ));
    }
  }

  Future<void> _onRefreshControlChart (
    RefreshControlChart event,
    Emitter<ChartDetailsState> emit,

  ) async {

  }
}