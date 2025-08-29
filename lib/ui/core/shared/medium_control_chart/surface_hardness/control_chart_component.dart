import 'dart:math';
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

  const ControlChartComponent({
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
      // horizontalInterval: dataPoints!.length/10,
      horizontalInterval: visibleSpot(dataPoints).length.toDouble()/2,
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
        // axisNameSize: 36, // กำหนดขนาด axis name
        axisNameWidget: SizedBox(
          width: width,
        ),
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 16, // เพิ่มขนาดสำหรับ X-axis labels
          interval: _calculateXInterval(),
          getTitlesWidget: 
          (value, meta) {
            final index = value.toInt();
            if (index >= 0 && index < dataPoints!.length) {
              return 
                Text(
                  dataPoints![index].label,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 8, // เพิ่มขนาดฟอนต์
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
        // spots: dataPoints!
        //     .asMap()
        //     .entries
        //     .where((entry) => entry.key % interval == 0)
        //     .map((entry) => FlSpot(entry.key.toDouble(), entry.value.value))
        //     .toList(),

        spots: visibleSpot(dataPoints),
        
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

  double _getInterval() {
    final spotMin = getMinSpot();
    final spotMax = getMaxSpot();
    final range = (spotMax - spotMin).abs();
    
    if (range < 10) {
      return 2.5; // hardcode สำหรับ range เล็ก
    }

    if (range < 5) {
      return 1.25; // hardcode สำหรับ range เล็ก
    }
    
    final targetIntervals = 2;
    final tempInterval = range / targetIntervals;
    
    // Conditional interval selection
    if (tempInterval < 25) {
      return 25.0;
    }
    else if (tempInterval < 50) {
      return 50.0;
    }
    else if (tempInterval < 75) {
      return 75.0;
    }
    else if (tempInterval < 100) {
      return 100.0;
    } 
    else {
      return (tempInterval / 100).ceil() * 100.0; // สำหรับค่าใหญ่กว่า
    } 
  }

  

  @override
  double getMinY() {
    final controlLCL = controlChartStats?.controlLimitIChart?.lcl;
    final specLower = controlChartStats?.specAttribute?.surfaceHardnessLowerSpec;
    final spotMin = getMinSpot();
    final spotMax = getMaxSpot();
    (spotMax - spotMin).abs();
    
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

  String formatValue(double? value) {
    if (value == null || value == 0.0) return 'N/A';
    return value.toStringAsFixed(2);
  }

  List<FlSpot> visibleSpot(List<ChartDataPoint>? dataPoints, {int maxPoints = 24}) {
    if (dataPoints == null || dataPoints.isEmpty) return const <FlSpot>[];

    final len = dataPoints.length;
    final start = (len - maxPoints).clamp(0, len);
    final visibleLen = len - start;

    return List<FlSpot>.generate(
      visibleLen,
      (i) => FlSpot(
        i.toDouble(),                      // x = index ภายในหน้าต่างที่ตัดมา
        dataPoints[start + i].value,       // y = ค่า point
      ),
    );
  }

  Widget? _legendIfHas(String label, Color color, String v) {
    if (v == 'N/A') return null;
    return buildLegendItem(label, color, false, v);
  }

}
