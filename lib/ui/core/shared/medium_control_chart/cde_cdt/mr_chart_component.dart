import 'dart:math' as math;

import 'package:control_chart/domain/models/chart_data_point.dart';
import 'package:control_chart/domain/models/control_chart_stats.dart';
import 'package:control_chart/domain/types/chart_component.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';
import 'package:control_chart/ui/core/shared/dashed_line_painter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MrChartComponent extends StatelessWidget implements ChartComponent  {
  final List<ChartDataPointCdeCdt>? dataPoints;
  final ControlChartStats? controlChartStats;
  final Color? dataLineColor;
  final Color? backgroundColor;
  final double? height;
  final double? width;
  final bool isMovingRange;

  MrChartComponent({
    super.key, 
    this.dataPoints,
    this.controlChartStats,
    this.dataLineColor = AppColors.colorBrand,
    this.backgroundColor,
    this.height = 240,
    this.width = 560,
    this.isMovingRange = true
  });

  // ------- window config (latest N points) -------
  static const int _windowSize = 24;

  // cache for Y range/interval
  double? _cachedMinY;
  double? _cachedMaxY;
  double? _cachedInterval;

  // Visible window
  List<ChartDataPointCdeCdt> get _visiblePoints {
    final src = dataPoints ?? const <ChartDataPointCdeCdt>[];
    if (src.length <= _windowSize) return src;
    return src.sublist(src.length - _windowSize);
  }

  // strictly pick per selection
  T? _sel<T>(T? cde, T? cdt, T? comp) {
    switch (controlChartStats?.secondChartSelected) {
      case SecondChartSelected.cde:
        return cde;
      case SecondChartSelected.cdt:
        return cdt;
      case SecondChartSelected.compoundLayer:
        return comp;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (dataPoints == null || dataPoints!.isEmpty) {
      return const Center(child: Text('ไม่พบข้อมูล'));
    }

    final visible = _visiblePoints;

    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: buildGridData(),
                titlesData: buildTitlesData(),
                borderData: buildBorderData(),
                lineBarsData: buildLineBarsData(),
                extraLinesData: buildControlLines(),
                minX: 0,
                maxX: (visible.length - 1).toDouble(),
                minY: getMinY(),
                maxY: getMaxY(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  FlGridData buildGridData() {
    final n = _visiblePoints.length;
    return FlGridData(
      show: true,
      drawHorizontalLine: true,
      drawVerticalLine: true,
      horizontalInterval: _getInterval(),
      verticalInterval: _xIntervalForCount(n),
      getDrawingHorizontalLine: (_) => FlLine(
        color: Colors.grey.shade100,
        strokeWidth: 0.5,
      ),
      getDrawingVerticalLine: (_) => FlLine(
        color: Colors.grey.shade100,
        strokeWidth: 0.5,
      ),
    );
  }

  @override
  FlTitlesData buildTitlesData() {
    final visible = _visiblePoints;
    final step = 1.0;

    return FlTitlesData(
      leftTitles: AxisTitles(
        axisNameWidget: SizedBox(width: height),
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 24,
          interval: _getInterval(),
          getTitlesWidget: (value, _) => Text(
            value.toStringAsFixed(0),
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 8,
            ),
          ),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 32,
          interval: step,
          getTitlesWidget: (value, meta) {
            final i = value.round();
            if (i < 0 || i >= visible.length) return const SizedBox.shrink();

            return SideTitleWidget(
              meta: meta,
              space: 8,
              child: Transform.rotate(
                angle: -30 * math.pi / 180,
                child: Text(
                  visible[i].label,
                  style: const TextStyle(fontSize: 8, color: Colors.black54),
                ),
              ),
            );
          },
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  @override
  FlBorderData buildBorderData() {
    return FlBorderData(
      show: true,
      border: Border.all(
        color: Colors.black54,
        width: 1,
      ),
    );
  }

  @override
  ExtraLinesData buildControlLines() {
    final ucl = _sel(
      controlChartStats?.cdeControlLimitMRChart?.ucl,
      controlChartStats?.cdtControlLimitMRChart?.ucl,
      controlChartStats?.compoundLayerControlLimitMRChart?.ucl,
    );
    final cl = _sel(
      controlChartStats?.cdeControlLimitMRChart?.cl,
      controlChartStats?.cdtControlLimitMRChart?.cl,
      controlChartStats?.compoundLayerControlLimitMRChart?.cl,
    );

    return ExtraLinesData(
      extraLinesOnTop: false,
      horizontalLines: [
        if (ucl != null) HorizontalLine(y: ucl, color: Colors.amberAccent, strokeWidth: 1.5),
        if (cl != null) HorizontalLine(y: cl, color: AppColors.colorSuccess1, strokeWidth: 2),
      ],
    );
  }

  @override
  List<LineChartBarData> buildLineBarsData() {
    final visible = _visiblePoints;

    final spots = List<FlSpot>.generate(
      visible.length,
      (i) => FlSpot(i.toDouble(), visible[i].mrValue),
    );

    final ucl = _sel(
      controlChartStats?.cdeControlLimitMRChart?.ucl,
      controlChartStats?.cdtControlLimitMRChart?.ucl,
      controlChartStats?.compoundLayerControlLimitMRChart?.ucl,
    ) ?? 0.0;

    return [
      LineChartBarData(
        spots: spots,
        isCurved: false,
        color: dataLineColor,
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, _, __, ___) {
            final i = spot.x.toInt();
            final v = visible[i].mrValue;
            Color dotColor = dataLineColor!;

            if (ucl > 0 && v > ucl) {
              dotColor = Colors.orange; // warning zone
            }

            return FlDotCirclePainter(
              radius: 3.5,
              color: dotColor,
              strokeWidth: 1,
              strokeColor: Colors.white,
            );
          },
        ),
        belowBarData: BarAreaData(show: false),
      ),
    ];
  }

  @override
  LineTouchData buildTouchData() {
    final visible = _visiblePoints;

    return LineTouchData(
      handleBuiltInTouches: true,
      touchTooltipData: LineTouchTooltipData(
        maxContentWidth: 150,
        getTooltipColor: (_) => AppColors.colorBrand.withValues(alpha: 0.9),
        tooltipBorderRadius: BorderRadius.circular(8),
        fitInsideHorizontally: true,
        fitInsideVertically: true,
        tooltipMargin: 8,
        getTooltipItems: (spots) {
          return spots.map((barSpot) {
            final index = barSpot.x.toInt();
            if (index >= 0 && index < visible.length) {
              final mr = visible[index].mrValue;
              return LineTooltipItem(
                "ค่า: ${mr.isNaN ? '-' : mr.toStringAsFixed(3)}\n",
                AppTypography.textBody3W,
                textAlign: TextAlign.left,
              );
            }
            return const LineTooltipItem('', TextStyle());
          }).whereType<LineTooltipItem>().toList();
        },
      ),
    );
  }

  @override
  Widget buildLegend() {
    final ucl = _sel(
      controlChartStats?.cdeControlLimitMRChart?.ucl,
      controlChartStats?.cdtControlLimitMRChart?.ucl,
      controlChartStats?.compoundLayerControlLimitMRChart?.ucl,
    );
    final cl = _sel(
      controlChartStats?.cdeControlLimitMRChart?.cl,
      controlChartStats?.cdtControlLimitMRChart?.cl,
      controlChartStats?.compoundLayerControlLimitMRChart?.cl,
    );

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      direction: Axis.horizontal,
      alignment: WrapAlignment.spaceEvenly,
      children: [
        if (formatValue(ucl) != 'N/A')
          buildLegendItem('UCL', Colors.orange, false, formatValue(ucl)),
        if (formatValue(cl) != 'N/A')
          buildLegendItem('AVG', Colors.green, false, formatValue(cl)),
      ],
    );
  }

  Widget buildLegendItem(String label, Color color, bool isDashed, String? value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 8,
          height: 2,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              border: isDashed ? Border.all(color: color, width: 1) : null,
            ),
            child: isDashed
                ? CustomPaint(painter: DashedLinePainter(color: color))
                : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.colorBlack)),
        const SizedBox(width: 8),
        Text(value ?? 'N/A',
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.colorBlack,
              fontWeight: FontWeight.w500,
            )),
      ],
    );
  }

  // ---------- Y scale cache/public ----------
  @override
  double getMaxY() {
    if (_cachedInterval == null) _getInterval();
    return _cachedMaxY ?? 0.0;
  }

  @override
  double getMinY() {
    if (_cachedInterval == null) _getInterval();
    return _cachedMinY ?? 0.0;
  }

  // ---------- Y scale compute ----------
  double _getInterval() {
    const divisions = 5; // -> 6 ticks
    final minSel = 0.0;
    final maxSel = _sel(
          controlChartStats?.yAxisRange?.maxYcdeMrChart,
          controlChartStats?.yAxisRange?.maxYcdtMrChart,
          controlChartStats?.yAxisRange?.maxYcompoundLayerMrChart,
        ) ??
        0.0;

    if (maxSel <= minSel) {
      _cachedMinY = minSel;
      _cachedMaxY = minSel + divisions;
      _cachedInterval = 1.0;
      return _cachedInterval!;
    }

    final ideal = (maxSel - minSel) / divisions;
    double interval = _niceStepCeil(ideal);

    double minY = (minSel / interval).floor() * interval;
    double maxY = minY + divisions * interval;

    while (maxY < maxSel - 1e-12) {
      interval = _nextNiceStep(interval);
      minY = (minSel / interval).floor() * interval;
      maxY = minY + divisions * interval;
    }

    _cachedMinY = minY;
    _cachedMaxY = maxY;
    _cachedInterval = interval;
    return interval;
  }

  // ---------- Y step helpers ----------
  double _niceStepCeil(double x) {
    if (x <= 0 || x.isNaN || x.isInfinite) return 1.0;
    final exp = (math.log(x) / math.log(10)).floor();
    final mag = math.pow(10.0, exp).toDouble();
    final mant = x / mag;
    if (mant <= 0.025) return 0.025 * mag;
    if (mant <= 0.050) return 0.050 * mag;
    if (mant <= 0.075) return 0.075 * mag;
    if (mant <= 0.125) return 0.125 * mag;
    if (mant <= 0.25) return 0.25 * mag;
    if (mant <= 0.5) return 0.5 * mag;
    if (mant <= 1.0) return 1.0 * mag;
    if (mant <= 1.25) return 1.25 * mag;
    if (mant <= 1.5) return 1.5 * mag;
    if (mant <= 2.0) return 2.0 * mag;
    if (mant <= 2.5) return 2.5 * mag;
    if (mant <= 3.0) return 3.0 * mag;
    if (mant <= 4.0) return 4.0 * mag;
    if (mant <= 5.0) return 5.0 * mag;
    return 10.0 * mag;
  }

  double _nextNiceStep(double step) {
    final exp = (math.log(step) / math.log(10)).floor();
    final mag = math.pow(10.0, exp).toDouble();
    final mant = step / mag;
    if (mant <= 0.025) return 0.050 * mag;
    if (mant <= 0.050) return 0.075 * mag;
    if (mant <= 0.075) return 0.125 * mag;
    if (mant <= 0.125) return 0.25 * mag;
    if (mant <= 0.25) return 0.5 * mag;
    if (mant <= 0.5) return 1.0 * mag;
    if (mant < 1.0) return 2.0 * mag;
    if (mant < 2.0) return 2.5 * mag;
    if (mant < 2.5) return 3.0 * mag;
    if (mant < 3.0) return 3.5 * mag;
    if (mant < 5.0) return 10.0 * mag;
    return 10.0 * mag;
  }

  // ---------- X helpers ----------
  double _xIntervalForCount(int n) {
    if (n <= 8) return 1;
    if (n <= 12) return 2;
    if (n <= 24) return 3;
    return (n / 8).floorToDouble().clamp(1, 10);
  }

  String formatValue(double? value) {
    if (value == null || value == 0.0) return 'N/A';
    return value.toStringAsFixed(2);
  }
}
