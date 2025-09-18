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
    // final visible = _pointsInWindow;
    // if (visible.isEmpty) {
    //   return const Center(child: Text('ไม่พบข้อมูล'));
    // }

    // ช่วงเวลา (µs)
    final double minXv = xStart.millisecondsSinceEpoch.toDouble();
    final double maxXv = xEnd.millisecondsSinceEpoch.toDouble();
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

  // จุดสำหรับวาด (กรองช่วงเวลา + sort)
  final spots = pts
      .where((p) => p.collectDate != null)
      .map((p) => FlSpot(p.collectDate!.millisecondsSinceEpoch.toDouble(), p.value))
      .where((s) => s.x >= math.min(minXv, maxXv) && s.x <= math.max(minXv, maxXv))
      .toList()
    ..sort((a, b) => a.x.compareTo(b.x));

  // หา R3 segments
  final List<List<FlSpot>> r3Segments = [];
  var cur = <FlSpot>[];
  for (final p in pts) {
    final dt = p.collectDate;
    if (dt == null) continue;
    final s = FlSpot(dt.millisecondsSinceEpoch.toDouble(), p.value);
    if (p.isViolatedR3 == true) {
      cur.add(s);
    } else {
      if (cur.isNotEmpty) {
        r3Segments.add(cur);
        cur = <FlSpot>[];
      }
    }
  }
  if (cur.isNotEmpty) r3Segments.add(cur);

  // lookup: x(epoch ms double) -> DataPoint (ใช้กับ dotPainter)
  final Map<double, ChartDataPoint> dpByX = {
    for (final p in pts.where((e) => e.collectDate != null))
      p.collectDate!.millisecondsSinceEpoch.toDouble(): p
  };

  final baseColor = dataLineColor ?? AppColors.colorBrand;

  // เส้น base — วาดจุดพร้อมสีตาม rule (ชมพู > แดง > ส้ม > default)
  final baseLine = LineChartBarData(
    spots: spots,
    isCurved: false,
    color: baseColor,
    barWidth: 2,
    isStrokeCapRound: true,
    dotData: FlDotData(
      show: true,
      getDotPainter: (spot, __, ___, ____) {
        final dp = dpByX[spot.x]; // จุดเดียวกัน
        final v = spot.y;

        // ขีดจำกัด (ถ้าต้องใช้จากค่าแทน flag)
        final upperSpec = controlChartStats?.specAttribute?.surfaceHardnessUpperSpec ?? 0.0;
        final lowerSpec = controlChartStats?.specAttribute?.surfaceHardnessLowerSpec ?? 0.0;
        final ucl       = controlChartStats?.controlLimitIChart?.ucl ?? 0.0;
        final lcl       = controlChartStats?.controlLimitIChart?.lcl ?? 0.0;

        // เลือกสีแบบ flag ก่อน ถ้าไม่มี flag ใช้เงื่อนไขค่าแทนได้
        Color dotColor;
        if (dp?.isViolatedR3 == true) {
          dotColor = Colors.pinkAccent;                           // Trend
        } else if (dp?.isViolatedR1BeyondUSL == true || dp?.isViolatedR1BeyondLSL == true ||
                  ((upperSpec > 0 && v > upperSpec) || (lowerSpec > 0 && v < lowerSpec))) {
          dotColor = Colors.red;                                   // Spec
        } else if (dp?.isViolatedR1BeyondUCL == true || dp?.isViolatedR1BeyondLCL == true ||
                  ((ucl > 0 && v > ucl) || (lcl > 0 && v < lcl))) {
          dotColor = Colors.orange;                                // Control
        } else {
          dotColor = baseColor;                                    // Default
        }

        return FlDotCirclePainter(
          radius: 3.5,
          color: dotColor,
          strokeWidth: 1,
          strokeColor: Colors.white, // ขอบขาว
        );
      },
    ),
    belowBarData: BarAreaData(show: false),
  );

  // เส้น overlay R3 (ขอบขาว + สีจริง), ปิด tooltip และไม่วาดจุด
  final r3Lines = r3Segments
      .where((seg) => seg.length >= 2)
      .expand((seg) => [
            // ขอบขาว
            LineChartBarData(
              spots: seg,
              isCurved: false,
              color: Colors.white,
              barWidth: 5,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
              showingIndicators: const [], // ไม่ร่วม tooltip
            ),
            // สีชมพูจริง
            LineChartBarData(
              spots: seg,
              isCurved: false,
              color: Colors.pinkAccent,
              barWidth: 5,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false), // จุดใช้จาก baseLine แล้ว
              belowBarData: BarAreaData(show: false),
              showingIndicators: const [], // ไม่ร่วม tooltip
            ),
          ])
      .toList();

  return [...r3Lines, baseLine];
}

@override
LineTouchData buildTouchData() {
  final points = _pointsInWindow;
  final Map<double, ChartDataPoint> map = {
    for (final p in points.where((e) => e.collectDate != null))
      p.collectDate!.millisecondsSinceEpoch.toDouble(): p,
  };

  return LineTouchData(
    // make hits easier to grab (optional)
    touchSpotThreshold: 16,
    handleBuiltInTouches: true,
    touchTooltipData: LineTouchTooltipData(
      showOnTopOfTheChartBoxArea: true,              // draw above chart
      fitInsideHorizontally: true,                   // constrain inside
      fitInsideVertically: true,
      tooltipMargin: 12,                             // avoid clinging to edge (not 0)
      maxContentWidth: 340,                          // a bit wider so it’s not too tall
      tooltipBorderRadius: BorderRadius.circular(8),
      getTooltipColor: (_) => AppColors.colorBrand.withValues(alpha: 0.9),

      // MUST return same length as `spots` (use nulls for the ones you want to skip)
      getTooltipItems: (spots) {
        if (spots.isEmpty) return const [];

        // base line is last because you return [...r3Lines, baseLine]
        final int baseIndex = spots
            .map((s) => s.barIndex)
            .reduce((a, b) => a > b ? a : b);

        return List<LineTooltipItem?>.generate(spots.length, (i) {
          final s = spots[i];

          // only base line shows tooltips (R3 overlays -> null)
          if (s.barIndex != baseIndex) return null;

          final p = map[s.x];
          if (p == null) return null;

          // Determine violations
          final bool beyondCL   = (p.isViolatedR1BeyondLCL == true) || (p.isViolatedR1BeyondUCL == true);
          final bool beyondSpec = (p.isViolatedR1BeyondLSL == true) || (p.isViolatedR1BeyondUSL == true);
          final bool trend      = (p.isViolatedR3 == true);

          // Build the text
          final buf = StringBuffer()
            ..writeln("วันที่: ${p.fullLabel}")
            ..writeln("ค่า: ${s.y.toStringAsFixed(3)}")
            ..writeln("เตา: ${p.furnaceNo}")
            ..writeln("เลขแมต: ${p.matNo}");

          // Add "การละเมิด:" **only if** there is at least one violation
            if (beyondCL || beyondSpec || trend) {
              final violations = <String>[];
              if (beyondCL)   violations.add("Beyond Control Limit");
              if (beyondSpec) violations.add("Beyond Spec Limit");
              if (trend)      violations.add("Trend");

              buf.writeln("การละเมิด: ${violations.join(", ")}");
            }


          return LineTooltipItem(
            buf.toString().trimRight(),
            AppTypography.textBody4W,
            textAlign: TextAlign.left,
          );
        });
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
