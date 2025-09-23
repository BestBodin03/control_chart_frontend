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

/// ---------------------------------------------------------------------------
/// Overlay tooltip (in-file, reusable, no layout change)
/// ---------------------------------------------------------------------------
// ---- Safe overlay tooltip (no layout change) -------------------------------
class _SafeChartTooltip {
  _SafeChartTooltip._();
  static final _SafeChartTooltip instance = _SafeChartTooltip._();

  OverlayEntry? _entry;

  Rect _chartRect = Rect.zero;
  Offset _localDot = Offset.zero;
  String _text = '';
  Color _bg = const Color(0xFF000000);
  double _dotR = 6;
  double _gap = 10;
  double _maxW =360;
  TextStyle _style = AppTypography.textBody4W;

  void showOrUpdate(
    BuildContext context, {
    required Rect chartRectGlobal,
    required Offset localDotPx,
    required String text,
    required Color background,
    required TextStyle textStyle,
    double dotRadius = 6,
    double gap = 12,
    double maxWidth = 360,
  }) {
    _chartRect = chartRectGlobal;
    _localDot = localDotPx;
    _text = text;
    _bg = background;
    _style = textStyle;
    _dotR = dotRadius;
    _gap = gap;
    _maxW = maxWidth;

    if (_entry == null) {
      _entry = OverlayEntry(builder: (_) => _build());
      Overlay.of(context, rootOverlay: true).insert(_entry!);
    } else {
      _entry!.markNeedsBuild();
    }
  }

  void hide() { _entry?.remove(); _entry = null; }

  Widget _build() {
    final lines = _text.split('\n');
    final estW = ((lines.fold<int>(0, (m, l) => m > l.length ? m : l.length)) * 8.0)
        .clamp(80.0, _maxW) + 16.0;
    final estH = lines.length * 16.0 + 16.0;

    final globalDot = _chartRect.topLeft + _localDot;

    // try above
    Offset candidate = Offset(
      globalDot.dx - estW / 2,
      globalDot.dy - _dotR - _gap - estH,
    );
    // if not enough above -> below
    if (candidate.dy < _chartRect.top) {
      candidate = Offset(
        globalDot.dx - estW / 2,
        globalDot.dy + _dotR + _gap,
      );
    }

    double x = candidate.dx.clamp(_chartRect.left, _chartRect.right - estW);
    double y = candidate.dy.clamp(_chartRect.top, _chartRect.bottom - estH);

    // left corner → right of dot
    if (x == _chartRect.left && (globalDot.dx - estW / 2) < _chartRect.left + _dotR + _gap) {
      x = (globalDot.dx + _dotR + _gap).clamp(_chartRect.left, _chartRect.right - estW);
      y = (globalDot.dy - estH / 2).clamp(_chartRect.top, _chartRect.bottom - estH);
    }
    // right corner → left of dot
    if (x == _chartRect.right - estW &&
        (globalDot.dx + estW / 2) > _chartRect.right - (_dotR + _gap)) {
      x = (globalDot.dx - _dotR - _gap - estW).clamp(_chartRect.left, _chartRect.right - estW);
      y = (globalDot.dy - estH / 2).clamp(_chartRect.top, _chartRect.bottom - estH);
    }

    return Positioned(
      left: x, top: y, width: estW, height: estH,
      child: IgnorePointer(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(8)),
          child: Text(_text, style: _style),
        ),
      ),
    );
  }
}


/// ---------------------------------------------------------------------------
/// Main chart (Stateless, same layout)
/// ---------------------------------------------------------------------------
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

  // key to measure chart rect (no layout change)
  final GlobalKey _chartKey = GlobalKey();

  // ---------- คำนวณ/แคชสเกลแกน Y ----------
  double? _cachedMinY;
  double? _cachedMaxY;
  double? _cachedInterval;

  // ---------- จุดที่อยู่ในหน้าต่างเวลา ----------
  List<ChartDataPoint> get _pointsInWindow {
    final src = dataPoints ?? const <ChartDataPoint>[];
    if (src.isEmpty) return const <ChartDataPoint>[];
    final startUs = xStart.millisecondsSinceEpoch;
    final endUs = xEnd.millisecondsSinceEpoch;
    final lo = math.min(startUs, endUs).toDouble();
    final hi = math.max(startUs, endUs).toDouble();

    return src
        .where((p) {
          final t = p.collectDate.millisecondsSinceEpoch.toDouble();
          return t >= lo && t <= hi;
        })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final double minXv = xStart.millisecondsSinceEpoch.toDouble();
    final double maxXv = xEnd.millisecondsSinceEpoch.toDouble();
    final double safeRange = (maxXv - minXv).abs().clamp(1.0, double.infinity);

    final int desiredTick = controlChartStats?.xTick ?? 6;
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
            // keep layout: just wrap LineChart with KeyedSubtree (no visual change)
            child: KeyedSubtree(
              key: _chartKey,
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
                  lineTouchData: buildTouchData(), // pass context to use overlay
                ),
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
    final double minXv = minX ?? xStart.millisecondsSinceEpoch.toDouble();
    final double maxXv = maxX ?? xEnd.millisecondsSinceEpoch.toDouble();
    final PeriodType periodType = controlChartStats?.periodType ?? PeriodType.ONE_MONTH;
    final df = DateFormat('dd/MM');
    final double step = getXInterval(periodType, minXv, maxXv);

    Widget bottomLabel(double value, TitleMeta meta) {
      final dt = DateTime.fromMillisecondsSinceEpoch(value.round(), isUtc: true);
      final text = df.format(dt);
      return SideTitleWidget(
        meta: meta,
        space: 8,
        child: Transform.rotate(
          angle: -30 * math.pi / 180,
          child: Text(
            text,
            style: const TextStyle(fontSize: 8, color: Colors.black54),
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
            v.toStringAsFixed(0),
            style: const TextStyle(color: Colors.black54, fontSize: 8),
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
      return [LineChartBarData(spots: const [], color: dataLineColor, barWidth: 2)];
    }

    final minXv = xStart.millisecondsSinceEpoch.toDouble();
    final maxXv = xEnd.millisecondsSinceEpoch.toDouble();

    final spots = pts
        .where((p) => p.collectDate != null)
        .map((p) => FlSpot(p.collectDate.millisecondsSinceEpoch.toDouble(), p.value))
        .where((s) => s.x >= math.min(minXv, maxXv) && s.x <= math.max(minXv, maxXv))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));

    final Map<double, ChartDataPoint> dpByX = {
      for (final p in pts.where((e) => e.collectDate != null))
        p.collectDate.millisecondsSinceEpoch.toDouble(): p
    };

    final baseColor = dataLineColor ?? AppColors.colorBrand;

    final baseLine = LineChartBarData(
      spots: spots,
      isCurved: false,
      color: baseColor,
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, __, ___, ____) {
          final dp = dpByX[spot.x];
          final v = spot.y;

          final upperSpec = controlChartStats?.specAttribute?.surfaceHardnessUpperSpec ?? 0.0;
          final lowerSpec = controlChartStats?.specAttribute?.surfaceHardnessLowerSpec ?? 0.0;
          final ucl       = controlChartStats?.controlLimitIChart?.ucl ?? 0.0;
          final lcl       = controlChartStats?.controlLimitIChart?.lcl ?? 0.0;

          Color dotColor;
          if (dp?.isViolatedR3 == true) {
            dotColor = Colors.pinkAccent;
          } else if (dp?.isViolatedR1BeyondUSL == true || dp?.isViolatedR1BeyondLSL == true ||
              ((upperSpec > 0 && v > upperSpec) || (lowerSpec > 0 && v < lowerSpec))) {
            dotColor = Colors.red;
          } else if (dp?.isViolatedR1BeyondUCL == true || dp?.isViolatedR1BeyondLCL == true ||
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
    );

    // You kept R3 overlay earlier; if you want it here, add back your segments.
    return [baseLine];
  }

static List<LineTooltipItem?> _emptyTooltip(List<LineBarSpot> _) => const [];

@override
LineTouchData buildTouchData() {
  final points = _pointsInWindow;
  final Map<double, ChartDataPoint> map = {
    for (final p in points.where((e) => e.collectDate != null))
      p.collectDate.millisecondsSinceEpoch.toDouble(): p,
  };

  return LineTouchData(
    handleBuiltInTouches: false,        // use our overlay instead
    touchSpotThreshold: 18,

    // hovered dot: bigger + brand color
    getTouchedSpotIndicator: (barData, indexes) {
      return indexes.map((_) => TouchedSpotIndicatorData(
        FlLine(color: const Color(0x00000000)), // transparent
        FlDotData(
          show: true,
          getDotPainter: (spot, __, ___, ____) => FlDotCirclePainter(
            radius: 6.0,
            color: AppColors.colorBrand,
            strokeWidth: 2,
            strokeColor: const Color(0xFFFFFFFF),
          ),
        ),
      )).toList();
    },

    // disable fl_chart tooltip entirely
    touchTooltipData: const LineTouchTooltipData(
      tooltipMargin: 0,
      getTooltipItems: _emptyTooltip,
    ),

    touchCallback: (event, resp) {
      final noHit = !event.isInterestedForInteractions ||
          resp?.lineBarSpots == null || resp!.lineBarSpots!.isEmpty;

      final box = _chartKey.currentContext?.findRenderObject() as RenderBox?;
      if (noHit || box == null || !box.attached) {
        _SafeChartTooltip.instance.hide();
        return;
      }

      final s = resp.lineBarSpots!.first;
      final p = map[s.x];
      if (p == null) { _SafeChartTooltip.instance.hide(); return; }

      final bool beyondCL   = p.isViolatedR1BeyondLCL == true || p.isViolatedR1BeyondUCL == true;
      final bool beyondSpec = p.isViolatedR1BeyondLSL == true || p.isViolatedR1BeyondUSL == true;
      final bool trend      = p.isViolatedR3 == true;

      final buf = StringBuffer()
        ..writeln("วันที่: ${p.fullLabel}")
        ..writeln("ค่า: ${s.y.toStringAsFixed(3)}")
        ..writeln("เตา: ${p.furnaceNo}")
        ..writeln("เลขแมต: ${p.matNo}");
      if (beyondCL || beyondSpec || trend) {
        final v = <String>[];
        if (beyondCL)   v.add("Over Control");
        if (beyondSpec) v.add("Over Spec Limit");
        if (trend)      v.add("Trend");
        buf.writeln("การละเมิด: ${v.join(", ")}");
      }

      Color bg = AppColors.colorBrand.withValues(alpha: 0.9);

      // measure chart rect and show/update overlay
      final rect = box.localToGlobal(Offset.zero) & box.size;
      _SafeChartTooltip.instance.showOrUpdate(
        _chartKey.currentContext!,                   // context for Overlay.of
        chartRectGlobal: rect,
        localDotPx: event.localPosition!,             // px inside chart
        text: buf.toString().trimRight(),
        background: bg,
        textStyle: AppTypography.textBody4W,
        dotRadius: 6.0, // MUST match hovered radius
        gap: 10,
        maxWidth: 340,
      );
    },
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
        Text(label, style: const TextStyle(
          fontSize: 10,
          color: AppColors.colorBlack,
          fontWeight: FontWeight.bold)),
        const SizedBox(width: 4),
        Text(value ?? 'N/A',
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.colorBlack,
              fontWeight: FontWeight.bold,
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
