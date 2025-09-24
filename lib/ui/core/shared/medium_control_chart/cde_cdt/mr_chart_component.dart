import 'dart:math' as math;
import 'package:control_chart/domain/models/chart_data_point.dart';
import 'package:control_chart/domain/models/control_chart_stats.dart';
import 'package:control_chart/domain/models/setting.dart';
import 'package:control_chart/domain/types/chart_component.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';
import 'package:control_chart/ui/core/shared/dashed_line_painter.dart' show DashedLinePainter;
import 'package:control_chart/ui/core/shared/medium_control_chart/surface_hardness/help.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// CDE/CDT MR Chart — Surface-like time axis with xStart/xEnd
class MrChartComponent extends StatelessWidget implements ChartComponent {
  final List<ChartDataPointCdeCdt>? dataPoints;
  final ControlChartStats? controlChartStats;
  final Color? dataLineColor;
  final Color? backgroundColor;
  final double? height;
  final double? width;

  /// time window (Surface-like)
  final DateTime xStart;
  final DateTime xEnd;

  MrChartComponent({
    super.key,
    this.dataPoints,
    this.controlChartStats,
    this.dataLineColor = AppColors.colorBrand,
    this.backgroundColor,
    this.height,
    this.width = 560,
    required this.xStart,
    required this.xEnd,
  });

  // cached Y scale
  double? _cachedMinY;
  double? _cachedMaxY;
  double? _cachedInterval;

  // pick by selected attribute
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

  List<ChartDataPointCdeCdt> get _pointsInWindow {
    final src = dataPoints ?? const <ChartDataPointCdeCdt>[];
    if (src.isEmpty) return const <ChartDataPointCdeCdt>[];

    final startUs = xStart.millisecondsSinceEpoch;
    final endUs = xEnd.millisecondsSinceEpoch;
    final lo = math.min(startUs, endUs).toDouble();
    final hi = math.max(startUs, endUs).toDouble();

    final filtered = src.where((p) {
      final t = p.collectDate.millisecondsSinceEpoch.toDouble();
      return t >= lo && t <= hi;
    }).toList();

    if (filtered.isEmpty) return filtered;

    // remove last index
    return filtered.sublist(0, filtered.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    final double minXv = xStart.millisecondsSinceEpoch.toDouble();
    final double maxXv = xEnd.millisecondsSinceEpoch.toDouble();
    final double safeRange = (maxXv - minXv).abs().clamp(1.0, double.infinity);

    final int desiredTick = (controlChartStats?.xTick ?? 6).clamp(2, 24);
    final double tickInterval = safeRange / (desiredTick - 1);

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
                minX: minXv,
                maxX: maxXv,
                minY: getMinY(),
                maxY: getMaxY(),
                gridData: buildGridData(minXv, maxXv, tickInterval),
                titlesData: buildTitlesData(minXv, maxXv, tickInterval),
                borderData: buildBorderData(),
                extraLinesData: buildControlLines(),
                lineBarsData: buildLineBarsData(),
                lineTouchData: buildTouchData(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----- GRID / TITLES / BORDER -----

  @override
  FlGridData buildGridData(double? minX, double? maxX, double? tickInterval) {
    return FlGridData(
      show: true,
      drawHorizontalLine: true,
      drawVerticalLine: true,
      horizontalInterval: _getInterval(),
      verticalInterval: tickInterval ?? 1,
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
  FlTitlesData buildTitlesData(double? minX, double? maxX, double? tickInterval) {
    final double minXv = minX ?? xStart.millisecondsSinceEpoch.toDouble();
    final double maxXv = maxX ?? xEnd.millisecondsSinceEpoch.toDouble();
    final PeriodType periodType = controlChartStats?.periodType ?? PeriodType.ONE_MONTH;
    // final double range = (maxXv - minXv).abs().clamp(1.0, double.infinity);
    final df = DateFormat('dd/MM');

    // final int desiredTick = (controlChartStats?.xTick ?? 6).clamp(2, 24);
    final double step = getXInterval(periodType, minXv, maxXv);

    // final shownLabels = <String>{};

    Widget bottomLabel(double value, TitleMeta meta) {
      final dt = DateTime.fromMillisecondsSinceEpoch(value.round(), isUtc: true);
      final text = df.format(dt);
      // if (!shownLabels.add(text)) return const SizedBox.shrink();

      return SideTitleWidget(
        meta: meta,
        space: 8,
        child: Transform.rotate(
          angle: -30 * math.pi / 180,
          child: Text(
            text,
            style: const TextStyle(fontSize: 8, color: AppColors.colorBlack),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 24,
          interval: _getInterval(),
          getTitlesWidget: (v, _) => Text(
            v.toStringAsFixed(2),
            style: const TextStyle(color: AppColors.colorBlack, fontSize: 8),
          ),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 24,
          interval: step,
          getTitlesWidget: bottomLabel,
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
      border: Border.all(color: Colors.black54, width: 1),
    );
  }

  // ----- CONTROL LINES -----

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

  // ----- LINE & TOUCH -----

  @override
  List<LineChartBarData> buildLineBarsData() {
    final pts = _pointsInWindow;
    if (pts.length < 2) {
      return [
        LineChartBarData(spots: const [], color: dataLineColor, barWidth: 2),
      ];
    }

    // MR at time i uses value[i] and value[i-1]; plot at timestamp of point[i]
    final spots = <FlSpot>[];
    for (var i = 1; i < pts.length; i++) {
      final t = pts[i].collectDate.millisecondsSinceEpoch.toDouble();
      spots.add(FlSpot(t, pts[i].mrValue));
    }

    final ucl = _sel(
          controlChartStats?.cdeControlLimitMRChart?.ucl,
          controlChartStats?.cdtControlLimitMRChart?.ucl,
          controlChartStats?.compoundLayerControlLimitMRChart?.ucl,
        ) ??
        0.0;

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
            Color dotColor = dataLineColor ?? AppColors.colorBrand;
            final v = spot.y;
            if (ucl > 0 && v > ucl) {
              dotColor = Colors.orange;
            }
            return FlDotCirclePainter(
              radius: 3.5,
              color: dotColor.withValues(alpha: 0.7),
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
    final pts = _pointsInWindow;
    final map = {
      for (final p in pts) p.collectDate.millisecondsSinceEpoch.toDouble(): p
    };

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
            // For MR we plotted at time[i]; use map lookup
            final p = map[barSpot.x];
            final mr = barSpot.y;
            if (p == null) return null;
            return LineTooltipItem(
              "ค่า: ${mr.isNaN ? '-' : mr.toStringAsFixed(3)}\n",
              AppTypography.textBody3W,
              textAlign: TextAlign.left,
            );
          }).whereType<LineTooltipItem>().toList();
        },
      ),
    );
  }

  // ----- LEGEND -----

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
            child: isDashed ? CustomPaint(painter: DashedLinePainter(color: color)) : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.colorBlack)),
        const SizedBox(width: 4),
        Text(value ?? 'N/A',
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.colorBlack,
              fontWeight: FontWeight.w500,
            )),
      ],
    );
  }

  // ----- Y SCALE -----

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

  String formatValue(double? value) {
    if (value == null || value == 0.0) return 'N/A';
    return value.toStringAsFixed(2);
  }
}
