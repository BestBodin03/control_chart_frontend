import 'dart:math' as math;
import 'package:control_chart/domain/models/chart_data_point.dart';
import 'package:control_chart/domain/models/control_chart_stats.dart';
import 'package:control_chart/domain/models/setting.dart';
import 'package:control_chart/domain/types/chart_component.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';
import 'package:control_chart/ui/core/shared/common/chart/font_scaler.dart';
import 'package:control_chart/ui/core/shared/dashed_line_painter.dart' show DashedLinePainter;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../common/chart/legend_item.dart';
import '../../common/chart/size_scaler.dart';
import '../../small_control_chart/small_control_chart_var.dart';

class ControlChartComponent extends StatefulWidget implements ChartComponent {
  final List<ChartDataPoint>? dataPoints;
  final ControlChartStats? controlChartStats;
  final Color? dataLineColor;
  final Color? backgroundColor;
  final double? height;
  final double? width;

  final DateTime xStart;
  final DateTime xEnd;
  final double? minY;
  final double? maxY;

  const ControlChartComponent({
    super.key,
    this.dataPoints,
    this.controlChartStats,
    this.dataLineColor = AppColors.colorBrand,
    this.backgroundColor,
    this.height,
    this.width = 560,
    required this.xStart,
    required this.xEnd,
    required this.minY,
    required this.maxY
  });

  @override
  Widget buildLegend(context) {
    String fmt(double? v) => (v == null || v == 0.0) ? 'N/A' : v.toStringAsFixed(2);

    return Wrap(
      spacing: 12,
      runSpacing: 4,
      direction: Axis.horizontal,
      alignment: WrapAlignment.spaceEvenly,
      children: [
        if (fmt(controlChartStats?.specAttribute?.surfaceHardnessUpperSpec) != 'N/A')
          legendItem(context,
            'Spec',
            Colors.red,
            fmt(controlChartStats?.specAttribute?.surfaceHardnessUpperSpec),
          ),

        if (fmt(controlChartStats?.controlLimitIChart?.ucl) != 'N/A')
          legendItem(context,
            'UCL',
            Colors.orange,
            fmt(controlChartStats?.controlLimitIChart?.ucl),
          ),

        if (fmt(controlChartStats?.specAttribute?.surfaceHardnessTarget) != 'N/A')
          legendItem(context,
            'Target',
            Colors.deepPurple.shade300,
            fmt(controlChartStats?.specAttribute?.surfaceHardnessTarget),
          ),

        if (fmt(controlChartStats?.average) != 'N/A')
          legendItem(context,
            'AVG',
            Colors.green,
            fmt(controlChartStats?.average),
          ),

        if (fmt(controlChartStats?.controlLimitIChart?.lcl) != 'N/A')
          legendItem(context,
            'LCL',
            Colors.orange,
            fmt(controlChartStats?.controlLimitIChart?.lcl),
          ),

        if (fmt(controlChartStats?.specAttribute?.surfaceHardnessLowerSpec) != 'N/A')
          legendItem(context,
            'Spec',
            Colors.red,
            fmt(controlChartStats?.specAttribute?.surfaceHardnessLowerSpec),
          ),
      ],
    );
  }

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
  State<ControlChartComponent> createState() => _ControlChartComponentState();
}

class _ControlChartComponentState extends State<ControlChartComponent> {
  final GlobalKey _chartKey = GlobalKey();

  // ---------- คำนวณ/แคชสเกลแกน Y (ล็อก 6 ticks) ----------
  double? _cachedMinY;
  double? _cachedMaxY;
  double? _cachedInterval;

  // หมายเหตุ: ต้องมี niceSteps ที่อื่นอยู่แล้ว (เช่น [1,2,2.5,5,10,...])
  double _niceStepCeil(double x) {
    int left = 0, right = niceSteps.length - 1;
    while (left < right) {
      final mid = (left + right) >> 1;
      if (niceSteps[mid] >= x) {
        right = mid;
      } else {
        left = mid + 1;
      }
    }
    return niceSteps[left];
  }

  double _nextNiceStep(double step) {
    int left = 0, right = niceSteps.length - 1;
    while (left < right) {
      final mid = (left + right) >> 1;
      if (niceSteps[mid] > step) {
        right = mid;
      } else {
        left = mid + 1;
      }
    }
    return niceSteps[left];
  }

  void _ensureYScale() {
    if (_cachedInterval != null) return;

    const divisions = 5;
    const epsilon = 1e-9;

    final specUsl = widget.controlChartStats?.specAttribute?.surfaceHardnessUpperSpec;
    final ucl = widget.controlChartStats?.controlLimitIChart?.ucl;
    final lcl = widget.controlChartStats?.controlLimitIChart?.lcl;
    final specLsl = widget.controlChartStats?.specAttribute?.surfaceHardnessLowerSpec;
    final minSel = widget.controlChartStats?.yAxisRange?.minYsurfaceHardnessControlChart ?? 0.0;
    final maxSel = widget.controlChartStats?.yAxisRange?.maxYsurfaceHardnessControlChart ?? 0.0;

    if (maxSel <= minSel) {
      _cachedMinY = minSel;
      _cachedMaxY = minSel + divisions;
      _cachedInterval = 1.0;
      return;
    }

    // Collect all pins
    final pins = <double?>[specLsl, specUsl, lcl, ucl];
    final activePins = pins
        .where((p) => p != null && p!.abs() > 0) // ใช้ abs() เผื่อค่าติดลบ 0.0
        .cast<double>()
        .toList();

    debugPrint('Initial range: [$minSel, $maxSel]');
    debugPrint('Active pins: $activePins');

    // Expand initial range to avoid pins on boundaries
    double workingMin = minSel;
    double workingMax = maxSel;

    for (final pin in activePins) {
      if ((pin - workingMin).abs() < epsilon) {
        workingMin = pin - 0.1;
      }
      if ((pin - workingMax).abs() < epsilon) {
        workingMax = pin + 0.1;
      }
    }

    debugPrint('Adjusted working range: [$workingMin, $workingMax]');

    // Calculate ideal interval
    final ideal = (workingMax - workingMin) / divisions;
    double interval = _niceStepCeil(ideal);

    debugPrint('Initial interval: $interval (from ideal: $ideal)');

    // Track tried intervals to detect infinite loop
    final Set<double> triedIntervals = {interval};

    // Align to grid
    double minY = (workingMin / interval).floor() * interval;
    double maxY = minY + divisions * interval;

    // Ensure coverage of workingMax
    while (maxY < workingMax - epsilon) {
      final oldInterval = interval;
      interval = _nextNiceStep(interval);
      
      if (interval == oldInterval || interval >= niceSteps.last) {
        debugPrint('⚠️ Reached end of niceSteps during coverage check');
        maxY = workingMax + interval;
        break;
      }
      
      minY = (workingMin / interval).floor() * interval;
      maxY = minY + divisions * interval;
    }

    debugPrint('After coverage check: minY=$minY, maxY=$maxY, interval=$interval');

    // Check and avoid collisions with minY and maxY only
    bool hasCollision = true;
    
    while (hasCollision) {
      hasCollision = false;

      for (final pin in activePins) {
        // Check if pin collides with minY or maxY
        if ((pin - minY).abs() < epsilon || (pin - maxY).abs() < epsilon) {
          debugPrint('Pin $pin collides with boundary (minY=$minY or maxY=$maxY)');
          
          final oldInterval = interval;
          interval = _nextNiceStep(interval);
          
          // Check if we've tried this interval before or reached the end
          if (triedIntervals.contains(interval) || interval == oldInterval || interval >= niceSteps.last) {
            debugPrint('⚠️ Cannot find collision-free interval, using current: $interval');
            hasCollision = false;
            break;
          }
          
          triedIntervals.add(interval);
          debugPrint('Trying new interval: $interval');
          
          // Recalculate grid with new interval
          minY = (workingMin / interval).floor() * interval;
          maxY = minY + divisions * interval;
          
          // Ensure coverage with new interval
          while (maxY < workingMax - epsilon) {
            final coverageInterval = _nextNiceStep(interval);
            if (coverageInterval == interval || coverageInterval >= niceSteps.last) {
              maxY = workingMax + interval;
              break;
            }
            interval = coverageInterval;
            triedIntervals.add(interval);
            minY = (workingMin / interval).floor() * interval;
            maxY = minY + divisions * interval;
          }
          
          hasCollision = true;
          break;
        }
      }
    }

    // Final snap
    double _snap(double val, double step) => (val / step).roundToDouble() * step;
    minY = _snap(minY, interval);
    maxY = minY + divisions * interval;

    debugPrint('Final: minY=$minY, maxY=$maxY, interval=$interval');
    debugPrint('Tried intervals: $triedIntervals');

    _cachedMinY = minY;
    _cachedMaxY = maxY;
    _cachedInterval = interval;
  }
  
  // Tooltip state
  final ValueNotifier<_Tip?> _tip = ValueNotifier<_Tip?>(null);

  List<ChartDataPoint> get _pointsInWindow {
    final src = widget.dataPoints ?? const <ChartDataPoint>[];
    if (src.isEmpty) return const <ChartDataPoint>[];
    final lo = math.min(widget.xStart.millisecondsSinceEpoch, widget.xEnd.millisecondsSinceEpoch).toDouble();
    final hi = math.max(widget.xStart.millisecondsSinceEpoch, widget.xEnd.millisecondsSinceEpoch).toDouble();
    return src.where((p) {
      final t = p.collectDate.millisecondsSinceEpoch.toDouble();
      return t >= lo && t <= hi;
    }).toList();
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

    final double minSel = widget.controlChartStats?.yAxisRange?.minYsurfaceHardnessControlChart ?? 0.0;
    final double maxSel = widget.controlChartStats?.yAxisRange?.maxYsurfaceHardnessControlChart ?? 0.0;

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
                      minY: _getMinY(minSel),
                      maxY: _getMaxY(maxSel),
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

              // Tooltip (local-only, non-blocking)
              ValueListenableBuilder<_Tip?>(
                valueListenable: _tip,
                builder: (context, tip, _) {
                  if (tip == null) return const SizedBox.shrink();

                  const double maxWidth = 144;
                  const double boxH = 196;
                  const double dotR = 8;
                  const double gap = 8;
                  const double pad = 8;

                  final dx = tip.local.dx;
                  final dy = tip.local.dy;

                  final bool canAbove = dy - (dotR + gap + boxH) >= pad;
                  final bool canBelow = dy + (dotR + gap + boxH) <= chartSize.height - pad;
                  final bool canRight = dx + (dotR + gap + maxWidth) <= chartSize.width  - 6*pad;
                  final bool canLeft  = dx - (dotR + gap + maxWidth) >= pad;

                  double left, top;

                  if (canAbove) {
                    left = dx - maxWidth / 2;
                    top  = dy - dotR - gap - boxH;
                    final hiX = chartSize.width - maxWidth - pad;
                    left = (hiX <= pad) ? (chartSize.width - maxWidth) / 2 : left.clamp(pad, hiX);
                  } else if (canBelow) {
                    left = dx - maxWidth / 2;
                    top  = dy + dotR + gap;
                    final hiX = chartSize.width - maxWidth - pad;
                    left = (hiX <= pad) ? (chartSize.width - maxWidth) / 2 : left.clamp(pad, hiX);
                  } else if (canRight) {
                    left = dx + dotR + 4*gap;
                    top  = dy - boxH / 2;
                    final hiY = chartSize.height - boxH - pad;
                    top = (hiY <= pad) ? (chartSize.height - boxH) / 2 : top.clamp(pad, hiY);
                  } else if (canLeft) {
                    left = dx - dotR - gap - maxWidth;
                    top  = dy - boxH / 2;
                    final hiY = chartSize.height - boxH - pad;
                    top = (hiY <= pad) ? (chartSize.height - boxH) / 2 : top.clamp(pad, hiY);
                  } else {
                    left = (chartSize.width  - maxWidth) / 2;
                    top  = (chartSize.height - boxH) / 2;
                  }

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
                          child: tip.content,
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

  // ---------------------------------------------------------------------------
  // GRID / TITLES / BORDER
  // ---------------------------------------------------------------------------
  FlGridData _gridData(double? minX, double? maxX, double? tickInterval) {
    return FlGridData(
      show: true,
      drawHorizontalLine: true,
      drawVerticalLine: true,
      horizontalInterval: _getInterval(),         // ✅ ใช้ interval จาก cache
      verticalInterval: tickInterval ?? 1,
      getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey.shade200, strokeWidth: 0.5),
      getDrawingVerticalLine: (_) => FlLine(color: Colors.grey.shade200, strokeWidth: 0.5),
    );
  }

  FlTitlesData _titlesData(double? minX, double? maxX) {
    final double minXv = minX ?? widget.xStart.millisecondsSinceEpoch.toDouble();
    final double maxXv = maxX ?? widget.xEnd.millisecondsSinceEpoch.toDouble();
    final PeriodType periodType = widget.controlChartStats?.periodType ?? PeriodType.ONE_MONTH;

    final df = DateFormat('dd/MM');
    final double step = _xInterval(periodType, minXv, maxXv);

    // bottom label
    Widget bottomLabel(double value, TitleMeta meta) {
      final dt = DateTime.fromMillisecondsSinceEpoch(value.round(), isUtc: true);
      final text = df.format(dt);

      final double fontSize = fontScaler(context, 10);

      return SideTitleWidget(
        meta: meta,
        child: Transform.rotate(
          angle: -30 * math.pi / 180,
          child: Text(
            text,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: fontSize,
              color: AppColors.colorBlack,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: sizeScaler(context, 14, 2.5),  // ✅ เติม base ให้ถูกต้อง
          interval: _getInterval(),
          getTitlesWidget: (v, meta) {
            final double fontSize = fontScaler(context, 10);
            return Text(
              v.toStringAsFixed(0),
              style: TextStyle(
                color: AppColors.colorBlack,
                fontSize: fontSize,
              ),
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: sizeScaler(context, 12, 2.25),
          interval: step,
          getTitlesWidget: bottomLabel,
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  FlBorderData _borderData() => FlBorderData(
    show: true,
    border: Border.all(color: Colors.black54, width: 1),
  );

  // -------------------------- CONTROL LINES --------------------------
  ExtraLinesData _controlLines() {
    return ExtraLinesData(
      extraLinesOnTop: false,
      horizontalLines: [
        if ((widget.controlChartStats?.specAttribute?.surfaceHardnessUpperSpec ?? 0.0) > 0.0)
          HorizontalLine(
            y: widget.controlChartStats!.specAttribute!.surfaceHardnessUpperSpec!,
            color: Colors.red.shade400,
            strokeWidth: 2,
          ),
        HorizontalLine(
          y: widget.controlChartStats?.controlLimitIChart?.ucl ?? 0.0,
          color: Colors.amberAccent,
          strokeWidth: 1.5,
        ),
        if ((widget.controlChartStats?.specAttribute?.surfaceHardnessTarget ?? 0.0) != 0.0)
          HorizontalLine(
            y: widget.controlChartStats!.specAttribute!.surfaceHardnessTarget!,
            color: Colors.deepPurple.shade300,
            strokeWidth: 1.5,
          ),
        HorizontalLine(
          y: widget.controlChartStats?.average ?? 0.0,
          color: AppColors.colorSuccess1,
          strokeWidth: 2,
        ),
        HorizontalLine(
          y: widget.controlChartStats?.controlLimitIChart?.lcl ?? 0.0,
          color: Colors.amberAccent,
          strokeWidth: 1.5,
        ),
        if ((widget.controlChartStats?.specAttribute?.surfaceHardnessLowerSpec ?? 0.0) > 0.0)
          HorizontalLine(
            y: widget.controlChartStats!.specAttribute!.surfaceHardnessLowerSpec!,
            color: Colors.red.shade400,
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
        .where((p) => p.collectDate != null)
        .map((p) => FlSpot(p.collectDate.millisecondsSinceEpoch.toDouble(), p.value))
        .where((s) => s.x >= math.min(minXv, maxXv) && s.x <= math.max(minXv, maxXv))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));

    final Map<double, ChartDataPoint> dpByX = {
      for (final p in pts.where((e) => e.collectDate != null))
        p.collectDate!.millisecondsSinceEpoch.toDouble(): p
    };

    // split R3 / non-R3 segments
    List<List<FlSpot>> r3Segments = [];
    List<List<FlSpot>> nonR3Segments = [];

    var cur = <FlSpot>[];
    bool? curIsR3;

    for (final s in spots) {
      final isR3 = (dpByX[s.x]?.isViolatedR3 == true);

      if (cur.isEmpty) {
        cur.add(s);
        curIsR3 = isR3;
      } else if (curIsR3 == isR3) {
        cur.add(s);
      } else {
        (curIsR3 == true ? r3Segments : nonR3Segments).add(cur);
        cur = <FlSpot>[s];
        curIsR3 = isR3;
      }
    }

    if (cur.isNotEmpty) {
      (curIsR3 == true ? r3Segments : nonR3Segments).add(cur);
    }

    final baseColor = widget.dataLineColor ?? AppColors.colorBrand;

    final upperSpec = widget.controlChartStats?.specAttribute?.surfaceHardnessUpperSpec ?? 0.0;
    final lowerSpec = widget.controlChartStats?.specAttribute?.surfaceHardnessLowerSpec ?? 0.0;
    final ucl       = widget.controlChartStats?.controlLimitIChart?.ucl ?? 0.0;
    final lcl       = widget.controlChartStats?.controlLimitIChart?.lcl ?? 0.0;

    final indexByX = <double, int>{for (var i = 0; i < spots.length; i++) spots[i].x: i};

    final bridgeSegments = <List<FlSpot>>[];
    for (final seg in r3Segments) {
      if (seg.isEmpty) continue;
      final firstIdx = indexByX[seg.first.x]!;
      final lastIdx  = indexByX[seg.last.x]!;
      if (firstIdx - 1 >= 0) bridgeSegments.add([spots[firstIdx - 1], seg.first]);
      if (lastIdx + 1 < spots.length) bridgeSegments.add([seg.last, spots[lastIdx + 1]]);
    }

    // dots-only layer
    final dotsOnly = LineChartBarData(
      spots: spots,
      isCurved: false,
      color: Colors.transparent,
      barWidth: 0,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, __, ___, ____) {
          final dp = dpByX[spot.x];
          final v = spot.y;

          Color dotColor;
          if (dp?.isViolatedR3 == true) {
            dotColor = Colors.pinkAccent;
          } else if (dp?.isViolatedR1BeyondUSL == true ||
              dp?.isViolatedR1BeyondLSL == true ||
              ((upperSpec > 0 && v > upperSpec) || (lowerSpec > 0 && v < lowerSpec))) {
            dotColor = Colors.red;
          } else if (dp?.isViolatedR1BeyondUCL == true ||
              dp?.isViolatedR1BeyondLCL == true ||
              ((ucl > 0 && v > ucl) || (lcl > 0 && v < lcl))) {
            dotColor = Colors.orange;
          } else {
            dotColor = baseColor;
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
    );

    // non-R3 lines
    final nonR3Lines = nonR3Segments
        .where((seg) => seg.length >= 2)
        .map((seg) => LineChartBarData(
              spots: seg,
              isCurved: false,
              color: baseColor,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ))
        .toList();

    final bridgeLines = bridgeSegments
        .map((seg) => LineChartBarData(
              spots: seg,
              isCurved: false,
              color: baseColor,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ))
        .toList();

    // R3 overlay
    final r3Overlay = r3Segments
        .where((seg) => seg.length >= 2)
        .expand((seg) => [
              LineChartBarData(spots: seg, isCurved: false, color: Colors.white,      barWidth: 5, dotData: const FlDotData(show: false)),
              LineChartBarData(spots: seg, isCurved: false, color: Colors.pinkAccent, barWidth: 3, dotData: const FlDotData(show: false)),
            ])
        .toList();

    return [...r3Overlay, ...nonR3Lines, ...bridgeLines, dotsOnly];
  }

  // --------------------------- TOUCH / TOOLTIP ---------------------------
  static List<LineTooltipItem?> _emptyTooltip(List<LineBarSpot> touchedSpots) =>
      List<LineTooltipItem?>.filled(touchedSpots.length, null);

  LineTouchData _touchData() {
    final points = _pointsInWindow;
    const hoverColor = Colors.blueAccent;

    return LineTouchData(
      handleBuiltInTouches: true,
      touchSpotThreshold: 4,
      mouseCursorResolver: (event, response) {
        final hasHit = response?.lineBarSpots?.isNotEmpty ?? false;
        return hasHit ? SystemMouseCursors.click : SystemMouseCursors.basic;
      },
      getTouchedSpotIndicator: (barData, indexes) => indexes.map((_) {
        return TouchedSpotIndicatorData(
          FlLine(color: hoverColor.withValues(alpha: 0.5), strokeWidth: 3),
          FlDotData(
            show: true,
            getDotPainter: (spot, __, ___, ____) => FlDotCirclePainter(
              radius: 3.5,
              color: AppColors.colorBrandTp,
              strokeWidth: 3,
              strokeColor: hoverColor
            ),
          ),
        );
      }).toList(),
      touchTooltipData: LineTouchTooltipData(getTooltipItems: _emptyTooltip),
      touchCallback: (event, resp) {
        final noHit = !event.isInterestedForInteractions ||
            resp?.lineBarSpots == null || resp!.lineBarSpots!.isEmpty;

        if (noHit) {
          _tip.value = null;
          return;
        }

        final s = resp.lineBarSpots!.first;

        // หา data point จริงที่ใกล้ที่สุด
        final nearestPoint = points
            .where((p) => p.collectDate != null)
            .reduce((a, b) {
          final aDistance = (a.collectDate.millisecondsSinceEpoch.toDouble() - s.x).abs();
          final bDistance = (b.collectDate.millisecondsSinceEpoch.toDouble() - s.x).abs();
          return aDistance < bDistance ? a : b;
        });
        final bool beyondCLL   = nearestPoint.isViolatedR1BeyondLCL == true;
        final bool beyondCLU   = nearestPoint.isViolatedR1BeyondUCL == true;
        final bool beyondSpecL = nearestPoint.isViolatedR1BeyondLSL == true;
        final bool beyondSpecU = nearestPoint.isViolatedR1BeyondUSL == true;
        final bool trend      = nearestPoint.isViolatedR3 == true;

        final chips = <_ChipData>[
          if (trend)       _ChipData('Trend', Colors.pinkAccent),
          if (beyondSpecL) _ChipData('Over Spec (L)', Colors.red),
          if (beyondSpecU) _ChipData('Over Spec (U)', Colors.red),
          if (beyondCLL)   _ChipData('Over Control (L)', Colors.orange),
          if (beyondCLU)   _ChipData('Over Control (U)', Colors.orange),
        ];

        final content = TooltipContent(
          title: nearestPoint.fullLabel,
          rows: [
            MapEntry('Value', s.y.toStringAsFixed(3)),
            MapEntry('Lot No.', nearestPoint.fgNo ?? '-')
          ],
          chips: chips,
          accent: hoverColor,
        );

        _tip.value = _Tip(local: event.localPosition!, content: content);
      },
    );
  }

  // ---------- getters ที่อ่านจาก cache เท่านั้น ----------
  double _getMinY(double _) {
    if (_cachedInterval == null) _ensureYScale();
    return _cachedMinY ?? 0.0;
  }

  double _getMaxY(double __) {
    if (_cachedInterval == null) _ensureYScale();
    return _cachedMaxY ?? 0.0;
  }

  double _getInterval() {
    if (_cachedInterval == null) _ensureYScale();
    return _cachedInterval!;
  }

  // ---------------------------- HELPERS ----------------------------
  double _xInterval(PeriodType periodType, double minX, double maxX) {
    final safeRange = (maxX - minX).abs().clamp(1.0, double.infinity);
    return safeRange / 6.0; // 6 ticks บนแกน X
  }
}

// ---------- Tooltip UI ----------
class _Tip {
  final Offset local;
  final Widget content;
  _Tip({required this.local, required this.content});
}

class TooltipContent extends StatelessWidget {
  final String title;
  final List<MapEntry<String, String>> rows;
  final List<_ChipData> chips;
  final Color accent;

  const TooltipContent({
    super.key,
    required this.title,
    required this.rows,
    this.chips = const [],
    this.accent = Colors.red,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: AppTypography.textBody4W,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.textBody4WBold),
          const SizedBox(height: 4),
          ...rows.map((e) =>
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(e.key, style: AppTypography.textBody4WBold),
                Text(e.value, style: AppTypography.textBody4W),
              ],
            )),
          if (chips.isNotEmpty) ...[
            const SizedBox(height: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: chips
                  .map((c) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        decoration: BoxDecoration(
                          color: c.color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: c.color),
                        ),
                        child: Text(c.label, style: AppTypography.textBody4W),
                      ))
                  .toList(),
            )
          ],
          const SizedBox(height: 6),
          Container(height: 2, color: accent),
        ],
      ),
    );
  }
}

class _ChipData {
  final String label;
  final Color color;
  _ChipData(this.label, this.color);
}
