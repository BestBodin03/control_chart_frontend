import 'package:control_chart/data/bloc/search_chart_details/extension/search_state_extension.dart';
import 'package:control_chart/domain/models/chart_data_point.dart';
import 'package:control_chart/domain/types/chart_component.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../data/bloc/search_chart_details/search_bloc.dart';
import '../../../../../domain/models/control_chart_stats.dart';
import '../../../design_system/app_color.dart';
import 'control_chart_component.dart';
import 'mr_chart_component.dart';

class ControlChartTemplate extends StatefulWidget {
  final String xAxisLabel;
  final String yAxisLabel;
  final Color? dataLineColor;
  final Color? backgroundColor;
  final double? height; // can be overridden by parent
  final double? width;
  final bool isMovingRange;

  // 🔒 Optional frozen overrides (keep same API as before)
  final ControlChartStats? frozenStats;
  final List<ChartDataPoint>? frozenDataPoints;
  final SearchStatus? frozenStatus;

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
  });

  @override
  State<ControlChartTemplate> createState() => _ControlChartTemplateState();
}

class _ControlChartTemplateState extends State<ControlChartTemplate> {
  static const int _windowSize = 24;

  // start index for the visible window [start, start+_windowSize)
  int _start = 0;
  int _maxStart = 0;

  // cache latest full list length to decide if we need to reset the window
  int _lastLen = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncWindowToData(); // initialize the window
  }

  @override
  void didUpdateWidget(covariant ControlChartTemplate oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncWindowToData();
  }

  void _syncWindowToData() {
    final full = _fullDataPoints();
    final n = full.length;

    if (n != _lastLen) {
      _lastLen = n;
      if (n <= _windowSize) {
        _start = 0;
        _maxStart = 0;
      } else {
        _maxStart = n - _windowSize;
        // default window shows the latest _windowSize points
        _start = _maxStart.clamp(0, _maxStart);
      }
      setState(() {});
    } else {
      // keep window valid if data changed shape but not length
      if (n <= _windowSize) {
        _start = 0;
        _maxStart = 0;
      } else {
        _maxStart = n - _windowSize;
        _start = _start.clamp(0, _maxStart);
      }
    }
  }

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
    if (full.length <= _windowSize) return full;
    final end = (_start + _windowSize).clamp(0, full.length);
    return full.sublist(_start, end);
  }

  @override
  Widget build(BuildContext context) {
    // If using frozen overrides, render without Bloc; else listen to Bloc
    if (widget.frozenStats != null && widget.frozenDataPoints != null) {
      return _buildFromData(
        dataPoints: _visible(widget.frozenDataPoints!),
        stats: widget.frozenStats!,
        status: widget.frozenStatus ?? SearchStatus.success,
        showSlider: (widget.frozenDataPoints!.length > _windowSize),
        totalLength: widget.frozenDataPoints!.length,
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

        final full = state.chartDataPoints;
        return _buildFromData(
          dataPoints: _visible(full),
          stats: state.controlChartStats!,
          status: state.status,
          showSlider: (full.length > _windowSize),
          totalLength: full.length,
        );
      },
    );
  }

  Widget _buildFromData({
    required List<ChartDataPoint> dataPoints,
    required ControlChartStats stats,
    required SearchStatus status,
    required bool showSlider,
    required int totalLength,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = widget.width ?? constraints.maxWidth;
        final h = widget.height ?? constraints.maxHeight;

        // Components receive ONLY the visible window
        final useIndividual = ControlChartComponent(
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
            widget.isMovingRange ? useMr : useIndividual;

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
              padding: const EdgeInsets.fromLTRB(
                  0, 0, legendRightPad, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: legendHeight,
                        child: Align(
                          alignment: Alignment.center,
                          child: selectedWidget.buildLegend(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: gapLegendToChart),


                  // Chart area
                  Expanded(
                    child: LineChart(
                      LineChartData(
                        gridData: selectedWidget.buildGridData(),
                        extraLinesData: selectedWidget.buildControlLines(),
                        titlesData: selectedWidget.buildTitlesData(),
                        borderData: selectedWidget.buildBorderData(),
                        lineBarsData: selectedWidget.buildLineBarsData(),
                        minX: 0,
                        maxX: (dataPoints.length - 1).toDouble(), // domain = visible window
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
