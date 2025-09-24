import 'dart:math' as math;
import 'package:control_chart/domain/models/chart_data_point.dart';
import 'package:control_chart/domain/models/control_chart_stats.dart';
import 'package:control_chart/domain/models/setting.dart';
import 'package:control_chart/domain/types/chart_component.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// MR-Chart (Moving Range) with local Tooltip (no Overlay), quadrant placement.
class MrChartComponent extends StatefulWidget implements ChartComponent {
  final List<ChartDataPoint>? dataPoints;
  final ControlChartStats? controlChartStats;
  final Color? dataLineColor;
  final Color? backgroundColor;
  final double? height;
  final double? width;

  /// ช่วงเวลาที่ต้องการแสดง
  final DateTime xStart;
  final DateTime xEnd;

  const MrChartComponent({
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

  // ===== Legend =====
  @override
  Widget buildLegend() {
    String fmt(double? v) => (v == null || v == 0.0) ? 'N/A' : v.toStringAsFixed(2);
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      direction: Axis.horizontal,
      alignment: WrapAlignment.spaceEvenly,
      children: [
        if (fmt(controlChartStats?.controlLimitMRChart?.ucl) != 'N/A')
          _legendItem('UCL', Colors.orange, fmt(controlChartStats?.controlLimitMRChart?.ucl)),
        if (fmt(controlChartStats?.mrAverage) != 'N/A')
          _legendItem('AVG', Colors.green, fmt(controlChartStats?.mrAverage)),
      ],
    );
  }

  Widget _legendItem(String label, Color color, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 8, height: 2, child: DecoratedBox(decoration: BoxDecoration(color: color))),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.colorBlack, fontWeight: FontWeight.bold)),
        const SizedBox(width: 4),
        Text(value, style: const TextStyle(fontSize: 10, color: AppColors.colorBlack, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // ===== STUBs เพื่อให้ตอบ interface ChartComponent =====
  @override
  FlBorderData buildBorderData() => FlBorderData(show: false);
  @override
  ExtraLinesData buildControlLines() => const ExtraLinesData();
  @override
  FlGridData buildGridData(double? minX, double? maxX, double? tickInterval) => const FlGridData(show: false);
  @override
  List<LineChartBarData> buildLineBarsData() => const <LineChartBarData>[];
  @override
  FlTitlesData buildTitlesData(double? minX, double? maxX, double? tickInterval) => const FlTitlesData();
  @override
  LineTouchData buildTouchData() => const LineTouchData();
  @override
  double getMaxY() => 0;
  @override
  double getMinY() => 0;

  @override
  State<MrChartComponent> createState() => _MrChartComponentState();
}

class _MrChartComponentState extends State<MrChartComponent> {
  final GlobalKey _chartKey = GlobalKey();

  // cache Y
  double? _cachedMinY;
  double? _cachedMaxY;
  double? _cachedInterval;

  // Tooltip state (local)
  final ValueNotifier<_MrTip?> _tip = ValueNotifier<_MrTip?>(null);


  List<ChartDataPoint> get _pointsInWindow {
    final src = widget.dataPoints ?? const <ChartDataPoint>[];
    if (src.length <= 1) return const <ChartDataPoint>[];

    final lo = math.min(widget.xStart.millisecondsSinceEpoch,
                        widget.xEnd.millisecondsSinceEpoch).toDouble();
    final hi = math.max(widget.xStart.millisecondsSinceEpoch,
                        widget.xEnd.millisecondsSinceEpoch).toDouble();

    final filtered = src.where((p) {
      final t = p.collectDate.millisecondsSinceEpoch.toDouble();
      return t >= lo && t <= hi;
    }).toList()
      ..sort((a, b) => a.collectDate.compareTo(b.collectDate));

    if (filtered.length <= 1) return const <ChartDataPoint>[];
    // เอาแค่ length - 1 (ตัดตัวท้าย)
    return filtered.sublist(0, filtered.length - 1);
  }


  @override
  void dispose() {
    _tip.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double minXv = widget.xStart.millisecondsSinceEpoch.toDouble();
    final double maxXv = widget.xEnd.millisecondsSinceEpoch.toDouble();
    final double safeRange = (maxXv - minXv).abs().clamp(1.0, double.infinity);
    final int desiredTick = (widget.controlChartStats?.xTick ?? 6).clamp(2, 100);
    final double tickInterval = safeRange / (desiredTick - 1);

    return LayoutBuilder(
      builder: (context, constraints) {
        final Size chartSize = Size(
          widget.width  ?? constraints.maxWidth,
          widget.height ?? constraints.maxHeight,
        );

        return Container(
          height: chartSize.height,
          width: chartSize.width,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Chart
              Positioned.fill(
                child: KeyedSubtree(
                  key: _chartKey,
                  child: LineChart(
                    LineChartData(
                      minX: minXv,
                      maxX: maxXv,
                      minY: _getMinY(),
                      maxY: _getMaxY(),
                      gridData: _gridData(minXv, maxXv, tickInterval),
                      titlesData: _titlesData(minXv, maxXv),
                      borderData: _borderData(),
                      extraLinesData: _controlLines(),
                      lineBarsData: _lineBarsData(),
                      lineTouchData: _touchData(),
                    ),
                  ),
                ),
              ),

              // Tooltip (local-only, non-blocking) — quadrant placement + clamp
              ValueListenableBuilder<_MrTip?>(
                valueListenable: _tip,
              builder: (context, tip, _) {
                if (tip == null) return const SizedBox.shrink();

                const double maxWidth = 90;
                const double boxH = 120;
                const double dotR = 8;
                const double gap = 8;
                const double pad = 8;

                final dx = tip.local.dx;
                final dy = tip.local.dy;

                // available room checks
                final bool canAbove = dy - (dotR + gap + boxH) >= pad;
                final bool canBelow = dy + (dotR + gap + boxH) <= chartSize.height - pad;
                final bool canRight = dx + (dotR + gap + maxWidth) <= chartSize.width  - 6*pad;
                final bool canLeft  = dx - (dotR + gap + maxWidth) >= pad; // ✅ fix

                double left, top;

                if (canAbove) {
                  // above
                  left = dx - maxWidth / 2;
                  top  = dy - dotR - gap - boxH;
                  final hiX = chartSize.width - maxWidth - pad;
                  left = (hiX <= pad) ? (chartSize.width - maxWidth) / 2 : left.clamp(pad, hiX);
                } else if (canBelow) {
                  // below
                  left = dx - maxWidth / 2;
                  top  = dy + dotR + gap;
                  final hiX = chartSize.width - maxWidth - pad;
                  left = (hiX <= pad) ? (chartSize.width - maxWidth) / 2 : left.clamp(pad, hiX);
                } else if (canRight) {
                  // right (vertically centered)
                  left = dx + dotR + 4*gap;
                  top  = dy - boxH / 2;
                  final hiY = chartSize.height - boxH - pad;
                  top = (hiY <= pad) ? (chartSize.height - boxH) / 2 : top.clamp(pad, hiY);
                } else if (canLeft) {
                  // left (vertically centered)
                  left = dx - dotR - gap - maxWidth;
                  top  = dy - boxH / 2;
                  final hiY = chartSize.height - boxH - pad;
                  top = (hiY <= pad) ? (chartSize.height - boxH) / 2 : top.clamp(pad, hiY);
                } else {
                  // very tight: center in the box
                  left = (chartSize.width  - maxWidth) / 2;
                  top  = (chartSize.height - boxH) / 2;
                }

                // final clamp (safety)
                final hiX = chartSize.width - maxWidth - pad;
                final hiY = chartSize.height - boxH - pad;
                if (hiX > pad) left = left.clamp(pad, hiX);
                if (hiY > pad) top  = top.clamp(pad, hiY);

                return Positioned(
                  left: left,
                  top: top,
                  width: maxWidth,
                  child: IgnorePointer(
                    ignoring: true,
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.colorBrand.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          textAlign: TextAlign.center,
                          tip.valueStr,
                          style: AppTypography.textBody4WBold,),
                      ),
                    ),
                  ),
                );
              },
              ),
            ],
          ),
        );
      },
    );
  }

  // --------------------- GRID / TITLES / BORDER ---------------------

  FlGridData _gridData(double? minX, double? maxX, double? tickInterval) {
    return FlGridData(
      show: true,
      drawHorizontalLine: true,
      drawVerticalLine: true,
      horizontalInterval: _getInterval(),
      verticalInterval: tickInterval ?? 1,
      getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey.shade100, strokeWidth: 0.5),
      getDrawingVerticalLine: (_) => FlLine(color: Colors.grey.shade100, strokeWidth: 0.5),
    );
  }

  FlTitlesData _titlesData(double? minX, double? maxX) {
    final double minXv = minX ?? widget.xStart.millisecondsSinceEpoch.toDouble();
    final double maxXv = maxX ?? widget.xEnd.millisecondsSinceEpoch.toDouble();
    final PeriodType periodType = widget.controlChartStats?.periodType ?? PeriodType.ONE_MONTH;
    final df = DateFormat('dd/MM');
    final double step = _xInterval(periodType, minXv, maxXv);

    Widget bottomLabel(double value, TitleMeta meta) {
      final dt = DateTime.fromMillisecondsSinceEpoch(value.round(), isUtc: true);
      final text = df.format(dt);
      return SideTitleWidget(
        meta: meta,
        space: 8,
        child: Transform.rotate(
          angle: -30 * math.pi / 180,
          child: Text(text, style: const TextStyle(
            fontSize: 8, 
            color: AppColors.colorBlack), 
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
            style: const TextStyle(
              color: AppColors.colorBlack, 
              fontSize: 8)),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 20,
          interval: step,
          getTitlesWidget: bottomLabel,
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  FlBorderData _borderData() => FlBorderData(show: true, border: Border.all(color: Colors.black54, width: 1));

  // -------------------------- CONTROL LINES --------------------------

  ExtraLinesData _controlLines() {
    return ExtraLinesData(
      extraLinesOnTop: false,
      horizontalLines: [
        HorizontalLine(
          y: widget.controlChartStats?.controlLimitMRChart?.ucl ?? 0.0,
          color: Colors.amberAccent,
          strokeWidth: 1.5,
        ),
        HorizontalLine(
          y: widget.controlChartStats?.mrAverage ?? 0.0,
          color: AppColors.colorSuccess1,
          strokeWidth: 2,
        ),
      ],
    );
  }

  // ---------------------------- DATA LAYERS ----------------------------

  List<LineChartBarData> _lineBarsData() {
    final pts = _pointsInWindow;
    if (pts.isEmpty) {
      return [LineChartBarData(spots: const [], color: widget.dataLineColor, barWidth: 2)];
    }

    final minXv = widget.xStart.millisecondsSinceEpoch.toDouble();
    final maxXv = widget.xEnd.millisecondsSinceEpoch.toDouble();

    final spots = pts
        .map((p) => FlSpot(p.collectDate.millisecondsSinceEpoch.toDouble(), p.mrValue))
        .where((s) => s.x >= math.min(minXv, maxXv) && s.x <= math.max(minXv, maxXv))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));

    final ucl = widget.controlChartStats?.controlLimitMRChart?.ucl ?? 0.0;
    final baseColor = widget.dataLineColor ?? AppColors.colorBrand;

    return [
      LineChartBarData(
        spots: spots,
        isCurved: false,
        color: baseColor,
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, _, __, ___) {
            final v = spot.y;
            final isOverUCL = (ucl > 0 && v > ucl);
            final dotColor = isOverUCL ? Colors.orange : baseColor;
            return FlDotCirclePainter(
              radius: 3.5,
              color: dotColor.withValues(alpha: 0.85),
              strokeWidth: 1,
              strokeColor: Colors.white,
            );
          },
        ),
        belowBarData: BarAreaData(show: false),
      ),
    ];
  }

  // --------------------------- TOUCH / TOOLTIP ---------------------------

  static List<LineTooltipItem?> _emptyTooltip(List<LineBarSpot> touchedSpots) =>
      List<LineTooltipItem?>.filled(touchedSpots.length, null);

  LineTouchData _touchData() {
    return LineTouchData(
      handleBuiltInTouches: true,
      touchSpotThreshold: 16,
      getTouchedSpotIndicator: (barData, indexes) => indexes.map((_) {
        return TouchedSpotIndicatorData(
          FlLine(color: Colors.blueAccent.withValues(alpha: 0.5), strokeWidth: 3),
          FlDotData(
            show: true,
            getDotPainter: (spot, __, ___, ____) => FlDotCirclePainter(
              radius: 3.5,
              color: AppColors.colorBrandTp,
              strokeWidth: 3,
              strokeColor: Colors.blueAccent
            ),
          ),
        );
      }).toList(),
      // ปิด tooltip ของ fl_chart (เราวาดเอง)
      touchTooltipData: LineTouchTooltipData(getTooltipItems: _emptyTooltip),

      touchCallback: (event, resp) {
        final noHit = !event.isInterestedForInteractions ||
            resp?.lineBarSpots == null ||
            resp!.lineBarSpots!.isEmpty;

        if (noHit) {
          _tip.value = null;
          return;
        }

        final s = resp.lineBarSpots!.first;
        _tip.value = _MrTip(
          local: event.localPosition!,
          valueStr: s.y.toStringAsFixed(3),
        );
      },
    );
  }

  // ------------------------------ Y SCALE ------------------------------

  double _getMaxY() {
    if (_cachedInterval == null) _getInterval();
    return _cachedMaxY ?? 0.0;
  }

  double _getMinY() {
    if (_cachedInterval == null) _getInterval();
    return _cachedMinY ?? 0.0;
  }

  double _getInterval() {
    const divisions = 5; // -> 6 ticks
    final spotMin = 0.0; // MR เริ่มที่ศูนย์
    final spotMax = widget.controlChartStats?.yAxisRange?.maxYsurfaceHardnessMrChart ?? spotMin;

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

  // ------------------------------ HELPERS ------------------------------
  double _xInterval(PeriodType periodType, double minX, double maxX) {
    final safeRange = (maxX - minX).abs().clamp(1.0, double.infinity);
    return safeRange / 6.0;
  }
}

class _MrTip {
  final Offset local;
  final String valueStr;
  _MrTip({required this.local, required this.valueStr});
}
