import 'package:control_chart/ui/core/shared/large_control_chart/cde_cdt/mr_chart_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/data/bloc/search_chart_details/extension/search_state_extension.dart';
import 'package:control_chart/domain/models/control_chart_stats.dart';
import 'package:control_chart/domain/models/chart_data_point.dart';
import 'package:control_chart/domain/types/chart_component.dart';

// CDE/CDT chart parts
import 'package:control_chart/ui/core/shared/medium_control_chart/cde_cdt/control_chart_component.dart'
    as ctrl;
import 'package:control_chart/ui/core/shared/medium_control_chart/cde_cdt/mr_chart_component.dart'
    as mr;

class ControlChartTemplateCdeCdtLarge extends StatefulWidget {
  final String xAxisLabel;
  final String yAxisLabel;
  final Color? dataLineColor;
  final Color? backgroundColor;
  final double? height;
  final double? width;
  final bool isMovingRange;

  /// Frozen overrides (optional). If provided, Bloc is bypassed.
  final ControlChartStats? frozenStats;
  final List<ChartDataPointCdeCdt>? frozenDataPoints;
  final SearchStatus? frozenStatus;

  /// Time range (required for Surface-like behavior)
  final DateTime? xStart;
  final DateTime? xEnd;

  const ControlChartTemplateCdeCdtLarge({
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
    required this.xStart,
    required this.xEnd,
  });

  @override
  State<ControlChartTemplateCdeCdtLarge> createState() =>
      _ControlChartTemplateCdeCdtLargeState();
}

class _ControlChartTemplateCdeCdtLargeState
    extends State<ControlChartTemplateCdeCdtLarge> {
  List<ChartDataPointCdeCdt> _fullDataPoints() {
    if (widget.frozenDataPoints != null) return widget.frozenDataPoints!;
    final state = context.read<SearchBloc>().state;
    return state.chartDataPointsCdeCdt;
  }

  @override
  Widget build(BuildContext context) {
    // Frozen path (bypass Bloc)
    if (widget.frozenStats != null && widget.frozenDataPoints != null) {
      return _buildFromData(
        dataPoints: widget.frozenDataPoints!,
        stats: widget.frozenStats!,
        status: widget.frozenStatus ?? SearchStatus.success,
      );
    }

    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        final stats = state.controlChartStats;
        if (state.status == SearchStatus.loading) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }
        if (state.status == SearchStatus.failure) {
          return const Center(
              child: Text('จำนวนข้อมูลไม่เพียงพอ ต้องการข้อมูลอย่างน้อย 5 รายการ'));
        }
        if (stats == null ||
            stats.secondChartSelected == SecondChartSelected.na) {
          return const SizedBox.shrink();
        }

        final full = _fullDataPoints();
        if (full.isEmpty) {
          return const Center(child: Text('ไม่มีข้อมูลสำหรับแสดงผล'));
        }

        return _buildFromData(
          dataPoints: full,
          stats: stats,
          status: state.status,
        );
      },
    );
  }

  Widget _buildFromData({
    required List<ChartDataPointCdeCdt> dataPoints,
    required ControlChartStats stats,
    required SearchStatus status,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = widget.width ?? constraints.maxWidth;
        final h = widget.height ?? constraints.maxHeight;

        DateTime? start = widget.xStart;
        DateTime? end = widget.xEnd;

        if ((start == null || end == null) && dataPoints.isNotEmpty) {
          // ensure chronological for fallback
          dataPoints.sort((a, b) => a.collectDate.compareTo(b.collectDate));
          start ??= dataPoints.first.collectDate;
          end ??= dataPoints.last.collectDate;
        }
        if (start == null || end == null) {
          return const Center(child: Text('ช่วงเวลาไม่ถูกต้อง'));
        }

        final iChart = ctrl.ControlChartComponent(
          dataPoints: dataPoints,
          controlChartStats: stats,
          dataLineColor: widget.dataLineColor,
          backgroundColor: widget.backgroundColor,
          height: h,
          width: w,
          xStart: start,
          xEnd: end,
        );

        final mrChart = mr.MrChartComponent(
          dataPoints: dataPoints,
          controlChartStats: stats,
          dataLineColor: widget.dataLineColor,
          backgroundColor: widget.backgroundColor,
          height: h,
          width: w,
          xStart: start,
          xEnd: end,
        );

        final Widget selectedWidget = widget.isMovingRange ? mrChart : iChart;

        // match Surface template constants
        const legendRightPad = 32.0;
        const legendHeight = 28.0;
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
              // keep left = 16, right = 16, bottom = 8
              padding: const EdgeInsets.fromLTRB(16, 0, legendRightPad, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top spacing to force "top = 4"
                  const SizedBox(height: 4),

                  // Legend: fixed height = 28, aligned left (so left = 16 visually)
                  SizedBox(
                    height: legendHeight,
                    child: Align(
                      alignment: Alignment.center,
                      child: (selectedWidget as ChartComponent).buildLegend(context),
                    ),
                  ),

                  // Gap between legend and chart = 4
                  const SizedBox(height: gapLegendToChart),

                  // Chart body
                  Expanded(child: selectedWidget),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
