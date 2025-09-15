import 'package:control_chart/data/bloc/search_chart_details/extension/search_state_extension.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/domain/models/chart_data_point.dart';
import 'package:control_chart/domain/models/control_chart_stats.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/shared/medium_control_chart/surface_hardness/control_chart_component.dart';
import 'package:control_chart/ui/core/shared/medium_control_chart/surface_hardness/mr_chart_component.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../domain/types/chart_component.dart';

class ControlChartTemplate extends StatefulWidget {
  final String xAxisLabel;
  final String yAxisLabel;
  final Color? dataLineColor;
  final Color? backgroundColor;
  final double? height; // can be overridden by parent
  final double? width;
  final bool isMovingRange;

  /// Optional frozen overrides
  final ControlChartStats? frozenStats;
  final List<ChartDataPoint>? frozenDataPoints;
  final SearchStatus? frozenStatus;

  /// Parent-controlled windowing
  final int? externalStart;
  final int? externalWindowSize;

  const ControlChartTemplate({
    super.key,
    this.xAxisLabel = 'Date',
    this.yAxisLabel = 'Attr.',
    this.dataLineColor = AppColors.colorBrand,
    this.backgroundColor = Colors.white,
    this.height,
    this.width,
    required this.isMovingRange,
    this.frozenStats,
    this.frozenDataPoints,
    this.frozenStatus,
    this.externalStart,
    this.externalWindowSize, int? xTick,
  });

  @override
  State<ControlChartTemplate> createState() => _ControlChartTemplateState();
}

class _ControlChartTemplateState extends State<ControlChartTemplate> {
  List<ChartDataPoint> _fullDataPoints() {
    if (widget.frozenDataPoints != null) return widget.frozenDataPoints!;
    final state = context.read<SearchBloc>().state;
    return state.chartDataPoints;
  }

  ControlChartStats? _fullStats() {
    if (widget.frozenStats != null) return widget.frozenStats;
    final state = context.read<SearchBloc>().state;
    return state.controlChartStats;
  }

  SearchStatus _status() {
    if (widget.frozenStatus != null) return widget.frozenStatus!;
    return context.read<SearchBloc>().state.status;
  }

  List<ChartDataPoint> _visible(List<ChartDataPoint> full) {
    if (full.isEmpty) return const <ChartDataPoint>[];
    final start = (widget.externalStart ?? 0).clamp(0, full.length - 1);
    final win = widget.externalWindowSize;
    if (win == null || full.length <= win) return full;
    final end = (start + win).clamp(0, full.length);
    return full.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    // Frozen path (no Bloc)
    if (widget.frozenStats != null && widget.frozenDataPoints != null) {
      final data = _visible(widget.frozenDataPoints!);
      return _buildFromData(
        dataPoints: data,
        stats: widget.frozenStats!,
        status: widget.frozenStatus ?? SearchStatus.success,
      );
    }

    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (state.status == SearchStatus.loading) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }
        if (state.status == SearchStatus.failure) {
          return const Center(child: Text('จำนวนข้อมูลไม่เพียงพอ ต้องการข้อมูลอย่างน้อย 5 รายการ'));
        }
        if (state.controlChartStats == null || state.chartDataPoints.isEmpty) {
          return const Center(child: Text('ไม่มีข้อมูลสำหรับแสดงผล'));
        }

        final full = _fullDataPoints();
        final data = _visible(full);

        return _buildFromData(
          dataPoints: data,
          stats: state.controlChartStats!,
          status: state.status,
        );
      },
    );
  }

  Widget _buildFromData({
    required List<ChartDataPoint> dataPoints,
    required ControlChartStats stats,
    required SearchStatus status,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = widget.width ?? constraints.maxWidth;
        final h = widget.height ?? constraints.maxHeight;

        // Components receive only the visible window
        final useI = ControlChartComponent(
          dataPoints: dataPoints,
          controlChartStats: stats,
          dataLineColor: widget.dataLineColor,
          backgroundColor: widget.backgroundColor,
          height: h,
          width: w,
        );
        final useMr = MrChartComponent(
          dataPoints: dataPoints,
          controlChartStats: stats,
          dataLineColor: widget.dataLineColor,
          backgroundColor: widget.backgroundColor,
          height: h,
          width: w,
        );
        final ChartComponent selectedWidget =
            widget.isMovingRange ? useMr : useI;

        const legendRightPad = 24.0;
        const legendHeight = 32.0;
        const gapLegendToChart = 4.0;

        return SizedBox(
          width: w,
          height: h,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, legendRightPad, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Legend
                  SizedBox(
                    height: legendHeight,
                    child: Align(
                      alignment: Alignment.center,
                      child: selectedWidget.buildLegend(),
                    ),
                  ),
                  const SizedBox(height: gapLegendToChart),

                  // Chart
                  Expanded(
                    child: LineChart(
                      LineChartData(
                        gridData: selectedWidget.buildGridData(),
                        extraLinesData: selectedWidget.buildControlLines(),
                        titlesData: selectedWidget.buildTitlesData(),
                        borderData: selectedWidget.buildBorderData(),
                        lineBarsData: selectedWidget.buildLineBarsData(),
                        minX: 0,
                        maxX: (dataPoints.length - 1).toDouble(),
                        minY: selectedWidget.getMinY(),
                        maxY: selectedWidget.getMaxY(),
                        lineTouchData: selectedWidget.buildTouchData(),
                        clipData: FlClipData.none(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
