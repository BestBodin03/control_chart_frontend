// lib/ui/core/shared/medium_control_chart/cde_cdt/control_chart_component.dart
import 'dart:developer' as dev;
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
  final List<ChartDataPointCdeCdt>? dataPoints; // <-- windowed by template
  final ControlChartStats? controlChartStats;
  final Color? dataLineColor;
  final Color? backgroundColor;
  final double? height;
  final double? width;

  ControlChartComponent({
    super.key,
    this.dataPoints,
    this.controlChartStats,
    this.dataLineColor = AppColors.colorBrand,
    this.backgroundColor,
    this.height,
    this.width = 560,
  });

  // ---- Y cache ----
  double? _cachedMinY;
  double? _cachedMaxY;
  double? _cachedInterval;

  // visible window = as passed from template
  List<ChartDataPointCdeCdt> get _visiblePoints =>
      dataPoints ?? const <ChartDataPointCdeCdt>[];

  // ---------- pick per selection ----------
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

  // ---------- time helpers ----------
  double _minXms(List<ChartDataPointCdeCdt> v) =>
      v.first.collectDate.millisecondsSinceEpoch.toDouble();
  double _maxXms(List<ChartDataPointCdeCdt> v) =>
      v.last.collectDate.millisecondsSinceEpoch.toDouble();

  ({int tickCount, double stepMs}) _xTickAndStep(List<ChartDataPointCdeCdt> v) {
    final double minX = _minXms(v);
    final double maxX = _maxXms(v);
    final double range = (maxX - minX).abs();

    // rule: total ≤ 30 → 6 ticks, else → API xTick (4/6)
    final int total = dataPoints?.length ?? v.length;
    final int apiTick = controlChartStats?.xTick ?? 6;
    final int tickCount = (total <= 30 ? 6 : apiTick).clamp(2, 12);
    final double stepMs = (tickCount <= 1) ? range : range / (tickCount - 1);

    dev.log('[CDE/CDT COMP] domain '
        'min=${DateTime.fromMillisecondsSinceEpoch(minX.toInt())} '
        'max=${DateTime.fromMillisecondsSinceEpoch(maxX.toInt())} '
        'rangeMs=$range tickCount=$tickCount stepMs=$stepMs');

    return (tickCount: tickCount, stepMs: stepMs);
  }

  /// split into segments when time gap > gapMs
  List<List<ChartDataPointCdeCdt>> _segmentsByGap(
    List<ChartDataPointCdeCdt> v,
    double gapMs,
  ) {
    if (v.isEmpty) return const [];
    final out = <List<ChartDataPointCdeCdt>>[];
    var cur = <ChartDataPointCdeCdt>[v.first];
    for (int i = 1; i < v.length; i++) {
      final prev = v[i - 1].collectDate.millisecondsSinceEpoch.toDouble();
      final now = v[i].collectDate.millisecondsSinceEpoch.toDouble();
      if ((now - prev) > gapMs) {
        out.add(cur);
        cur = <ChartDataPointCdeCdt>[];
      }
      cur.add(v[i]);
    }
    if (cur.isNotEmpty) out.add(cur);
    return out;
  }

  /// nearest visible point by time
  ChartDataPointCdeCdt _nearestByTime(List<ChartDataPointCdeCdt> v, double xMs) {
    int lo = 0, hi = v.length - 1;
    while (lo < hi) {
      final mid = (lo + hi) >> 1;
      final midMs = v[mid].collectDate.millisecondsSinceEpoch.toDouble();
      if (midMs < xMs) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    int idx = lo;
    if (lo > 0) {
      final leftMs = v[lo - 1].collectDate.millisecondsSinceEpoch.toDouble();
      final rightMs = v[lo].collectDate.millisecondsSinceEpoch.toDouble();
      if ((xMs - leftMs).abs() <= (rightMs - xMs).abs()) idx = lo - 1;
    }
    return v[idx];
  }

  // ---------------- grid / titles / border ----------------
  @override
  FlGridData buildGridData() {
    final v = _visiblePoints;
    final double verticalStep = v.isEmpty ? 1.0 : _xTickAndStep(v).stepMs;

    return FlGridData(
      show: true,
      drawHorizontalLine: true,
      drawVerticalLine: true,
      horizontalInterval: _getInterval(), // Y
      verticalInterval: verticalStep,     // X = time(ms)
      getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey.shade100, strokeWidth: 0.5),
      getDrawingVerticalLine:   (_) => FlLine(color: Colors.grey.shade100, strokeWidth: 0.5),
    );
  }

  @override
  FlTitlesData buildTitlesData() {
    final v = _visiblePoints;
    if (v.isEmpty) {
      return const FlTitlesData(
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      );
    }

    final double stepMs = _xTickAndStep(v).stepMs;

    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 24,
          interval: _getInterval(),
          getTitlesWidget: (value, _) => Text(
            value.toStringAsFixed(2),
            style: const TextStyle(color: Colors.black54, fontSize: 8),
          ),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 32,
          interval: stepMs, // ✅ time-based ticks
          getTitlesWidget: (value, meta) {
            final d = DateTime.fromMillisecondsSinceEpoch(value.round());
            return SideTitleWidget(
              meta: meta,
              space: 8,
              child: Transform.rotate(
                angle: -30 * math.pi / 180,
                child: Text(
                  DateFormat('dd/MM').format(d),
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
  FlBorderData buildBorderData() =>
      FlBorderData(show: true, border: Border.all(color: Colors.black54, width: 1));

  // ---------------- control lines (I-Chart) ----------------
  @override
  ExtraLinesData buildControlLines() {
    final specUsl = _sel(
      controlChartStats?.specAttribute?.cdeUpperSpec,
      controlChartStats?.specAttribute?.cdtUpperSpec,
      controlChartStats?.specAttribute?.compoundLayerUpperSpec,
    );
    final specLsl = _sel(
      controlChartStats?.specAttribute?.cdeLowerSpec,
      controlChartStats?.specAttribute?.cdtLowerSpec,
      controlChartStats?.specAttribute?.compoundLayerLowerSpec,
    );
    final target = _sel(
      controlChartStats?.specAttribute?.cdeTarget,
      controlChartStats?.specAttribute?.cdtTarget,
      controlChartStats?.specAttribute?.compoundLayerTarget,
    );
    final ucl = _sel(
      controlChartStats?.cdeControlLimitIChart?.ucl,
      controlChartStats?.cdtControlLimitIChart?.ucl,
      controlChartStats?.compoundLayerControlLimitIChart?.ucl,
    );
    final lcl = _sel(
      controlChartStats?.cdeControlLimitIChart?.lcl,
      controlChartStats?.cdtControlLimitIChart?.lcl,
      controlChartStats?.compoundLayerControlLimitIChart?.lcl,
    );
    final avg = _sel(
      controlChartStats?.cdeAverage,
      controlChartStats?.cdtAverage,
      controlChartStats?.compoundLayerAverage,
    );

    return ExtraLinesData(
      extraLinesOnTop: false,
      horizontalLines: [
        if ((specUsl ?? 0) > 0)
          HorizontalLine(y: specUsl!, color: Colors.red.shade400, strokeWidth: 2),
        if (ucl != null)
          HorizontalLine(y: ucl, color: Colors.amberAccent, strokeWidth: 1.5),
        if ((target ?? 0) != 0)
          HorizontalLine(y: target!, color: Colors.deepPurple.shade300, strokeWidth: 1.5),
        if (avg != null)
          HorizontalLine(y: avg, color: AppColors.colorSuccess1, strokeWidth: 2),
        if (lcl != null)
          HorizontalLine(y: lcl, color: Colors.amberAccent, strokeWidth: 1.5),
        if ((specLsl ?? 0) > 0)
          HorizontalLine(y: specLsl!, color: Colors.red.shade400, strokeWidth: 2),
      ],
    );
  }

  // ---------------- line & touch ----------------
  @override
  List<LineChartBarData> buildLineBarsData() {
    final v = _visiblePoints;
    if (v.isEmpty) return const [];

    // จุดตามเวลา
    final stepMs = _xTickAndStep(v).stepMs;
    final segments = _segmentsByGap(v, stepMs * 1.5);

    final specUsl = _sel(
      controlChartStats?.specAttribute?.cdeUpperSpec,
      controlChartStats?.specAttribute?.cdtUpperSpec,
      controlChartStats?.specAttribute?.compoundLayerUpperSpec,
    ) ?? 0.0;
    final specLsl = _sel(
      controlChartStats?.specAttribute?.cdeLowerSpec,
      controlChartStats?.specAttribute?.cdtLowerSpec,
      controlChartStats?.specAttribute?.compoundLayerLowerSpec,
    ) ?? 0.0;
    final ucl = _sel(
      controlChartStats?.cdeControlLimitIChart?.ucl,
      controlChartStats?.cdtControlLimitIChart?.ucl,
      controlChartStats?.compoundLayerControlLimitIChart?.ucl,
    ) ?? 0.0;
    final lcl = _sel(
      controlChartStats?.cdeControlLimitIChart?.lcl,
      controlChartStats?.cdtControlLimitIChart?.lcl,
      controlChartStats?.compoundLayerControlLimitIChart?.lcl,
    ) ?? 0.0;

    final bars = <LineChartBarData>[];
    for (final seg in segments) {
      if (seg.isEmpty) continue;

      final spots = seg.map((p) => FlSpot(
            p.collectDate.millisecondsSinceEpoch.toDouble(),
            p.value,
          )).toList();

      if (spots.isNotEmpty) {
        dev.log('[CDE/CDT COMP] segment '
            'minX=${DateTime.fromMillisecondsSinceEpoch(spots.first.x.toInt())} '
            'maxX=${DateTime.fromMillisecondsSinceEpoch(spots.last.x.toInt())} '
            'count=${spots.length}');
      }

      bars.add(
        LineChartBarData(
          spots: spots,
          isCurved: false,
          color: dataLineColor,
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, _, __, ___) {
              final vVal = spot.y;
              Color dotColor = dataLineColor!;
              if (((specUsl > 0) && vVal > specUsl) || ((specLsl > 0) && vVal < specLsl)) {
                dotColor = Colors.red;
              } else if ((ucl > 0 && vVal > ucl) || (lcl > 0 && vVal < lcl)) {
                dotColor = Colors.orange;
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
      );
    }

    return bars;
  }

  @override
  LineTouchData buildTouchData() {
    final v = _visiblePoints;
    return LineTouchData(
      handleBuiltInTouches: true,
      touchTooltipData: LineTouchTooltipData(
        maxContentWidth: 150,
        getTooltipColor: (_) => AppColors.colorBrand.withValues(alpha: 0.9),
        tooltipBorderRadius: BorderRadius.circular(8),
        fitInsideHorizontally: true,
        fitInsideVertically: true,
        tooltipMargin: 8,
        getTooltipItems: (touched) {
          return touched.map((barSpot) {
            final p = _nearestByTime(v, barSpot.x); // ✅ match by time
            return LineTooltipItem(
              "วันที่: ${p.fullLabel}\n"
              "ค่า: ${p.value.toStringAsFixed(3)}\n"
              "เตา: ${p.furnaceNo ?? '-'}\n"
              "เลขแมต: ${p.matNo ?? '-'}",
              AppTypography.textBody3W,
              textAlign: TextAlign.left,
            );
          }).toList();
        },
      ),
    );
  }

  @override
  Widget buildLegend() {
    final specUsl = _sel(
      controlChartStats?.specAttribute?.cdeUpperSpec,
      controlChartStats?.specAttribute?.cdtUpperSpec,
      controlChartStats?.specAttribute?.compoundLayerUpperSpec,
    );
    final target = _sel(
      controlChartStats?.specAttribute?.cdeTarget,
      controlChartStats?.specAttribute?.cdtTarget,
      controlChartStats?.specAttribute?.compoundLayerTarget,
    );
    final avg = _sel(
      controlChartStats?.cdeAverage,
      controlChartStats?.cdtAverage,
      controlChartStats?.compoundLayerAverage,
    );
    final ucl = _sel(
      controlChartStats?.cdeControlLimitIChart?.ucl,
      controlChartStats?.cdtControlLimitIChart?.ucl,
      controlChartStats?.compoundLayerControlLimitIChart?.ucl,
    );
    final lcl = _sel(
      controlChartStats?.cdeControlLimitIChart?.lcl,
      controlChartStats?.cdtControlLimitIChart?.lcl,
      controlChartStats?.compoundLayerControlLimitIChart?.lcl,
    );
    final specLsl = _sel(
      controlChartStats?.specAttribute?.cdeLowerSpec,
      controlChartStats?.specAttribute?.cdtLowerSpec,
      controlChartStats?.specAttribute?.compoundLayerLowerSpec,
    );

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      direction: Axis.horizontal,
      alignment: WrapAlignment.spaceEvenly,
      children: [
        if (formatValue(specUsl) != 'N/A')
          buildLegendItem('Spec', Colors.red, false, formatValue(specUsl)),
        if (formatValue(ucl) != 'N/A')
          buildLegendItem('UCL', Colors.orange, false, formatValue(ucl)),
        if (formatValue(target) != 'N/A')
          buildLegendItem('Target', Colors.deepPurple.shade300, false, formatValue(target)),
        if (formatValue(avg) != 'N/A')
          buildLegendItem('AVG', Colors.green, false, formatValue(avg)),
        if (formatValue(lcl) != 'N/A')
          buildLegendItem('LCL', Colors.orange, false, formatValue(lcl)),
        if (formatValue(specLsl) != 'N/A')
          buildLegendItem('Spec', Colors.red, false, formatValue(specLsl)),
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
    final minSel = _sel(
          controlChartStats?.yAxisRange?.minYcdeControlChart,
          controlChartStats?.yAxisRange?.minYcdtControlChart,
          controlChartStats?.yAxisRange?.minYcompoundLayerControlChart,
        ) ??
        0.0;
    final maxSel = _sel(
          controlChartStats?.yAxisRange?.maxYcdeControlChart,
          controlChartStats?.yAxisRange?.maxYcdtControlChart,
          controlChartStats?.yAxisRange?.maxYcompoundLayerControlChart,
        ) ??
        minSel;

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

  String formatValue(double? value) {
    if (value == null || value == 0.0) return 'N/A';
    return value.toStringAsFixed(2);
  }

  // (unused build; chart is driven by template)
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
