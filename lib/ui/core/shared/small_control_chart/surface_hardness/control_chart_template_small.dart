import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/domain/models/chart_data_point.dart';
import 'package:control_chart/domain/models/control_chart_stats.dart';
import 'package:control_chart/domain/types/chart_component.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/shared/small_control_chart/surface_hardness/control_chart_component_small.dart';
import 'package:control_chart/ui/core/shared/small_control_chart/surface_hardness/mr_chart_component_small.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ControlChartTemplateSmall extends StatelessWidget {
  final List<ChartDataPoint>? dataPoints;
  final ControlChartStats? controlChartStats;

  // requested params
  final String xAxisLabel;
  final String yAxisLabel;
  final Color? dataLineColor;
  final Color? backgroundColor;
  final double? height;
  final double? width;
  final bool isMovingRange;
  final DateTime? xStart;
  final DateTime? xEnd;
  final int? xTick;

  const ControlChartTemplateSmall({
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
    this.xStart,
    this.xEnd,
    this.xTick,
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
    // guard: data
    if (dataPoints == null || dataPoints!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.data_usage_outlined, size: 64),
            SizedBox(height: 8),
            Text('ไม่มีข้อมูลสำหรับแสดงผล', style: TextStyle(fontSize: 16)),
          ],
        ),
      );
    }

    // choose component
    final useI = ControlChartComponentSmall(
      dataPoints: dataPoints,
      controlChartStats: controlChartStats,
      dataLineColor: dataLineColor,
      backgroundColor: backgroundColor,
      height: height,
      width: width,
    );

    final useMr = MrChartComponentSmall(
      dataPoints: dataPoints,
      controlChartStats: controlChartStats,
      dataLineColor: dataLineColor,
      backgroundColor: backgroundColor,
      height: height,
      width: width,
    );

    final ChartComponent selectedWidget = isMovingRange ? useMr : useI;

    // ----- X time window (ms) -----
    final nowUtc = DateTime.now().toUtc();

    // Priority: widget.xStart/xEnd -> searchState.query -> data range -> now
    DateTime? s = xStart ?? searchState.currentQuery.startDate;
    DateTime? e = xEnd ?? searchState.currentQuery.endDate;

    if ((s == null || e == null) && dataPoints!.isNotEmpty) {
      // derive from data if missing
      DateTime minDt = dataPoints!.first.collectDate;
      DateTime maxDt = minDt;
      for (final p in dataPoints!) {
        if (p.collectDate.isBefore(minDt)) minDt = p.collectDate;
        if (p.collectDate.isAfter(maxDt)) maxDt = p.collectDate;
      }
      s ??= minDt;
      e ??= maxDt;
    }

    // final fallback: last 30 days to now
    s ??= nowUtc.subtract(const Duration(days: 30));
    e ??= nowUtc;

    // ensure start <= end
    if (s.isAfter(e)) {
      final tmp = s;
      s = e;
      e = tmp;
    }

    final minXv = s.millisecondsSinceEpoch.toDouble();
    final maxXv = e.millisecondsSinceEpoch.toDouble();
    final safeRange = (maxXv - minXv).abs().clamp(1.0, double.infinity);

    // X tick density
    final desiredTick = (xTick ?? controlChartStats?.xTick ?? 6).clamp(2, 24);
    final tickInterval = safeRange / (desiredTick - 1);

    // ----- UI -----
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Padding(
        // leave top space for top grid/tooltip
        padding: const EdgeInsets.fromLTRB(4.0, 24.0, 16.0, 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // chart
            Expanded(
              child: LineChart(
                LineChartData(
                  extraLinesData: selectedWidget.buildControlLines(),
                  gridData: selectedWidget.buildGridData(minXv, maxXv, tickInterval),
                  titlesData: selectedWidget.buildTitlesData(minXv, maxXv, tickInterval),
                  borderData: selectedWidget.buildBorderData(),
                  lineBarsData: selectedWidget.buildLineBarsData(),
                  // IMPORTANT: time-based X axis
                  minX: minXv,
                  maxX: maxXv,
                  minY: selectedWidget.getMinY(),
                  maxY: selectedWidget.getMaxY(),
                  lineTouchData: selectedWidget.buildTouchData(),
                  clipData: FlClipData.none(),
                ),
              ),
            ),

            // (legend omitted in small template; enable if you want)
            // const SizedBox(width: 16),
            // (isMovingRange ? useMr : useI).buildLegend(),
          ],
        ),
      ),
    );
  }
}
