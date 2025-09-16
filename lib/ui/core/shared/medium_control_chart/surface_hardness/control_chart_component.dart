import 'dart:math' as math;
import 'package:control_chart/domain/models/chart_data_point.dart';
import 'package:control_chart/domain/models/control_chart_stats.dart';
import 'package:control_chart/domain/types/chart_component.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';
import 'package:control_chart/ui/core/shared/dashed_line_painter.dart' show DashedLinePainter;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ControlChartComponent extends StatelessWidget implements ChartComponent {
  final List<ChartDataPoint>? dataPoints;
  final ControlChartStats? controlChartStats;
  final Color? dataLineColor;
  final Color? backgroundColor;
  final double? height;
  final double? width;

  /// ช่วงเวลาที่ต้องการแสดง (อ้างอิงจาก HomeContent)
  final DateTime xStart;
  final DateTime xEnd;

  ControlChartComponent({
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

  // ---------- คำนวณ/แคชสเกลแกน Y ----------
  double? _cachedMinY;
  double? _cachedMaxY;
  double? _cachedInterval;

  // ---------- จุดที่อยู่ในหน้าต่างเวลา ----------
  List<ChartDataPoint> get _pointsInWindow {
    final src = dataPoints ?? const <ChartDataPoint>[];
    if (src.isEmpty) return const <ChartDataPoint>[];
    final startUs = xStart.microsecondsSinceEpoch;
    final endUs = xEnd.microsecondsSinceEpoch;
    final lo = math.min(startUs, endUs).toDouble();
    final hi = math.max(startUs, endUs).toDouble();

    return src
        .where((p) {
          final t = p.collectDate.microsecondsSinceEpoch.toDouble();
          return t >= lo && t <= hi;
        })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // final visible = _pointsInWindow;
    // if (visible.isEmpty) {
    //   return const Center(child: Text('ไม่พบข้อมูล'));
    // }

    // ช่วงเวลา (µs)
    final double minXv = xStart.microsecondsSinceEpoch.toDouble();
    final double maxXv = xEnd.microsecondsSinceEpoch.toDouble();
    final double safeRange = (maxXv - minXv).abs().clamp(1.0, double.infinity);

    // จำนวน tick ที่ต้องการโชว์ (อย่างน้อย 2 จะมีหัว-ท้าย, ถ้าน้อยกว่านั้นบังคับเป็น 2)
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

  // ---------------------------------------------------------------------------
  // GRID / TITLES / BORDER
  // ---------------------------------------------------------------------------

  @override
  FlGridData buildGridData(double? minX, double? maxX, double? tickInterval) {
    return FlGridData(
      show: true,
      drawHorizontalLine: true,
      drawVerticalLine: true,
      horizontalInterval: _getInterval(),   // ให้ grid แนว Y สอดคล้องกับ tick Y
      verticalInterval: tickInterval ?? 1,  // ให้ grid แนว X กระจายตามช่วงเวลา
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
    final double minXv = minX ?? xStart.microsecondsSinceEpoch.toDouble();
    final double maxXv = maxX ?? xEnd.microsecondsSinceEpoch.toDouble();
    final double range = (maxXv - minXv).abs().clamp(1.0, double.infinity);

    final ticks = _labelEpochsInWindow(minXv, maxXv);
    final df = DateFormat('dd-MM');

    final int desiredTick = (controlChartStats?.xTick ?? 6).clamp(2, 24);
    final double step = (tickInterval ?? (range / (desiredTick - 1))).abs();
    final double tol  = step * 0.49; // tolerance to snap to nearest tick

    // ✅ ensure unique strings per build
    final shownLabels = <String>{};

    Widget bottomLabel(double value, TitleMeta meta) {
      // find nearest precomputed tick
      double? nearest;
      double best = double.infinity;
      for (final t in ticks) {
        final d = (value - t).abs();
        if (d < best) { best = d; nearest = t; }
      }
      if (nearest == null || best > tol) return const SizedBox.shrink();

      final dt = DateTime.fromMicrosecondsSinceEpoch(nearest.round(), isUtc: true);
      final text = df.format(dt);

      // ✅ skip duplicate strings
      if (!shownLabels.add(text)) return const SizedBox.shrink();

      return SideTitleWidget(
        meta: meta,
        space: 8,
        child: Transform.rotate(
          angle: -30 * math.pi / 180,
          child: Text(text,
            style: const TextStyle(fontSize: 8, color: Colors.black54),
            overflow: TextOverflow.ellipsis),
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
            v.toStringAsFixed(0),
            style: const TextStyle(color: Colors.black54, fontSize: 8),
          ),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 32,
          interval: step,
          getTitlesWidget: bottomLabel,
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }


  List<double> _labelEpochsInWindow(double minXv, double maxXv) {
    final double lo = math.min(minXv, maxXv);
    final double hi = math.max(minXv, maxXv);

    final List<DateTime> candidates = [
      DateTime.fromMicrosecondsSinceEpoch(lo.round(), isUtc: true),
      DateTime.fromMicrosecondsSinceEpoch(hi.round(), isUtc: true),
    ];

    final raw = controlChartStats?.xAxisMediumLabel;
    if (raw! is List) {
      for (final e in raw) {
        DateTime? dt;
        if (e is DateTime) {
          dt = e;
        } else if (e is String) {
          // ✅ parse the ISO string directly (no .toIso8601String() on String)
          try { dt = DateTime.parse(e.toIso8601String()); } catch (_) {}
        }
        if (dt == null) continue;

        final us = dt.microsecondsSinceEpoch.toDouble();
        if (us >= lo && us <= hi) {
          candidates.add(dt.toUtc());
        }
      }
    }

    // Dedup by the *text label* you actually show
    final fmt = DateFormat('dd-MM'); // change if you format differently
    candidates.sort((a, b) => a.compareTo(b));

    final seen = <String>{};
    final out = <double>[];
    for (final dt in candidates) {
      final key = fmt.format(dt);     // label string
      if (seen.add(key)) {
        out.add(dt.microsecondsSinceEpoch.toDouble());
      }
    }
    return out;
  }


  @override
  FlBorderData buildBorderData() {
    return FlBorderData(
      show: true,
      border: Border.all(color: Colors.black54, width: 1),
    );
  }

  // ---------------------------------------------------------------------------
  // CONTROL LINES
  // ---------------------------------------------------------------------------

  @override
  ExtraLinesData buildControlLines() {
    return ExtraLinesData(
      extraLinesOnTop: false,
      horizontalLines: [
        if ((controlChartStats?.specAttribute?.surfaceHardnessUpperSpec ?? 0.0) > 0.0)
          HorizontalLine(
            y: controlChartStats!.specAttribute!.surfaceHardnessUpperSpec!,
            color: Colors.red.shade400,
            strokeWidth: 2,
          ),
        HorizontalLine(
          y: controlChartStats?.controlLimitIChart?.ucl ?? 0.0,
          color: Colors.amberAccent,
          strokeWidth: 1.5,
        ),
        if ((controlChartStats?.specAttribute?.surfaceHardnessTarget ?? 0.0) != 0.0)
          HorizontalLine(
            y: controlChartStats!.specAttribute!.surfaceHardnessTarget!,
            color: Colors.deepPurple.shade300,
            strokeWidth: 1.5,
          ),
        HorizontalLine(
          y: controlChartStats?.average ?? 0.0,
          color: AppColors.colorSuccess1,
          strokeWidth: 2,
        ),
        HorizontalLine(
          y: controlChartStats?.controlLimitIChart?.lcl ?? 0.0,
          color: Colors.amberAccent,
          strokeWidth: 1.5,
        ),
        if ((controlChartStats?.specAttribute?.surfaceHardnessLowerSpec ?? 0.0) > 0.0)
          HorizontalLine(
            y: controlChartStats!.specAttribute!.surfaceHardnessLowerSpec!,
            color: Colors.red.shade400,
            strokeWidth: 2,
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // LINE & TOUCH
  // ---------------------------------------------------------------------------

  @override
  List<LineChartBarData> buildLineBarsData() {
    final pts = _pointsInWindow;
    if (pts.isEmpty) {
      return [
        LineChartBarData(spots: const [], color: dataLineColor, barWidth: 2),
      ];
    }

    final minXv = xStart.microsecondsSinceEpoch.toDouble();
    final maxXv = xEnd.microsecondsSinceEpoch.toDouble();

    final spots = pts
        .map((p) => FlSpot(
              p.collectDate.microsecondsSinceEpoch.toDouble(),
              p.value,
            ))
        .where((s) => s.x >= math.min(minXv, maxXv) && s.x <= math.max(minXv, maxXv))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));

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
            final v = spot.y;
            Color dotColor = dataLineColor ?? AppColors.colorBrand;
            final upperSpec = controlChartStats?.specAttribute?.surfaceHardnessUpperSpec ?? 0.0;
            final lowerSpec = controlChartStats?.specAttribute?.surfaceHardnessLowerSpec ?? 0.0;
            final ucl = controlChartStats?.controlLimitIChart?.ucl ?? 0.0;
            final lcl = controlChartStats?.controlLimitIChart?.lcl ?? 0.0;

            if ((upperSpec > 0 && v > upperSpec) || (lowerSpec > 0 && v < lowerSpec)) {
              dotColor = Colors.red;
            } else if ((ucl > 0 && v > ucl) || (lcl > 0 && v < lcl)) {
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
    final points = _pointsInWindow;
    final Map<double, ChartDataPoint> map = {
      for (final p in points) p.collectDate.microsecondsSinceEpoch.toDouble(): p
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
            final p = map[barSpot.x];
            if (p == null) return null;

            return LineTooltipItem(
              "วันที่: ${p.fullLabel}\n"
              "ค่า: ${barSpot.y.toStringAsFixed(3)}\n"
              "เตา: ${p.furnaceNo}\n"
              "เลขแมต: ${p.matNo}",
              AppTypography.textBody3W,
              textAlign: TextAlign.left,
            );
          }).whereType<LineTooltipItem>().toList();
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LEGEND
  // ---------------------------------------------------------------------------

  @override
  Widget buildLegend() {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      direction: Axis.horizontal,
      alignment: WrapAlignment.spaceEvenly,
      children: [
        if (formatValue(controlChartStats?.specAttribute?.surfaceHardnessUpperSpec) != 'N/A')
          buildLegendItem('Spec', Colors.red, false,
              formatValue(controlChartStats?.specAttribute?.surfaceHardnessUpperSpec)),
        if (formatValue(controlChartStats?.controlLimitIChart?.ucl) != 'N/A')
          buildLegendItem('UCL', Colors.orange, false,
              formatValue(controlChartStats?.controlLimitIChart?.ucl)),
        if (formatValue(controlChartStats?.specAttribute?.surfaceHardnessTarget) != 'N/A')
          buildLegendItem('Target', Colors.deepPurple.shade300, false,
              formatValue(controlChartStats?.specAttribute?.surfaceHardnessTarget)),
        if (formatValue(controlChartStats?.average) != 'N/A')
          buildLegendItem('AVG', Colors.green, false,
              formatValue(controlChartStats?.average)),
        if (formatValue(controlChartStats?.controlLimitIChart?.lcl) != 'N/A')
          buildLegendItem('LCL', Colors.orange, false,
              formatValue(controlChartStats?.controlLimitIChart?.lcl)),
        if (formatValue(controlChartStats?.specAttribute?.surfaceHardnessLowerSpec) != 'N/A')
          buildLegendItem('Spec', Colors.red, false,
              formatValue(controlChartStats?.specAttribute?.surfaceHardnessLowerSpec)),
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

  // ---------------------------------------------------------------------------
  // Y SCALE (คงเดิม)
  // ---------------------------------------------------------------------------

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
    final spotMin = controlChartStats?.yAxisRange?.minYsurfaceHardnessControlChart ?? 0.0;
    final spotMax = controlChartStats?.yAxisRange?.maxYsurfaceHardnessControlChart ?? spotMin;

    if (spotMax <= spotMin) {
      _cachedMinY = spotMin;
      _cachedMaxY = spotMin + divisions;
      _cachedInterval = 1.0;
      return _cachedInterval!;
    }

    final ideal = (spotMax - spotMin) / divisions;
    double interval = _niceStepCeil(ideal);

    double minY = (spotMin / interval).floor() * interval;
    double maxY = minY + divisions * interval;

    while (maxY < spotMax - 1e-12) {
      interval = _nextNiceStep(interval);
      minY = (spotMin / interval).floor() * interval;
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

  // ---------------------------------------------------------------------------
  // UTIL
  // ---------------------------------------------------------------------------

  String formatValue(double? value) {
    if (value == null || value == 0.0) return 'N/A';
    return value.toStringAsFixed(2);
  }
}
