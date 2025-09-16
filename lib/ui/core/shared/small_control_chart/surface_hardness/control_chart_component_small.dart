// import 'dart:math' as math;

// import 'package:control_chart/domain/models/chart_data_point.dart';
// import 'package:control_chart/domain/models/control_chart_stats.dart';
// import 'package:control_chart/domain/types/chart_component.dart';
// import 'package:control_chart/ui/core/design_system/app_color.dart';
// import 'package:control_chart/ui/core/design_system/app_typography.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';

  
// class ControlChartComponentSmall extends StatelessWidget implements ChartComponent {
//   final List<ChartDataPoint>? dataPoints;
//   final ControlChartStats? controlChartStats;
//   // final String xAxisLabel;
//   // final String yAxisLabel;
//   final Color? dataLineColor;
//   final Color? backgroundColor;
//   final double? height;
//   final double? width;

//   ControlChartComponentSmall({
//     super.key,
//     this.dataPoints,
//     this.controlChartStats,
//     // this.xAxisLabel = 'Date (mm/dd)',
//     // this.yAxisLabel = 'Surface Hardness',
//     this.dataLineColor = AppColors.colorBrand,
//     this.backgroundColor,
//     this.height = 240,
//     this.width = 560,
//   });
  
//   @override
//   Widget build(BuildContext context) {
//     if (dataPoints == null || dataPoints!.isEmpty) {
//       return const Center(child: Text('No data available'));
//     }

//     return Container(
//       height: height,
//       width: width,
//       // padding: const EdgeInsets.all(4),
//       decoration: BoxDecoration(
//         color: backgroundColor ?? Colors.white,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Column(
//         children: [
//           Expanded(
//             child: LineChart(
//               LineChartData(
//                 gridData: buildGridData(),
//                 // titlesData: buildTitlesData(),
//                 borderData: buildBorderData(),
//                 lineBarsData: buildLineBarsData(),
//                 extraLinesData: buildControlLines(),
//                 // lineTouchData: buildTouchData(),
//                 minX: 0,
//                 maxX: (dataPoints!.length - 1).toDouble(),
//                 minY: getMinY(),
//                 maxY: getMaxY(),
//               ),
//             ),
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               // Y-axis label (rotated)
//               RotatedBox(
//                 quarterTurns: 3,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
  
//   @override
//   FlGridData buildGridData() {
//     return FlGridData(
//       show: true,
//       drawHorizontalLine: true,
//       drawVerticalLine: true,
//       horizontalInterval: _calculateYAxisInterval(),
//       // horizontalInterval: 24,
//       verticalInterval: 24,
//       getDrawingHorizontalLine: (value) {
//         return FlLine(
//           color: Colors.grey.shade100,
//           strokeWidth: 0.5,
//         );
//       },
//       getDrawingVerticalLine: (value) {
//         return FlLine(
//           color: Colors.grey.shade100,
//           strokeWidth: 0.5,
//         );
//       },
//     );
//   }

//   @override
//   FlTitlesData buildTitlesData() {
//     return FlTitlesData(
//         leftTitles: AxisTitles(
//         // axisNameSize: 16, // กำหนดขนาด axis name
//         axisNameWidget: SizedBox(
//           width: height,
//         ),
//         sideTitles: SideTitles(
//           showTitles: true,
//           reservedSize: 24,
//           interval: _calculateYAxisInterval(),
//           getTitlesWidget: (value, meta) {
//             return Text(
//               value.toStringAsFixed(0),
//               style: const TextStyle(
//                 color: Colors.black54,
//                 fontSize: 8,
//               ),
//             );
//           },
//         ),
//         ),
//       bottomTitles: AxisTitles(
//         // axisNameSize: 36, // กำหนดขนาด axis name
//         axisNameWidget: SizedBox(
//           width: width,
//         ),
//         sideTitles: SideTitles(
//           showTitles: true,
//           reservedSize: 16, // เพิ่มขนาดสำหรับ X-axis labels
//           interval: _calculateXInterval(),
//           getTitlesWidget: (value, meta) {
//             final index = value.toInt();
//             if (index >= 0 && index < dataPoints!.length) {
//               return 
//                 Text(
//                   dataPoints![index].label,
//                   style: const TextStyle(
//                     color: Colors.black54,
//                     fontSize: 8, // เพิ่มขนาดฟอนต์
//                   ),
//                 );
//             }
//             return const SizedBox.shrink();
//           },
//         ),
//       ),
//       topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//       rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//     );
//   }

//   @override
//   FlBorderData buildBorderData() {
//     return FlBorderData(
//       show: true,
//       border: Border.all(
//         color: Colors.black54,
//         width: 1,
//       ),
//     );
//   }

//   @override
//   ExtraLinesData buildControlLines() {
//     return ExtraLinesData(
//       extraLinesOnTop: false,
//       horizontalLines: [
//         // USL (Upper Specification Limit)
//         if ((controlChartStats?.specAttribute?.surfaceHardnessUpperSpec ?? 0.0) > 0.0)
//           HorizontalLine(
//             y: controlChartStats!.specAttribute!.surfaceHardnessUpperSpec!,
//             color: Colors.red.shade400,
//             strokeWidth: 2,
//           ),
        
//         HorizontalLine(
//           y: controlChartStats?.controlLimitIChart?.ucl ?? 0.0,
//           color: Colors.amberAccent,
//           strokeWidth: 1.5,
//         ),
        
//         // Average Line
//         HorizontalLine(
//           y: controlChartStats?.average ?? 0.0,
//           color: AppColors.colorSuccess1,
//           strokeWidth: 2,
//         ),

//         HorizontalLine(
//           y: controlChartStats?.controlLimitIChart?.lcl ?? 0.0,
//           color: Colors.amberAccent,
//           strokeWidth: 1.5,
//         ),
        
//         // LSL (Lower Specification Limit)
//       if ((controlChartStats?.specAttribute?.surfaceHardnessLowerSpec ?? 0.0) > 0.0)
//         HorizontalLine(
//           y: controlChartStats!.specAttribute!.surfaceHardnessLowerSpec!,
//           color: Colors.red.shade400,
//           strokeWidth: 2,
//         ),
//       ],
//     );
//   }

//   @override
//   List<LineChartBarData> buildLineBarsData() {
//     // final interval = _calculateXInterval().toInt();
    
//     return [
//       LineChartBarData(
//         spots: dataPoints!
//             .asMap()
//             .entries
//             .where((entry) => entry.key % 1 == 0)
//             .map((entry) => FlSpot(entry.key.toDouble(), entry.value.value))
//             .toList(),
        
//         isCurved: false,
//         color: dataLineColor,
//         barWidth: 3,
//         isStrokeCapRound: true,
//         dotData: FlDotData(
//           show: false,
//           getDotPainter: (spot, percent, barData, index) {
//             final realIndex = spot.x.toInt();
//             final value = dataPoints![realIndex].value;
//             Color dotColor = dataLineColor!;
            
//             // OVER LIMIT #RULE 1
//             if ((controlChartStats?.specAttribute?.surfaceHardnessUpperSpec ?? 0.0) > 0.0 &&
//               (value > (controlChartStats?.specAttribute?.surfaceHardnessUpperSpec ?? 0.0) || 
//                 value < (controlChartStats?.specAttribute?.surfaceHardnessLowerSpec ?? 0.0))) {
//             dotColor = Colors.red; // Out of spec
//             } else if (value > (controlChartStats?.controlLimitIChart?.ucl ?? 0.0) || 
//                       value < (controlChartStats?.controlLimitIChart?.lcl ?? 0.0)) {
//             dotColor = Colors.orange; // Warning zone
//             }
            
//             return FlDotCirclePainter(
//               radius: 4,
//               color: dotColor,
//               strokeWidth: 2,
//               strokeColor: Colors.white,
//             );
//           },
//         ),
//         belowBarData: BarAreaData(show: false),
//       ),
//     ];
//   }

//   @override
//   LineTouchData buildTouchData() {
//     return LineTouchData(
//       handleBuiltInTouches: true,
//       touchTooltipData: LineTouchTooltipData(
//         maxContentWidth: 150,
//         getTooltipColor: (_) => AppColors.colorBrand.withValues(alpha: 0.9),
//         tooltipBorderRadius: BorderRadius.circular(8),
//         // กัน tooltip หลุดกรอบ/ถูกตัด
//         fitInsideHorizontally: true,
//         fitInsideVertically: true,
//         tooltipMargin: 8,
//         getTooltipItems: (spots) {
//           return spots.map((barSpot) {
//             final index = barSpot.x.toInt();
//             if (index >= 0 && index < dataPoints!.length) {
//               return LineTooltipItem(
//                 "วันที่: ${dataPoints![index].fullLabel}\n"
//                 "ค่า: ${dataPoints![index].value.toStringAsFixed(3)}\n"
//                 "เตา: ${dataPoints![index].furnaceNo}\n"
//                 "เลขแมต: ${dataPoints![index].matNo}",
//                 AppTypography.textBody3W,
//                 textAlign: TextAlign.left,
//               );
//             }
//             return null;
//           }).whereType<LineTooltipItem>().toList();
//         },
//       ),
//     );
//   }
  
// // ---------- Cache ----------
// double? _cachedMinY;
// double? _cachedMaxY;
// double? _cachedInterval;

// // ---------- Public ----------
// @override
// double getMaxY() {
//   if (_cachedInterval == null) _getInterval();
//   return _cachedMaxY ?? 0.0;
// }

// @override
// double getMinY() {
//   if (_cachedInterval == null) _getInterval();
//   return _cachedMinY ?? 0.0;
// }


// double _getInterval() {
//   const divisions = 5; // => 6 ticks
//   final spotMin = controlChartStats?.yAxisRange?.minYsurfaceHardnessControlChart ?? 0.0;
//   final spotMax = controlChartStats?.yAxisRange?.maxYsurfaceHardnessControlChart ?? spotMin;

//   if (spotMax <= spotMin) {
//     _cachedMinY = spotMin;
//     _cachedMaxY = spotMin + divisions;
//     _cachedInterval = 1.0;
//     return _cachedInterval!;
//   }

//   // target step for desired divisions
//   final ideal = (spotMax - spotMin) / divisions;
//   double interval = _niceStepCeil(ideal);

//   // snap min to multiple of step; max exactly divisions*step above
//   double minY = (spotMin / interval).floor() * interval;
//   double maxY = minY + divisions * interval;

//   // if not yet covering data max, bump to next nice step(s)
//   while (maxY < spotMax - 1e-12) {
//     interval = _nextNiceStep(interval);
//     minY = (spotMin / interval).floor() * interval;
//     maxY = minY + divisions * interval;
//   }

//   _cachedMinY = minY;
//   _cachedMaxY = maxY;
//   _cachedInterval = interval;
//   return interval;
// }

// // ---------- Utilities ----------
//   double _roundUpToPowerOf10(double x) {
//     if (x <= 0 || x.isNaN || x.isInfinite) return x;
//     final exp = (math.log(x) / math.log(10)).floor();
//     final base = math.pow(10.0, exp).toDouble();
//     return (x <= base) ? base : math.pow(10.0, exp + 1).toDouble();
//   }

//   double _niceStepCeil(double x) {
//     if (x <= 0 || x.isNaN || x.isInfinite) return 1.0;
//     final exp = (math.log(x) / math.log(10)).floor();
//     final mag = math.pow(10.0, exp).toDouble();
//     final mant = x / mag;
//     if (mant <= 0.025) return 0.025 * mag;
//     if (mant <= 0.050) return 0.050 * mag;
//     if (mant <= 0.075) return 0.075 * mag;
//     if (mant <= 0.125) return 0.125 * mag;
//     if (mant <= 0.25) return 0.25 * mag;
//     if (mant <= 0.5) return 0.5 * mag;
//     if (mant <= 1.0) return 1.0 * mag;
//     if (mant <= 2.0) return 2.0 * mag;
//     if (mant <= 2.5) return 2.5 * mag;
//     if (mant <= 5.0) return 5.0 * mag;
//     return 10.0 * mag;
//   }

//   double _nextNiceStep(double step) {
//     final exp = (math.log(step) / math.log(10)).floor();
//     final mag = math.pow(10.0, exp).toDouble();
//     final mant = step / mag;
//     if (mant <= 0.025) return 0.025 * mag;
//     if (mant <= 0.050) return 0.050 * mag;
//     if (mant <= 0.075) return 0.075 * mag;
//     if (mant <= 0.125) return 0.125 * mag;
//     if (mant <= 0.25) return 0.25 * mag;
//     if (mant <= 0.5) return 0.5 * mag;
//     if (mant < 1.0) return 1.0 * mag;
//     if (mant < 2.0) return 2.0 * mag;
//     if (mant < 2.5) return 2.5 * mag;
//     if (mant < 5.0) return 5.0 * mag;
//     return 10.0 * mag;
//   }

//   double _calculateYAxisInterval() {
//     return _getInterval(); // ใช้ interval ที่คำนวณแล้ว
//   }
    
//   double _calculateXInterval() {
//     int pointCount = dataPoints!.length;
    
//     if (pointCount <= 24) return 1.0;
//     return (pointCount / 24).ceilToDouble();
//   }

  
//   @override
//   Widget? buildLegend() {
//     // TODO: implement buildLegend
//     throw UnimplementedError();
//   }
// }
