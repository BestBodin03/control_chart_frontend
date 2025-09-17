import 'package:control_chart/domain/models/control_chart_stats.dart';
import 'package:control_chart/domain/types/chart_component.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/shared/small_control_chart/cde_cdt/control_chart_component_small.dart';
import 'package:control_chart/ui/core/shared/small_control_chart/cde_cdt/mr_chart_component_small.dart';
import 'package:control_chart/ui/core/shared/small_control_chart/surface_hardness/control_chart_component_small.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../data/bloc/search_chart_details/search_bloc.dart';
import '../../../../../domain/models/chart_data_point.dart';

/// Small template for CDE/CDT charts.
/// IMPORTANT: X-axis uses real time (millisecondsSinceEpoch).
/// minX / maxX come from SearchState.currentQuery.startDate / endDate (UTC fallback).
class ControlChartTemplateSmallCdeCdt extends StatelessWidget {
  final List<ChartDataPointCdeCdt>? dataPoints;
  final ControlChartStats? controlChartStats;
  final String xAxisLabel;
  final String yAxisLabel;
  final Color? dataLineColor;
  final Color? backgroundColor;
  final double? height;
  final double? width;
  final bool isMovingRange;

  const ControlChartTemplateSmallCdeCdt({
    super.key,
    this.dataPoints,
    this.controlChartStats,
    this.xAxisLabel = 'Date',
    this.yAxisLabel = 'Attr.',
    this.dataLineColor = AppColors.colorBrand,
    this.backgroundColor = Colors.white,
    this.height = 300,
    this.width,
    required this.isMovingRange,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, searchState) {
        return SizedBox(
          height: height ?? 300,
          width: width,
          child: _buildChartContent(searchState),
        );
      },
    );
  }

  Widget _buildChartContent(SearchState searchState) {
    // Guard: no data
    if (dataPoints == null || dataPoints!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.data_usage_outlined, size: 48),
            const SizedBox(height: 8),
            Text('ไม่มีข้อมูลสำหรับแสดงผล', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          ],
        ),
      );
    }

    // Choose which component to use (Individual vs MR)
    final ChartComponent selectedWidget = isMovingRange
        ? MrChartComponentSmall(
            dataPoints: dataPoints,
            controlChartStats: controlChartStats,
          )
        : ControlChartComponentSmallCdeCdt(
            dataPoints: dataPoints,
            controlChartStats: controlChartStats,
          );

    // Compute time window from searchState (UTC fallback)
    final nowUtc = DateTime.now().toUtc();
    final rawStart = (searchState.currentQuery.startDate ?? nowUtc).toUtc();
    final rawEnd = (searchState.currentQuery.endDate ?? nowUtc).toUtc();

    // Ensure start <= end; if not, swap
    final start = rawStart.isAfter(rawEnd) ? rawEnd : rawStart;
    final end = rawStart.isAfter(rawEnd) ? rawStart : rawEnd;

    // Convert to ms epoch for axis
    final minXv = start.millisecondsSinceEpoch.toDouble();
    final maxXv = end.millisecondsSinceEpoch.toDouble();
    final safeRange = (maxXv - minXv).abs().clamp(1.0, double.infinity);

    // Desired x ticks from stats with sane bounds
    final desiredTick = (controlChartStats?.xTick ?? 6).clamp(2, 24);
    final tickInterval = safeRange / (desiredTick - 1);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Padding(
        // top padding leaves space for top grid line / tooltip
        padding: const EdgeInsets.fromLTRB(4.0, 24.0, 16.0, 4.0),
        child: LineChart(
          LineChartData(
            // control/spec/target/avg lines
            extraLinesData: selectedWidget.buildControlLines(),

            // grid & titles use time-based axis
            gridData: selectedWidget.buildGridData(minXv, maxXv, tickInterval),
            titlesData: selectedWidget.buildTitlesData(minXv, maxXv, tickInterval),

            // border & series
            borderData: selectedWidget.buildBorderData(),
            lineBarsData: selectedWidget.buildLineBarsData(),

            // IMPORTANT: time-based X axis (ms)
            minX: minXv,
            maxX: maxXv,

            // Y from component-calculated nice range
            minY: selectedWidget.getMinY(),
            maxY: selectedWidget.getMaxY(),

            lineTouchData: selectedWidget.buildTouchData(),
            clipData: FlClipData.none(),
          ),
        ),
      ),
    );
  }
}
