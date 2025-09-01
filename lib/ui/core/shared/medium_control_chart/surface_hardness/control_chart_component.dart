import 'dart:math';
import 'dart:math' as math;
import 'package:control_chart/domain/models/chart_data_point.dart';
import 'package:control_chart/domain/models/control_chart_stats.dart';
import 'package:control_chart/domain/types/chart_component.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';
import 'package:control_chart/ui/core/shared/dashed_line_painter.dart' show DashedLinePainter;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

  
class ControlChartComponent extends StatelessWidget implements ChartComponent {
  final List<ChartDataPoint>? dataPoints;
  final ControlChartStats? controlChartStats;
  // final String xAxisLabel;
  // final String yAxisLabel;
  final Color? dataLineColor;
  final Color? backgroundColor;
  final double? height;
  final double? width;

  ControlChartComponent({
    super.key,
    this.dataPoints,
    this.controlChartStats,
    // this.xAxisLabel = 'Date (mm/dd)',
    // this.yAxisLabel = 'Surface Hardness',
    this.dataLineColor = AppColors.colorBrand,
    this.backgroundColor,
    this.height,
    this.width = 560,
  });
  
  @override
  Widget build(BuildContext context) {
    if (dataPoints == null || dataPoints!.isEmpty) {
      return const Center(child: Text('No data available'));
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
                titlesData: buildTitlesData(),
                borderData: buildBorderData(),
                lineBarsData: buildLineBarsData(),
                extraLinesData: buildControlLines(),
                lineTouchData: buildTouchData(),
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
  
  @override
  FlGridData buildGridData() {
    return FlGridData(
      show: true,
      drawHorizontalLine: true,
      drawVerticalLine: true,
      horizontalInterval: dataPoints!.length/10,
      // horizontalInterval: visibleSpot(dataPoints).length.toDouble()/4,
      verticalInterval: 24,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: Colors.grey.shade100,
          strokeWidth: 0.5,
        );
      },
      getDrawingVerticalLine: (value) {
        return FlLine(
          color: Colors.grey.shade100,
          strokeWidth: 0.5,
        );
      },
    );
  }

  @override
  FlTitlesData buildTitlesData() {
    return FlTitlesData(
        leftTitles: AxisTitles(
        // axisNameSize: 16, // กำหนดขนาด axis name
        axisNameWidget: SizedBox(
          width: height,
        ),
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 24,
          interval: _calculateYAxisInterval(),
          getTitlesWidget: (value, meta) {
            return Text(
              value.toStringAsFixed(0),
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 8,
              ),
            );
          },
        ),
        ),
      bottomTitles: AxisTitles(
        axisNameWidget: SizedBox(width: width),
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 28, // 👈 เพิ่มพื้นที่เผื่อ label หมุน
          interval: _calculateXInterval(),
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index >= 0 && index < dataPoints!.length) {
              return RotatedBox(
                quarterTurns: 3, // 1 = 90 องศา, 3 = -90 องศา
                child: Text(
                  dataPoints![index].label,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 8,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
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
        // USL (Upper Specification Limit)
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

    if (controlChartStats?.specAttribute?.surfaceHardnessTarget != null &&
        controlChartStats!.specAttribute!.surfaceHardnessTarget != 0.0)
      HorizontalLine(
        y: controlChartStats!.specAttribute!.surfaceHardnessTarget!,
        color: Colors.deepPurple.shade300,
        strokeWidth: 1.5,
      ),

        
        // Average Line
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
        
        // LSL (Lower Specification Limit)
      if ((controlChartStats?.specAttribute?.surfaceHardnessLowerSpec ?? 0.0) > 0.0)
        HorizontalLine(
          y: controlChartStats!.specAttribute!.surfaceHardnessLowerSpec!,
          color: Colors.red.shade400,
          strokeWidth: 2,
        ),
      ],
    );
  }

  @override
  List<LineChartBarData> buildLineBarsData() {
  // final len = dataPoints!.length;
  // final start = (len - 24).clamp(0, len);
  // final visible = dataPoints!.sublist(start, len); // <= 24 จุด (ล่าสุด)

  // final spots = List.generate(
  //   visible.length,
  //   (i) => FlSpot(i.toDouble(), visible[i].value),
  // );

    return [
      LineChartBarData(
        spots: dataPoints!
            .asMap()
            .entries
            .where((entry) => entry.key % 1 == 0)
            .map((entry) => FlSpot(entry.key.toDouble(), entry.value.value))
            .toList(),

        // spots: visibleSpot(dataPoints),
        
        isCurved: false,
        color: dataLineColor,
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) {
            final realIndex = spot.x.toInt();
            final value = dataPoints![realIndex].value;
            Color dotColor = dataLineColor!;
            
            // OVER LIMIT #RULE 1
            if ((controlChartStats?.specAttribute?.surfaceHardnessUpperSpec ?? 0.0) > 0.0 &&
              (value > (controlChartStats?.specAttribute?.surfaceHardnessUpperSpec ?? 0.0) || 
                value < (controlChartStats?.specAttribute?.surfaceHardnessLowerSpec ?? 0.0))) {
            dotColor = Colors.red; // Out of spec
            } else if (value > (controlChartStats?.controlLimitIChart?.ucl ?? 0.0) || 
                      value < (controlChartStats?.controlLimitIChart?.lcl ?? 0.0)) {
            dotColor = Colors.orange; // Warning zone
            }
            
            return FlDotCirclePainter(
              radius: 4,
              color: dotColor,
              strokeWidth: 2,
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
        // กัน tooltip หลุดกรอบ/ถูกตัด
        fitInsideHorizontally: true,
        fitInsideVertically: true,
        tooltipMargin: 8,
        getTooltipItems: (spots) {
          return spots.map((barSpot) {
            final index = barSpot.x.toInt();
            if (index >= 0 && index < dataPoints!.length) {
              return LineTooltipItem(
                "วันที่: ${dataPoints![index].fullLabel}\n"
                "ค่า: ${dataPoints![index].value.toStringAsFixed(3)}\n"
                "เตา: ${dataPoints![index].furnaceNo}\n"
                "เลขแมต: ${dataPoints![index].matNo}",
                AppTypography.textBody3W,
                textAlign: TextAlign.left,
              );
            }
            return null;
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
                ? CustomPaint(
                    painter: DashedLinePainter(color: color),
                  )
                : null,
          ),
        ),
        const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.colorBlack,
              ),
            ),
        const SizedBox(width: 8),
            Text(
              value ?? 'N/A',
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.colorBlack,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
    );
  }

  @override
  double getMinY() {
    final controlLCL = controlChartStats?.controlLimitIChart?.lcl;
    final specLower = controlChartStats?.specAttribute?.surfaceHardnessLowerSpec;
    final spotMin = getMinSpot();
    final spotMax = getMaxSpot();
    (spotMax - spotMin).abs();
    // print('$spotMin, $spotMax');
    
    // คำนวณ base min
    double baseMin = spotMin;
    if (specLower != null && specLower > 0) {
      baseMin = min(baseMin, specLower * 0.95);
    } else if (controlLCL != null && controlLCL > 0) {
      baseMin = min(baseMin, controlLCL * 0.95);
    }
    
    final interval = _getInterval();
    final calculatedMin = (baseMin / interval).floor() * interval;
    return max(0.0, calculatedMin);
  }

  @override
  double getMaxY() {
    final controlUCL = controlChartStats?.controlLimitIChart?.ucl;
    final specUpper = controlChartStats?.specAttribute?.surfaceHardnessUpperSpec;
    final spotMin = getMinSpot();
    final spotMax = getMaxSpot();
    (spotMax - spotMin).abs();
    
    // คำนวณ base max
    double baseMax = spotMax;
    if (specUpper != null && specUpper > 0) {
      baseMax = max(baseMax, specUpper * 1.05);
    } else if (controlUCL != null && controlUCL > 0) {
      baseMax = max(baseMax, controlUCL * 1.05);
    }
    
    final interval = _getInterval();
    return (baseMax / interval).ceil() * interval;
  }

  double _calculateYAxisInterval() {
    return _getInterval(); // ใช้ interval ที่คำนวณแล้ว
  }
    
  double _calculateXInterval() {
    int pointCount = dataPoints!.length;
    
    if (pointCount <= 24) return 1.0;
    return (pointCount / 24).ceilToDouble();
  }

  double getMaxSpot() {
  if (dataPoints == null || dataPoints!.isEmpty) {
    return 0.0;
  }
  
  final maxSpot = dataPoints!
      .map((point) => point.value)
      .where((value) => value > 0)
      .fold<double>(double.negativeInfinity, max);

  return maxSpot;
  }

  double getMinSpot() {
  if (dataPoints == null || dataPoints!.isEmpty) {
    return 0.0;
  }
  
  final minSpot = dataPoints!
      .map((point) => point.value)
      .where((value) => value > 0)
      .fold<double>(double.infinity, min);
  
  return minSpot;
  }

// ---------- Utilities ----------
double? _minNonNull(List<double?> xs) {
  double? m;
  for (final v in xs) {
    if (v == null) continue;
    m = (m == null) ? v : (v < m ? v : m);
  }
  return m;
}

double? _maxNonNull(List<double?> xs) {
  double? m;
  for (final v in xs) {
    if (v == null) continue;
    m = (m == null) ? v : (v > m ? v : m);
  }
  return m;
}

// ปัด interval ให้เป็น “nice step” (1, 2, 2.5, 5) × 10^k โดยปัด "ขึ้น"
double _niceStepCeil(double x) {
  if (x <= 0 || x.isNaN || x.isInfinite) return 1.0;
  final exp = (math.log(x) / math.log(10)).floor(); // log10
  final mag = math.pow(10.0, exp).toDouble();
  final mant = x / mag;
  if (mant <= 1.0) return 1.0 * mag;
  if (mant <= 2.0) return 2.0 * mag;
  if (mant <= 2.5) return 2.5 * mag;
  if (mant <= 5.0) return 5.0 * mag;
  return 10.0 * mag;
}

  // หา next nice step ที่ “ใหญ่ขึ้นจาก step ปัจจุบัน”
  double _nextNiceStep(double step) {
    // log10(step) = log(step) / log(10)
    final exp = (math.log(step) / math.log(10)).floor();
    final mag = math.pow(10.0, exp).toDouble();
    final mant = step / mag;

    if (mant < 1.0)  return 1.0 * mag;
    if (mant < 2.0)  return 2.0 * mag;
    if (mant < 2.5)  return 2.5 * mag;
    if (mant < 5.0)  return 5.0 * mag;
    return 10.0 * mag; // ข้ามขึ้นไปอีกหลัก
  }
// ---------- Core scaling ----------
// เก็บค่าไว้ให้ getMinY/getMaxY ใช้ เพื่อให้ divisions = 6 เสมอ
double? _cachedMinY;
double? _cachedMaxY;
double? _cachedInterval;

/// ข้อกำหนด:
/// - ต้องได้ divisions = 6 (range / interval == 6)
/// - minY = ค่าต่ำสุดจาก SpotMin, SpecLower, LCL (จริง ๆ คือ "สแนปลง" จากค่านี้)
/// - maxY = ค่าสูงสุดจาก SpotMax, SpecUpper, UCL (จริง ๆ คือ "สแนปขึ้น" แล้วขยายให้ครบ 6 ช่อง)
double _getInterval() {
  // 1) อ่านค่า base จาก Spot/Spec/CL
  final spotMin = getMinSpot();
  final spotMax = getMaxSpot();

  final specLower = controlChartStats?.specAttribute?.surfaceHardnessLowerSpec;
  final specUpper = controlChartStats?.specAttribute?.surfaceHardnessUpperSpec;
  final lcl       = controlChartStats?.controlLimitIChart?.lcl;
  final ucl       = controlChartStats?.controlLimitIChart?.ucl;

  // baseMin/baseMax คือ "ขอบโลกความจริง" ก่อนสแนป
  final baseMin = _minNonNull([spotMin, specLower, lcl]) ?? spotMin;
  final baseMax = _maxNonNull([spotMax, specUpper, ucl]) ?? spotMax;

  // กันกรณีข้อมูลไม่สมเหตุผล
  if (baseMax <= baseMin) {
    _cachedMinY = baseMin;
    _cachedMaxY = baseMin + 4; // สร้างช่วงบังคับ
    _cachedInterval = 1.0;
    return _cachedInterval!;
  }

  // 2) คำนวณ interval แบบ "อยากได้" ให้มี 6 ช่อง
  final ideal = (baseMax - baseMin) / 4.0;

  // 3) เลือก nice step ที่ "ปัดขึ้น" จาก ideal
  double interval = _niceStepCeil(ideal);

  // 4) สแนป min ลง & max ขึ้น ด้วย interval นี้
  double minY = (baseMin / interval).floor() * interval;
  double maxY = (baseMax / interval).ceil()  * interval;

  // 5) ตรวจจำนวนช่องจริง
  int d = ((maxY - minY) / interval).round();

  if (d < 4) {
    // ขยาย max ให้ครบ 6 ช่อง
    maxY = minY + 4 * interval;
    d = 4;
  } else if (d > 4) {
    // เพิ่ม interval เป็น next nice step จนกว่าจะ ≤ 6 แล้วบังคับให้ = 6
    while (true) {
      interval = _nextNiceStep(interval);
      minY = (baseMin / interval).floor() * interval;
      maxY = (baseMax / interval).ceil()  * interval;
      d = ((maxY - minY) / interval).round();
      if (d <= 4) {
        maxY = minY + 4 * interval;
        d = 4;
        break;
      }
    }
  } else {
    // d == 6 แล้ว — ผ่าน
  }

  // 6) เก็บค่า cache ให้ getMinY/getMaxY ใช้
  _cachedMinY = minY;
  _cachedMaxY = maxY;
  _cachedInterval = interval;

  // ต้องได้ range/interval == 6 เสมอ
  // (maxY - minY) / interval == 6
  return interval;
}

  String formatValue(double? value) {
    if (value == null || value == 0.0) return 'N/A';
    return value.toStringAsFixed(2);
  }

  // List<FlSpot> visibleSpot(List<ChartDataPoint>? dataPoints, {int maxPoints = 24}) {
  //   if (dataPoints == null || dataPoints.isEmpty) return const <FlSpot>[];

  //   final len = dataPoints.length;
  //   final start = (len - maxPoints).clamp(0, len);
  //   final visibleLen = len - start;

  //   return List<FlSpot>.generate(
  //     visibleLen,
  //     (i) => FlSpot(
  //       i.toDouble(),                      // x = index ภายในหน้าต่างที่ตัดมา
  //       dataPoints[start + i].value,       // y = ค่า point
  //     ),
  //   );
  // }

  Widget? _legendIfHas(String label, Color color, String v) {
    if (v == 'N/A') return null;
    return buildLegendItem(label, color, false, v);
  }

}
