part of 'chart_details_bloc.dart';

enum ChartDetailsStatus { initial, loading, refreshing, loaded, error }

final class ChartDetailsState extends Equatable {
  const ChartDetailsState({
    this.status = ChartDetailsStatus.initial,
    this.chartDetails = const [], 
    this.controlChartStats,
    this.errorMessage,
  });

  final ChartDetailsStatus status;
  final List<ChartDetail> chartDetails; 
  final ControlChartStats? controlChartStats; 
  final String? errorMessage;

  ChartDetailsState copyWith({
    ChartDetailsStatus Function()? status,
    List<ChartDetail> Function()? chartDetails, 
    ControlChartStats Function()? controlChartStats, 
    String? Function()? errorMessage,
  }) {
    return ChartDetailsState(
      status: status != null ? status() : this.status,
      chartDetails: chartDetails != null ? chartDetails() : this.chartDetails,
      controlChartStats: controlChartStats != null ? controlChartStats() : this.controlChartStats,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    chartDetails,
    controlChartStats,
    errorMessage,
  ];
}