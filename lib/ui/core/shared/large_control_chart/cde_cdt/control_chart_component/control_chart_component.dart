// lib/ui/core/shared/large_control_chart/control_chart_component_large.dart
import 'dart:math' as math;
import 'package:control_chart/domain/models/chart_data_point.dart';
import 'package:control_chart/domain/models/control_chart_stats.dart';
import 'package:control_chart/domain/models/setting.dart';
import 'package:control_chart/domain/types/chart_component.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';
import 'package:control_chart/ui/core/shared/chart_selection.dart'; // <- provides .sel<T>()
import 'package:control_chart/ui/core/shared/common/chart/size_scaler.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../common/chart/font_scaler.dart';
import '../../../common/chart/legend_item.dart';
import 'control_chart_large_logic.dart';
import 'control_chart_large_view.dart';

class ControlChartComponentLarge extends StatefulWidget implements ChartComponent {
  final List<ChartDataPointCdeCdt>? dataPoints;
  final ControlChartStats? controlChartStats;
  final Color? dataLineColor;
  final Color? backgroundColor;
  final double? height;
  final double? width;
  final DateTime xStart;
  final DateTime xEnd;

  const ControlChartComponentLarge({
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

  // ---------- Legend ----------
  @override
  Widget buildLegend(BuildContext context) {
    String fmt(double? v) => (v == null || v == 0.0) ? 'N/A' : v.toStringAsFixed(2);

    final specUsl = controlChartStats?.sel<double?>(
      controlChartStats?.specAttribute?.cdeUpperSpec,
      controlChartStats?.specAttribute?.cdtUpperSpec,
      controlChartStats?.specAttribute?.compoundLayerUpperSpec,
    );
    final target = controlChartStats?.sel<double?>(
      controlChartStats?.specAttribute?.cdeTarget,
      controlChartStats?.specAttribute?.cdtTarget,
      controlChartStats?.specAttribute?.compoundLayerTarget,
    );
    final avg = controlChartStats?.sel<double?>(
      controlChartStats?.cdeAverage,
      controlChartStats?.cdtAverage,
      controlChartStats?.compoundLayerAverage,
    );
    final ucl = controlChartStats?.sel<double?>(
      controlChartStats?.cdeControlLimitIChart?.ucl,
      controlChartStats?.cdtControlLimitIChart?.ucl,
      controlChartStats?.compoundLayerControlLimitIChart?.ucl,
    );
    final lcl = controlChartStats?.sel<double?>(
      controlChartStats?.cdeControlLimitIChart?.lcl,
      controlChartStats?.cdtControlLimitIChart?.lcl,
      controlChartStats?.compoundLayerControlLimitIChart?.lcl,
    );
    final specLsl = controlChartStats?.sel<double?>(
      controlChartStats?.specAttribute?.cdeLowerSpec,
      controlChartStats?.specAttribute?.cdtLowerSpec,
      controlChartStats?.specAttribute?.compoundLayerLowerSpec,
    );

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      alignment: WrapAlignment.spaceEvenly,
      children: [
        if (fmt(specUsl) != 'N/A') legendItem(context, 'Spec', Colors.red, fmt(specUsl)),
        if (fmt(ucl) != 'N/A')     legendItem(context, 'UCL', Colors.orange, fmt(ucl)),
        if (fmt(target) != 'N/A')  legendItem(context, 'Target', Colors.deepPurple.shade300, fmt(target)),
        if (fmt(avg) != 'N/A')     legendItem(context, 'AVG', Colors.green, fmt(avg)),
        if (fmt(lcl) != 'N/A')     legendItem(context, 'LCL', Colors.orange, fmt(lcl)),
        if (fmt(specLsl) != 'N/A') legendItem(context, 'Spec', Colors.red, fmt(specLsl)),
      ],
    );
  }

  // interface stubs
  @override FlBorderData buildBorderData() => FlBorderData(show: false);
  @override ExtraLinesData buildControlLines() => const ExtraLinesData();
  @override FlGridData buildGridData(double? minX, double? maxX, double? tickInterval) => const FlGridData(show: false);
  @override List<LineChartBarData> buildLineBarsData() => const <LineChartBarData>[];
  @override FlTitlesData buildTitlesData(double? minX, double? maxX, double? tickInterval) => const FlTitlesData();
  @override LineTouchData buildTouchData() => const LineTouchData();
  @override double getMaxY() => 0;
  @override double getMinY() => 0;

  @override
  State<ControlChartComponentLarge> createState() => _ControlChartComponentLargeState();
}

class _ControlChartComponentLargeState extends State<ControlChartComponentLarge> {
  final _logic = ControlChartLargeLogic();
  final ValueNotifier<_Tip?> _tip = ValueNotifier<_Tip?>(null);

  @override
  void dispose() {
    _tip.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minXv = widget.xStart.millisecondsSinceEpoch.toDouble();
    final maxXv = widget.xEnd.millisecondsSinceEpoch.toDouble();
    final desiredTick = (widget.controlChartStats?.xTick ?? 6).clamp(2, 100);

    // ------- Build POJO inputs -------
    final yr = widget.controlChartStats?.yAxisRange;

    final yMin = widget.controlChartStats?.sel<double?>(
          yr?.minYcdeControlChart,
          yr?.minYcdtControlChart,
          yr?.minYcompoundLayerControlChart,
        ) ??
        0.0;

    final yMax = widget.controlChartStats?.sel<double?>(
          yr?.maxYcdeControlChart,
          yr?.maxYcdtControlChart,
          yr?.maxYcompoundLayerControlChart,
        ) ??
        yMin;

    final specAttr = widget.controlChartStats?.specAttribute;

    final lsl = widget.controlChartStats?.sel<double?>(
      specAttr?.cdeLowerSpec,
      specAttr?.cdtLowerSpec,
      specAttr?.compoundLayerLowerSpec,
    );

    final usl = widget.controlChartStats?.sel<double?>(
      specAttr?.cdeUpperSpec,
      specAttr?.cdtUpperSpec,
      specAttr?.compoundLayerUpperSpec,
    );

    final lcl = widget.controlChartStats?.sel<double?>(
      widget.controlChartStats?.cdeControlLimitIChart?.lcl,
      widget.controlChartStats?.cdtControlLimitIChart?.lcl,
      widget.controlChartStats?.compoundLayerControlLimitIChart?.lcl,
    );

    final ucl = widget.controlChartStats?.sel<double?>(
      widget.controlChartStats?.cdeControlLimitIChart?.ucl,
      widget.controlChartStats?.cdtControlLimitIChart?.ucl,
      widget.controlChartStats?.compoundLayerControlLimitIChart?.ucl,
    );

    final xWin = XWindow(minX: minXv, maxX: maxXv, desiredTicks: desiredTick);
    final ySpec = YAxisSpec(minSel: yMin, maxSel: yMax, lsl: lsl, usl: usl, lcl: lcl, ucl: ucl);

    // Convert domain points -> POJO SeriesPoint
    final src = widget.dataPoints ?? const <ChartDataPointCdeCdt>[];
    final pojo = src
        .where((p) => p.collectDate != null)
        .map((p) => SeriesPoint(
              x: p.collectDate.millisecondsSinceEpoch.toDouble(),
              y: p.value,
              isR3: p.isViolatedR3 == true,
              beyondUSL: p.isViolatedR1BeyondUSL == true,
              beyondLSL: p.isViolatedR1BeyondLSL == true,
              beyondUCL: p.isViolatedR1BeyondUCL == true,
              beyondLCL: p.isViolatedR1BeyondLCL == true,
              title: p.fullLabel,
              fgNo: p.fgNo,
            ))
        .toList();

    // ------- Logic layer -------
    final filtered = _logic.filterPointsInWindow(pojo, xWin);
    final segs = _logic.splitSegments(filtered);
    final yRes = _logic.computeYScale(ySpec);
    final xInterval = _logic.xInterval(xWin);

    // ------- Build FL data (presentational mapping) -------
    final baseColor = widget.dataLineColor ?? AppColors.colorBrand;

    LineChartBarData _line(List<SeriesPoint> pts, Color c, double w) => LineChartBarData(
          spots: pts.map((e) => FlSpot(e.x, e.y)).toList(),
          isCurved: false,
          color: c,
          barWidth: w,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
        );

    // R3 overlay (white + pink)
    final r3Overlay = segs.r3Segments
        .where((s) => s.length >= 2)
        .expand((s) => [
              _line(s, Colors.white, 5),
              _line(s, Colors.pinkAccent, 3),
            ])
        .toList();

    final nonR3Lines = segs.nonR3Segments.where((s) => s.length >= 2).map((s) => _line(s, baseColor, 2)).toList();
    final bridgeLines = segs.bridgeSegments.map((s) => _line(s, baseColor, 2)).toList();

    final dotsOnly = LineChartBarData(
      spots: segs.orderedPoints.map((e) => FlSpot(e.x, e.y)).toList(),
      isCurved: false,
      color: Colors.transparent,
      barWidth: 0,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, __, ___, ____) {
          final p = segs.orderedPoints.firstWhere((e) => e.x == spot.x);
          Color dotColor;
          if (p.isR3) {
            dotColor = Colors.pinkAccent;
          } else if (p.beyondUSL || p.beyondLSL) {
            dotColor = Colors.red;
          } else if (p.beyondUCL || p.beyondLCL) {
            dotColor = Colors.orange;
          } else {
            dotColor = baseColor;
          }
          return FlDotCirclePainter(radius: 3.5, color: dotColor, strokeWidth: 1, strokeColor: Colors.white);
        },
      ),
      belowBarData: BarAreaData(show: false),
    );

    final extraLines = ExtraLinesData(
      extraLinesOnTop: false,
      horizontalLines: [
        if ((usl ?? 0) > 0) HorizontalLine(y: usl!, color: Colors.red.shade400, strokeWidth: 2),
        if (ucl != null)     HorizontalLine(y: ucl,  color: Colors.amberAccent, strokeWidth: 1.5),
        if (lcl != null)     HorizontalLine(y: lcl,  color: Colors.amberAccent, strokeWidth: 1.5),
        if ((lsl ?? 0) > 0)  HorizontalLine(y: lsl!, color: Colors.red.shade400, strokeWidth: 2),
      ],
    );

    // Titles & grid
    final df = DateFormat('dd/MM');
    final axisFont = fontScaler(context, 14);
    Widget bottomLabel(double value, TitleMeta meta) {
      final dt = DateTime.fromMillisecondsSinceEpoch(value.round(), isUtc: true);
      final text = df.format(dt);
      return SideTitleWidget(
        meta: meta,
        space: 8,
        child: Transform.rotate(
          angle: -30 * math.pi / 180,
          child: Text(text, style: TextStyle(fontSize: axisFont, color: AppColors.colorBlack), overflow: TextOverflow.ellipsis),
        ),
      );
    }

    final titles = FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: sizeScaler(context, 32, 1.5),
          interval: yRes.interval,
          getTitlesWidget: (v, _) => Text(
            v.toStringAsFixed(2),
            style: TextStyle(color: AppColors.colorBlack, fontSize: axisFont),
          ),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: sizeScaler(context, 24, 1.5),
          interval: xInterval,
          getTitlesWidget: bottomLabel,
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );

    final grid = FlGridData(
      show: true,
      drawHorizontalLine: true,
      drawVerticalLine: true,
      horizontalInterval: yRes.interval,
      verticalInterval: xInterval,
      getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey.shade100, strokeWidth: 0.5),
      getDrawingVerticalLine:   (_) => FlLine(color: Colors.grey.shade100, strokeWidth: 0.5),
    );

    // Touch/tooltip
    final hoverColor = Colors.blueAccent;
    final touch = LineTouchData(
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
              radius: 3.5, color: AppColors.colorBrandTp, strokeWidth: 3, strokeColor: hoverColor),
          ),
        );
      }).toList(),
      touchTooltipData: LineTouchTooltipData(getTooltipItems: (s) => List<LineTooltipItem?>.filled(s.length, null)),
      touchCallback: (event, resp) {
        final noHit = !event.isInterestedForInteractions || (resp?.lineBarSpots?.isEmpty ?? true);
        if (noHit) {
          _tip.value = null;
          return;
        }
        final x = resp!.lineBarSpots!.first.x;
        final nearest = _logic.nearestByX(segs.orderedPoints, x);
        final tModel = _logic.buildTooltip(nearest, resp.lineBarSpots!.first.y);

        _tip.value = _Tip(
          local: event.localPosition!,
          content: TooltipContent(title: tModel.title, rows: tModel.rows, chips: tModel.chips, accent: hoverColor),
        );
      },
    );

    return LayoutBuilder(builder: (c, cons) {
      final chartSize = Size(widget.width ?? cons.maxWidth, widget.height ?? cons.maxHeight);

      // overlay placement
      Widget? overlay;
      final tip = _tip.value;
      if (tip != null) {
        const maxWidth = 144.0, boxH = 196.0, dotR = 8.0, gap = 8.0, pad = 8.0;
        final dx = tip.local.dx, dy = tip.local.dy;
        final canAbove = dy - (dotR + gap + boxH) >= pad;
        final canBelow = dy + (dotR + gap + boxH) <= chartSize.height - pad;
        final canRight = dx + (dotR + gap + maxWidth) <= chartSize.width - 6 * pad;
        final canLeft  = dx - (dotR + gap + maxWidth) >= pad;
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
          left = dx + dotR + 4 * gap;
          top  = dy - boxH / 2;
          final hiY = chartSize.height - boxH - pad;
          top  = (hiY <= pad) ? (chartSize.height - boxH) / 2 : top.clamp(pad, hiY);
        } else if (canLeft) {
          left = dx - dotR - gap - maxWidth;
          top  = dy - boxH / 2;
          final hiY = chartSize.height - boxH - pad;
          top  = (hiY <= pad) ? (chartSize.height - boxH) / 2 : top.clamp(pad, hiY);
        } else {
          left = (chartSize.width - maxWidth) / 2;
          top  = (chartSize.height - boxH) / 2;
        }
        final hiX = chartSize.width - maxWidth - pad;
        final hiY = chartSize.height - boxH - pad;
        if (hiX > pad) left = left.clamp(pad, hiX);
        if (hiY > pad) top  = top.clamp(pad, hiY);

        overlay = Positioned(
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
      }

      final data = LineChartData(
        minX: minXv,
        maxX: maxXv,
        minY: yRes.minY,
        maxY: yRes.maxY,
        gridData: grid,
        titlesData: titles,
        borderData: FlBorderData(show: true, border: Border.all(color: Colors.black54, width: 1)),
        extraLinesData: extraLines,
        lineBarsData: [...r3Overlay, ...nonR3Lines, ...bridgeLines, dotsOnly],
        lineTouchData: touch,
      );

      return ValueListenableBuilder<_Tip?>(
        valueListenable: _tip,
        builder: (_, __, ___) => ControlChartLargeView(
          chartSize: chartSize,
          data: data,
          tooltipOverlay: overlay,
        ),
      );
    });
  }
}

/// Internal tip carrier for overlay
class _Tip {
  final Offset local;
  final Widget content;
  _Tip({required this.local, required this.content});
}
