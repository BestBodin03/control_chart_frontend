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

/// CDE/CDT Control Chart — Surface-like (xStart/xEnd time axis)
class ControlChartComponent extends StatefulWidget implements ChartComponent {
  final List<ChartDataPointCdeCdt>? dataPoints;
  final ControlChartStats? controlChartStats;
  final Color? dataLineColor;
  final Color? backgroundColor;
  final double? height;
  final double? width;

  final DateTime xStart;
  final DateTime xEnd;

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
  });

  // ===== legend =====
  @override
  Widget buildLegend() {
    String fmt(double? v) => (v == null || v == 0.0) ? 'N/A' : v.toStringAsFixed(2);

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

    Widget item(String label, Color color, String value) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 8, height: 2, child: DecoratedBox(decoration: BoxDecoration(color: color))),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.colorBlack, fontWeight: FontWeight.bold)),
        const SizedBox(width: 4),
        Text(value, style: const TextStyle(fontSize: 10, color: AppColors.colorBlack, fontWeight: FontWeight.bold)),
      ],
    );

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      alignment: WrapAlignment.spaceEvenly,
      children: [
        if (fmt(specUsl) != 'N/A') item('Spec', Colors.red, fmt(specUsl)),
        if (fmt(ucl)     != 'N/A') item('UCL', Colors.orange, fmt(ucl)),
        if (fmt(target)  != 'N/A') item('Target', Colors.deepPurple.shade300, fmt(target)),
        if (fmt(avg)     != 'N/A') item('AVG', Colors.green, fmt(avg)),
        if (fmt(lcl)     != 'N/A') item('LCL', Colors.orange, fmt(lcl)),
        if (fmt(specLsl) != 'N/A') item('Spec', Colors.red, fmt(specLsl)),
      ],
    );
  }

  // interface stubs
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

  double? _cachedMinY;
  double? _cachedMaxY;
  double? _cachedInterval;

  final ValueNotifier<_Tip?> _tip = ValueNotifier<_Tip?>(null);

  T? _sel<T>(T? cde, T? cdt, T? comp) {
    switch (widget.controlChartStats?.secondChartSelected) {
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
    final src = widget.dataPoints ?? const <ChartDataPointCdeCdt>[];
    if (src.isEmpty) return const <ChartDataPointCdeCdt>[];
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

              // Tooltip (local-only, quadrant placement + clamp)
              ValueListenableBuilder<_Tip?>(
                valueListenable: _tip,
                builder: (context, tip, _) {
                  if (tip == null) return const SizedBox.shrink();

                  const double maxWidth = 240;
                  const double boxH = 120;
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

  // ---------------- GRID / TITLES / BORDER ----------------
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
          child: Text(text, style: const TextStyle(fontSize: 8, color: AppColors.colorBlack), overflow: TextOverflow.ellipsis),
        ),
      );
    }

    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 24,
          interval: _getInterval(),
          getTitlesWidget: (v, _) => Text(v.toStringAsFixed(2), style: const TextStyle(color: AppColors.colorBlack, fontSize: 8)),
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

  // ---------------- CONTROL LINES ----------------
  ExtraLinesData _controlLines() {
    final specUsl = _sel(
      widget.controlChartStats?.specAttribute?.cdeUpperSpec,
      widget.controlChartStats?.specAttribute?.cdtUpperSpec,
      widget.controlChartStats?.specAttribute?.compoundLayerUpperSpec,
    );
    final specLsl = _sel(
      widget.controlChartStats?.specAttribute?.cdeLowerSpec,
      widget.controlChartStats?.specAttribute?.cdtLowerSpec,
      widget.controlChartStats?.specAttribute?.compoundLayerLowerSpec,
    );
    final target = _sel(
      widget.controlChartStats?.specAttribute?.cdeTarget,
      widget.controlChartStats?.specAttribute?.cdtTarget,
      widget.controlChartStats?.specAttribute?.compoundLayerTarget,
    );
    final ucl = _sel(
      widget.controlChartStats?.cdeControlLimitIChart?.ucl,
      widget.controlChartStats?.cdtControlLimitIChart?.ucl,
      widget.controlChartStats?.compoundLayerControlLimitIChart?.ucl,
    );
    final lcl = _sel(
      widget.controlChartStats?.cdeControlLimitIChart?.lcl,
      widget.controlChartStats?.cdtControlLimitIChart?.lcl,
      widget.controlChartStats?.compoundLayerControlLimitIChart?.lcl,
    );
    final avg = _sel(
      widget.controlChartStats?.cdeAverage,
      widget.controlChartStats?.cdtAverage,
      widget.controlChartStats?.compoundLayerAverage,
    );

    return ExtraLinesData(
      extraLinesOnTop: false,
      horizontalLines: [
        if ((specUsl ?? 0) > 0) HorizontalLine(y: specUsl!, color: Colors.red.shade400, strokeWidth: 2),
        if (ucl != null)       HorizontalLine(y: ucl, color: Colors.amberAccent, strokeWidth: 1.5),
        if ((target ?? 0) != 0) HorizontalLine(y: target!, color: Colors.deepPurple.shade300, strokeWidth: 1.5),
        if (avg != null)       HorizontalLine(y: avg, color: AppColors.colorSuccess1, strokeWidth: 2),
        if (lcl != null)       HorizontalLine(y: lcl, color: Colors.amberAccent, strokeWidth: 1.5),
        if ((specLsl ?? 0) > 0) HorizontalLine(y: specLsl!, color: Colors.red.shade400, strokeWidth: 2),
      ],
    );
  }

  // ---------------- DATA LAYERS (R3 overlay + bridge, like Surface) ----------------
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

    final Map<double, ChartDataPointCdeCdt> dpByX = {
      for (final p in pts.where((e) => e.collectDate != null))
        p.collectDate.millisecondsSinceEpoch.toDouble(): p
    };

    // split R3 / non-R3 segments
    final r3Segments = <List<FlSpot>>[];
    final nonR3Segments = <List<FlSpot>>[];
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

    final specUsl = _sel(
          widget.controlChartStats?.specAttribute?.cdeUpperSpec,
          widget.controlChartStats?.specAttribute?.cdtUpperSpec,
          widget.controlChartStats?.specAttribute?.compoundLayerUpperSpec,
        ) ??
        0.0;
    final specLsl = _sel(
          widget.controlChartStats?.specAttribute?.cdeLowerSpec,
          widget.controlChartStats?.specAttribute?.cdtLowerSpec,
          widget.controlChartStats?.specAttribute?.compoundLayerLowerSpec,
        ) ??
        0.0;
    final ucl = _sel(
          widget.controlChartStats?.cdeControlLimitIChart?.ucl,
          widget.controlChartStats?.cdtControlLimitIChart?.ucl,
          widget.controlChartStats?.compoundLayerControlLimitIChart?.ucl,
        ) ??
        0.0;
    final lcl = _sel(
          widget.controlChartStats?.cdeControlLimitIChart?.lcl,
          widget.controlChartStats?.cdtControlLimitIChart?.lcl,
          widget.controlChartStats?.compoundLayerControlLimitIChart?.lcl,
        ) ??
        0.0;

    final indexByX = <double, int>{for (var i = 0; i < spots.length; i++) spots[i].x: i};

    // bridge neighbors for each R3 segment
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
          } else if (((specUsl > 0 && v > specUsl) || (specLsl > 0 && v < specLsl))) {
            dotColor = Colors.red;
          } else if ((ucl > 0 && v > ucl) || (lcl > 0 && v < lcl)) {
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

    // R3 overlay (white outline + pink)
    final r3Overlay = r3Segments
        .where((seg) => seg.length >= 2)
        .expand((seg) => [
              LineChartBarData(
                spots: seg,
                isCurved: false,
                color: Colors.white,
                barWidth: 5,
                dotData: const FlDotData(show: false),
              ),
              LineChartBarData(
                spots: seg,
                isCurved: false,
                color: Colors.pinkAccent,
                barWidth: 3,
                dotData: const FlDotData(show: false),
              ),
            ])
        .toList();

    return [...r3Overlay, ...nonR3Lines, ...bridgeLines, dotsOnly];
  }

  // ---------------- TOUCH / TOOLTIP (local) ----------------
  static List<LineTooltipItem?> _emptyTooltip(List<LineBarSpot> touchedSpots) =>
      List<LineTooltipItem?>.filled(touchedSpots.length, null);

  LineTouchData _touchData() {
    final points = _pointsInWindow;
    const hoverColor = Colors.blueAccent;

    return LineTouchData(
      handleBuiltInTouches: true,
      touchSpotThreshold: 8,
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
              strokeColor: hoverColor,
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

        final specUsl = _sel(
              widget.controlChartStats?.specAttribute?.cdeUpperSpec,
              widget.controlChartStats?.specAttribute?.cdtUpperSpec,
              widget.controlChartStats?.specAttribute?.compoundLayerUpperSpec,
            ) ??
            0.0;
        final specLsl = _sel(
              widget.controlChartStats?.specAttribute?.cdeLowerSpec,
              widget.controlChartStats?.specAttribute?.cdtLowerSpec,
              widget.controlChartStats?.specAttribute?.compoundLayerLowerSpec,
            ) ??
            0.0;
        final ucl = _sel(
              widget.controlChartStats?.cdeControlLimitIChart?.ucl,
              widget.controlChartStats?.cdtControlLimitIChart?.ucl,
              widget.controlChartStats?.compoundLayerControlLimitIChart?.ucl,
            ) ??
            0.0;
        final lcl = _sel(
              widget.controlChartStats?.cdeControlLimitIChart?.lcl,
              widget.controlChartStats?.cdtControlLimitIChart?.lcl,
              widget.controlChartStats?.compoundLayerControlLimitIChart?.lcl,
            ) ??
            0.0;

        final bool beyondCL   = (lcl > 0 && nearestPoint.value < lcl) || (ucl > 0 && nearestPoint.value > ucl);
        final bool beyondSpec = (specLsl > 0 && nearestPoint.value < specLsl) || (specUsl > 0 && nearestPoint.value > specUsl);
        final bool trend      = nearestPoint.isViolatedR3 == true;

        final chips = <_ChipData>[
          if (trend)      _ChipData('Trend', Colors.pinkAccent),
          if (beyondSpec) _ChipData('Over Spec', Colors.red),
          if (beyondCL)   _ChipData('Over Control', Colors.orange),
        ];

        final content = TooltipContent(
          title: nearestPoint.fullLabel ?? '',
          rows: [
            MapEntry('Value', s.y.toStringAsFixed(3)),
            MapEntry('FG No.', nearestPoint.fgNo ?? '-'),
          ],
          chips: chips,
          accent: hoverColor,
        );

        _tip.value = _Tip(local: event.localPosition!, content: content);
      },
    );
  }

  // ---------------- Y SCALE ----------------
  double _getMaxY() {
    if (_cachedInterval == null) _getInterval();
    return _cachedMaxY ?? 0.0;
    }
  double _getMinY() {
    if (_cachedInterval == null) _getInterval();
    return _cachedMinY ?? 0.0;
  }

  double _getInterval() {
    const divisions = 5;
    final minSel = _sel(
          widget.controlChartStats?.yAxisRange?.minYcdeControlChart,
          widget.controlChartStats?.yAxisRange?.minYcdtControlChart,
          widget.controlChartStats?.yAxisRange?.minYcompoundLayerControlChart,
        ) ?? 0.0;
    final maxSel = _sel(
          widget.controlChartStats?.yAxisRange?.maxYcdeControlChart,
          widget.controlChartStats?.yAxisRange?.maxYcdtControlChart,
          widget.controlChartStats?.yAxisRange?.maxYcompoundLayerControlChart,
        ) ?? minSel;

    if (maxSel <= minSel) {
      _cachedMinY = minSel;
      _cachedMaxY = maxSel;
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
    // if (mant <= 3.0) return 3.0 * mag;
    // if (mant <= 4.0) return 4.0 * mag;
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
    // if (mant < 3.0) return 3.5 * mag;
    if (mant < 5.0) return 10.0 * mag;
    return 10.0 * mag;
  }

  double _xInterval(PeriodType periodType, double minX, double maxX) {
    final safeRange = (maxX - minX).abs().clamp(1.0, double.infinity);
    return safeRange / 6.0;
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
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(e.key, style: AppTypography.textBody4WBold),
                Text(e.value, style: AppTypography.textBody4W),
              ])),
          if (chips.isNotEmpty) ...[
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              children: chips
                  .map((c) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: c.color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: c.color),
                        ),
                        child: Text(c.label, style: AppTypography.textBody4W),
                      ))
                  .toList(),
            ),
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
