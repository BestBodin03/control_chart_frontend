import 'package:control_chart/domain/models/chart_data_point.dart';
import 'package:control_chart/domain/models/control_chart_stats.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';
import 'package:control_chart/ui/core/shared/dashed_line_painter.dart' show DashedLinePainter;
import 'package:control_chart/ui/core/shared/table_component.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

  
class ControlChartComponentSmall extends StatelessWidget {
  final List<ChartDataPoint>? dataPoints;
  final ControlChartStats? controlChartStats;
  // final String xAxisLabel;
  // final String yAxisLabel;
  final Color? dataLineColor;
  final Color? backgroundColor;
  final double? height;
  final double? width;

  const ControlChartComponentSmall({
    super.key,
    this.dataPoints,
    this.controlChartStats,
    // this.xAxisLabel = 'Date (mm/dd)',
    // this.yAxisLabel = 'Surface Hardness',
    this.dataLineColor = AppColors.colorBrand,
    this.backgroundColor,
    this.height = 240,
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
          // Chart Title
          // Text(
          //   'Control Chart',
          //   style: AppTypography.textBody3B,
          // ),
          // const SizedBox(height: 4),
          
          // The LineChart
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
          
          // const SizedBox(height: 4),
          
          // Axis Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Y-axis label (rotated)
              RotatedBox(
                quarterTurns: 3,
                // child: Text(
                //   yAxisLabel, // Surface Hardness
                //   style: const TextStyle(
                //     fontSize: 14,
                //     fontWeight: FontWeight.w500,
                //     color: Colors.black87,
                //   ),
                // ),
              ),
              // X-axis label
              // Text(
              //   xAxisLabel, // Date (mm/dd)
              //   style: const TextStyle(
              //     fontSize: 14,
              //     fontWeight: FontWeight.w500,
              //     color: Colors.black87,
              //   ),
              // ),
            ],
          ),
          
          // const SizedBox(height: 4),
          
          // // Legend
          // buildLegend(),
        ],
      ),
    );
  }
  
  FlGridData buildGridData() {
    return FlGridData(
      show: true,
      drawHorizontalLine: true,
      drawVerticalLine: true,
      horizontalInterval: _calculateYAxisInterval(),
      // horizontalInterval: 24,
      verticalInterval: 24,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: Colors.grey.shade300,
          strokeWidth: 0.5,
        );
      },
      getDrawingVerticalLine: (value) {
        return FlLine(
          color: Colors.grey.shade300,
          strokeWidth: 0.5,
        );
      },
    );
  }

  FlTitlesData buildTitlesData() {
    return FlTitlesData(
        leftTitles: AxisTitles(
        // axisNameSize: 16, // กำหนดขนาด axis name
        axisNameWidget: SizedBox(
          width: height,
          // child: Text(
          //   yAxisLabel,
          //   style: AppTypography.textBody3BBold,
          //   textAlign: TextAlign.center,
          // ),
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
          // child: Text(
          //   xAxisLabel,
          //   style: AppTypography.textBody3BBold,
          //   textAlign: TextAlign.center,
          // ),
        ),
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 16, // เพิ่มขนาดสำหรับ X-axis labels
          interval: _calculateXInterval(),
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index >= 0 && index < dataPoints!.length) {
              return 
                // padding: const EdgeInsets.only(top: 8.0),
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

  FlBorderData buildBorderData() {
    return FlBorderData(
      show: true,
      border: Border.all(
        color: Colors.black54,
        width: 1,
      ),
    );
  }

  ExtraLinesData buildControlLines() {
    return ExtraLinesData(
      extraLinesOnTop: false,
      horizontalLines: [
        // USL (Upper Specification Limit)
        HorizontalLine(
          y: (controlChartStats?.controlLimitIChart?.ucl ?? 0.0) * 1.2,
          color: Colors.red.shade400,
          strokeWidth: 2,
        ),
        
        // UCL (Upper Control Limit)
        HorizontalLine(
          y: controlChartStats?.controlLimitIChart?.ucl ?? 0.0,
          color: Colors.amberAccent,
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
        HorizontalLine(
          y: (controlChartStats?.controlLimitIChart?.lcl ?? 0.0) * 0.8,
          color: Colors.red.shade400,
          strokeWidth: 2,
        ),
      ],
    );
  }

  List<LineChartBarData> buildLineBarsData() {
    final interval = _calculateXInterval().toInt();
    
    return [
      LineChartBarData(
        spots: dataPoints!
            .asMap()
            .entries
            .where((entry) => entry.key % interval == 0)
            .map((entry) => FlSpot(entry.key.toDouble(), entry.value.value))
            .toList(),
        
        isCurved: false,
        color: dataLineColor,
        barWidth: 4,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) {
            final realIndex = spot.x.toInt();
            final value = dataPoints![realIndex].value;
            Color dotColor = dataLineColor!;
            
            // Color dots based on control limits
            if (value > (controlChartStats?.controlLimitIChart?.ucl ?? 0.0) * 1.2 || 
                value < (controlChartStats?.controlLimitIChart?.lcl ?? 0.0) * 0.8) {
              dotColor = Colors.red; // Out of control
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

  LineTouchData buildTouchData() {
    return LineTouchData(
      handleBuiltInTouches: true,
      touchTooltipData: LineTouchTooltipData(
        maxContentWidth: 150,
        getTooltipColor: (_) => AppColors.colorBrand,
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


  // Widget buildLegend() {
  //   return Wrap(
  //     spacing: 16,
  //     runSpacing: 8,
  //     direction: Axis.vertical,
  //     children: [
  //       buildLegendItem('USL', Colors.red, false, (controlChartStats?.controlLimitIChart?.ucl ?? 0.0) * 1.2),
  //       buildLegendItem('UCL', Colors.orange, false, controlChartStats?.controlLimitIChart?.ucl ?? 0.0),
  //       buildLegendItem('AVG', Colors.green, false, controlChartStats?.average ?? 0.0),
  //       buildLegendItem('LCL', Colors.orange, false, controlChartStats?.controlLimitIChart?.lcl ?? 0.0),
  //       buildLegendItem('LSL', Colors.red, false, (controlChartStats?.controlLimitIChart?.lcl ?? 0.0) * 0.8),
  //     ],
  //   );
  // }

  // Widget buildLegendItem(String label, Color color, bool isDashed, double? value) {
  //   return Row(
  //     mainAxisSize: MainAxisSize.min,
  //     children: [
  //       SizedBox(
  //         width: 8,
  //         height: 2,
  //         child: DecoratedBox(
  //           decoration: BoxDecoration(
  //             color: color,
  //             border: isDashed ? Border.all(color: color, width: 1) : null,
  //           ),
  //           child: isDashed
  //               ? CustomPaint(
  //                   painter: DashedLinePainter(color: color),
  //                 )
  //               : null,
  //         ),
  //       ),
  //       const SizedBox(width: 8),
  //       Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Text(
  //             label,
  //             style: const TextStyle(
  //               fontSize: 10,
  //               color: AppColors.colorBlack,
  //             ),
  //           ),
  //           Text(
  //             value?.toStringAsFixed(3) ?? 'N/A',
  //             style: const TextStyle(
  //               fontSize: 10,
  //               color: AppColors.colorBlack,
  //               fontWeight: FontWeight.w500,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  double getMinY() {
    // final dataMin = dataPoints!.map((e) => e.value).reduce((a, b) => a < b ? a : b);
    // final lclLimit = (controlChartStats?.controlLimitIChart?.lcl ?? 0.0) * 0.9;
    
    return (controlChartStats?.controlLimitIChart?.lcl ?? 0.0) * 0.95;
  }

  double getMaxY() {
  // minY: (controlChartStats?.controlLimitIChart?.lcl ?? 0.0) * 0.75,
  // maxY: (controlChartStats?.controlLimitIChart?.ucl ?? 0.0) * 1.1;
    
    return (controlChartStats?.controlLimitIChart?.ucl ?? 0.0) * 1.05;
  }
  
  double _calculateXInterval() {
    int pointCount = dataPoints!.length;
    
    if (pointCount <= 10) return 1.0;
    return (pointCount / 10).ceilToDouble();
  }

  double _calculateYAxisInterval() {
    final ucl = controlChartStats?.controlLimitIChart?.ucl ?? 0.0;
    final lcl = controlChartStats?.controlLimitIChart?.lcl ?? 0.0;
    
    final maxValue = ucl * 1.1;
    final minValue = lcl * 0.9;
    final totalRange = maxValue - minValue;
    
    return totalRange; // แบ่งเป็น 8 ช่วง
  }
}
