import 'dart:math' as math;
import 'dart:math' as dev;

import 'package:control_chart/domain/models/chart_data_point.dart';
import 'package:control_chart/domain/models/control_chart_stats.dart';
import 'package:control_chart/domain/types/chart_component.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';
import 'package:control_chart/ui/core/shared/dashed_line_painter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MrChartComponent extends StatelessWidget implements ChartComponent  {
  final List<ChartDataPoint>? dataPoints;      // ⬅️ already windowed by parent
  final ControlChartStats? controlChartStats;
  final Color? dataLineColor;
  final Color? backgroundColor;
  final double? height;
  final double? width;
  final int? xTick; // 4 or 6 from API

  MrChartComponent({
    super.key,
    this.dataPoints,
    this.controlChartStats,
    this.dataLineColor = AppColors.colorBrand,
    this.backgroundColor,
    this.height,
    this.width = 560,
    this.xTick,
  });

  // ---- Y scale cache ----
  double? _cachedMinY;
  double? _cachedMaxY;
  double? _cachedInterval;
  // ---------- helpers: time domain ----------
  double _minXms(List<ChartDataPoint> v) =>
      v.first.collectDate.millisecondsSinceEpoch.toDouble();

  double _maxXms(List<ChartDataPoint> v) =>
      v.last.collectDate.millisecondsSinceEpoch.toDouble();

  ({int tickCount, double stepMs}) _xTickAndStep(List<ChartDataPoint> v) {
    final double minX = _minXms(v);
    final double maxX = _maxXms(v);
    final double range = (maxX - minX).abs();

    // rule: if total ≤ 30 → 6 ticks, else → API ticks (4 or 6)
    final int total = (dataPoints?.length ?? v.length);
    final int apiTick = (xTick ?? controlChartStats?.xTick ?? 6);
    final int tickCount = (total <= 30 ? 6 : apiTick).clamp(2, 12);
    final double stepMs = range / (tickCount - 1);

    return (tickCount: tickCount, stepMs: stepMs);
  }
  
  @override
  Widget build(BuildContext context) {
    if (dataPoints == null || dataPoints!.isEmpty) {
      return const Center(child: Text('ไม่พบข้อมูล'));
    }

    return Container(
      height: height,
      width: width,
      // padding: const EdgeInsets.all(4),
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
                // titlesData: buildTitlesData(),
                borderData: buildBorderData(),
                lineBarsData: buildLineBarsData(),
                extraLinesData: buildControlLines(),
                // lineTouchData: buildTouchData(),
                minX: 0,
                maxX: (dataPoints!.length - 1).toDouble(),
                minY: getMinY(),
                maxY: getMaxY(),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Y-axis label (rotated)
              RotatedBox(
                quarterTurns: 3,
              ),
            ],
          ),
        ],
      ),
    );
  }
  static const int _windowSize = 30;

  List<dynamic> get _visiblePoints {
    // final src = dataPoints ?? const <ControlChartStats>[];
    final src = dataPoints ?? const <ChartDataPoint>[];
    if (src.length <= _windowSize) return src;
    return src.sublist(src.length - _windowSize);
  }
  
  @override
  FlGridData buildGridData() {
    final n = _visiblePoints.length;
    return FlGridData(
      show: true,
      drawHorizontalLine: true,
      drawVerticalLine: true,
      horizontalInterval: _getInterval(),                   // Y grid aligns with Y ticks
      verticalInterval: _xIntervalForCount(n),              // X grid aligns with window size
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
    // final step = _xIntervalForCount(visible.length);
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
          reservedSize: 32,   // ✅ เพิ่มความสูงของ label zone
          interval: step, 
          getTitlesWidget: (value, meta) {
            final i = value.round();
            if (i < 0 || i >= visible.length) return const SizedBox.shrink();

            return SideTitleWidget(
              meta: meta,
              space: 8,       // ✅ ดัน label ออกห่างจากกราฟ
              child: Transform.rotate(
                angle: -30 * math.pi / 180, // ใช้ radians (270° = -90°)
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
    return ExtraLinesData(
      extraLinesOnTop: false,
      horizontalLines: [
        
        HorizontalLine(
          y: controlChartStats?.controlLimitMRChart?.ucl ?? 0.0,
          color: Colors.amberAccent,
          strokeWidth: 1.5,
        ),
        
        // Average Line
        HorizontalLine(
          y: controlChartStats?.mrAverage ?? 0.0,
          color: AppColors.colorSuccess1,
          strokeWidth: 2,
        ),

        // HorizontalLine(
        //   y: controlChartStats?.controlLimitMRChart?.lcl ?? 0.0,
        //   color: Colors.amberAccent,
        //   strokeWidth: 1.5,
        // ),

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

            // final upperSpec = controlChartStats?.specAttribute?.surfaceHardnessUpperSpec ?? 0.0;
            // final lowerSpec = controlChartStats?.specAttribute?.surfaceHardnessLowerSpec ?? 0.0;
            final ucl = controlChartStats?.controlLimitMRChart?.ucl ?? 0.0;
            // final lcl = controlChartStats?.controlLimitMRChart?.lcl ?? 0.0;

            if ((ucl > 0 && v > ucl)) {
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
            final index = barSpot.x.toInt() - 1; // map กลับจาก x -> index เดิม
            if (index >= 0 && index < (dataPoints!.length - 1)) { // ให้สอดคล้องกับ .take(nullMrValue)
              final mr = dataPoints![index].mrValue;
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
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      direction: Axis.horizontal,
      alignment: WrapAlignment.spaceEvenly,
      children: [
        // buildLegendItem('USL', Colors.red, false, formatValue(controlChartStats?.specAttribute?.)),
        buildLegendItem('UCL', Colors.orange, false, formatValue(controlChartStats?.controlLimitMRChart?.ucl)),
        buildLegendItem('AVG', Colors.green, false, formatValue(controlChartStats?.mrAverage)),
        // buildLegendItem('LCL', Colors.orange, false, formatValue(controlChartStats?.controlLimitIChart?.lcl)),
        // buildLegendItem('LSL', Colors.red, false, formatValue(controlChartStats?.specAttribute?.surfaceHardnessLowerSpec)),
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
    final spotMin = 0.0;
    final spotMax = controlChartStats?.yAxisRange?.maxYsurfaceHardnessMrChart ?? spotMin;

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
    if (mant < 2.5) return 5.0 * mag;
    if (mant < 5.0) return 10.0 * mag;
    return 10.0 * mag;
  }

  // ---------- X helpers ----------
  double _xIntervalForCount(int n) {
    if (n <= 8) return 1;
    if (n <= 12) return 2;
    if (n <= 24) return 3; // good default for 24
    return (n / 8).floorToDouble().clamp(1, 10);
  }

  String formatValue(double? value) {
    if (value == null || value == 0.0) return 'N/A';
    return value.toStringAsFixed(2);
  }
}