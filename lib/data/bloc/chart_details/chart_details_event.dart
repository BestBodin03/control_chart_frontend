part of 'chart_details_bloc.dart';

sealed class ChartDetailsEvent {
  const ChartDetailsEvent();

  @override
  List<Object> get props => [];
}

final class LoadChartDetailsSpots  extends ChartDetailsEvent {
  const LoadChartDetailsSpots();
}

final class LoadControlChartStatistics extends ChartDetailsEvent {
  const LoadControlChartStatistics({required this.query});
  
  final ChartFilterQuery query;
  
  @override
  List<Object> get props => [query];
}

final class RefreshControlChart extends ChartDetailsEvent {
  const RefreshControlChart({
    required this.chartDetail,
    required this.controlChartStat}
  );
  final ChartDetail chartDetail;
  final ControlChartStats controlChartStat;

  @override
  List<Object> get props => [chartDetail, controlChartStat];
}



