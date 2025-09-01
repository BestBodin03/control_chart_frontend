

import 'dart:math';

import 'package:control_chart/domain/models/chart_data_point.dart';
import 'package:control_chart/domain/models/control_chart_stats.dart';
import 'package:control_chart/domain/types/chart_component.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';
import 'package:control_chart/ui/core/shared/dashed_line_painter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MrChartComponent extends StatelessWidget implements ChartComponent  {
  final List<ChartDataPointCdeCdt>? dataPoints;
  final ControlChartStats? controlChartStats;
  // final String xAxisLabel;
  // final String yAxisLabel;
  final Color? dataLineColor;
  final Color? backgroundColor;
  final double? height;
  final double? width;
  final bool isMovingRange;

  const MrChartComponent({
    super.key, 
    this.dataPoints,
    this.controlChartStats,
    // this.xAxisLabel = 'Date (mm/dd)',
    // this.yAxisLabel = 'Surface Hardness',
    this.dataLineColor = AppColors.colorBrand,
    this.backgroundColor,
    this.height = 240,
    this.width = 560,
    this.isMovingRange = true
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
                // titlesData: buildTitlesData(),
                borderData: buildBorderData(),
                lineBarsData: buildLineBarsData(),
                extraLinesData: buildControlLines(),
                // lineTouchData: buildTouchData(),
                minX: 0,
                maxX: (dataPoints!.length - 1).toDouble(),
                minY: 0,
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
              value.toStringAsFixed(2),
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
        
        HorizontalLine(
          y: _chooseCdeOrCdt(controlChartStats?.cdeControlLimitMRChart?.ucl ?? 0.0,
          controlChartStats?.cdtControlLimitMRChart?.ucl ?? 0.0),
          color: Colors.amberAccent,
          strokeWidth: 1.5,
        ),
        
        // Average Line
        HorizontalLine(
          y: _chooseCdeOrCdt(controlChartStats?.cdeMrAverage ?? 0.0, 
          controlChartStats?.cdtMrAverage ?? 0.0),
          // y: controlChartStats?.mrAverage ?? 0.0,
          color: AppColors.colorSuccess1,
          strokeWidth: 2,
        ),

        // HorizontalLine(
        //   y: _chooseCdeOrCdt(controlChartStats?.cdeControlLimitMRChart?.lcl ?? 0.0,
        //   controlChartStats?.cdtControlLimitMRChart?.lcl ?? 0.0),
        //   color: Colors.amberAccent,
        //   strokeWidth: 1.5,
        // ),

      ],
    );
  }

  @override
  List<LineChartBarData> buildLineBarsData() {
    final interval = _calculateXInterval().toInt();
    final int nullMrValue = dataPoints!.length - 1;
    
    return [
      LineChartBarData(
      spots: dataPoints!
        .asMap()
        .entries
        .take(nullMrValue)
        .where((entry) => (entry.key - 1) % interval == 0)
        .map((entry) => FlSpot(
          entry.key.toDouble() + 1.0,
          entry.value.mrValue
        ))
        .toList(),
        
        isCurved: false,
        color: dataLineColor,
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) {
            final realIndex = spot.x.toInt();
            final value = dataPoints![realIndex].mrValue;
            Color dotColor = dataLineColor!;
            
            // RULE 1 # OVER CONTROL
            dotColor = (value < _chooseCdeOrCdt(
              controlChartStats?.cdeControlLimitMRChart?.lcl ?? 0.0,
              controlChartStats?.cdtControlLimitMRChart?.lcl ?? 0.0,
            )) ? Colors.orange : AppColors.colorBrand;


            
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

  double _getInterval() {
    final spotMin = getMinSpot();
    final spotMax = getMaxSpot();
    // final range = (spotMax - spotMin).abs();
    final range = getMaxY();
    // final theMaxY = getMaxY();

    // debugPrint('The Range = $range, max - min: ($spotMax - $spotMin)');


    return range <= 0.25 ? 0.05
        : range <= 0.5  ? 0.10
        : range <= 1.0  ? 0.20
        : 0.20;
  }

  @override
  double getMinY() {
    return 0.0;
  }

  @override
  double getMaxY() {
    final ucl = _chooseCdeOrCdt(controlChartStats?.cdeControlLimitMRChart?.ucl ?? 0, 
    controlChartStats?.cdtControlLimitMRChart?.ucl ?? 0);
    final maxY = max(getMaxSpot(), ucl);
    return maxY <= 0.25 ? 0.25 : maxY <= 0.5 ? 0.5 : 1.0;
  }

  double _calculateYAxisInterval() {
    return _getInterval();
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
      .map((point) => point.mrValue)
      .where((value) => value > 0)
      .fold<double>(double.negativeInfinity, max);

  return maxSpot;
  }

  double getMinSpot() {
    return 0.0;
  }

  double _chooseCdeOrCdt(double? cde, double? cdt, {double fallback = 0}) {
    if (cde == null) return cdt ?? fallback;
    if (cdt == null) return cde;
    return cde > cdt ? cde : cdt;
  }
  
  @override
  Widget buildLegend() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      direction: Axis.horizontal,
      alignment: WrapAlignment.spaceEvenly,
      children: [
      // if (formatValue(controlChartStats?.specAttribute?.surfaceHardnessUpperSpec) != 'N/A')
      //   buildLegendItem('Spec', Colors.red, false,
      //       formatValue(controlChartStats?.specAttribute?.surfaceHardnessUpperSpec)),

      if (formatValue(_chooseCdeOrCdt(controlChartStats?.cdeControlLimitMRChart?.ucl, controlChartStats?.cdtControlLimitMRChart?.ucl)) != 'N/A')
        buildLegendItem('UCL', Colors.orange, false,
            formatValue(_chooseCdeOrCdt(controlChartStats?.cdeControlLimitMRChart?.ucl, controlChartStats?.cdtControlLimitMRChart?.ucl))),

      // if (formatValue(controlChartStats?.specAttribute?.surfaceHardnessTarget) != 'N/A')
      //   buildLegendItem('Target', Colors.deepPurple.shade300, false,
      //       formatValue(controlChartStats?.specAttribute?.surfaceHardnessTarget)),

      if (formatValue(_chooseCdeOrCdt(controlChartStats?.cdeControlLimitMRChart?.cl, controlChartStats?.cdtControlLimitMRChart?.cl)) != 'N/A')
        buildLegendItem('AVG', Colors.green, false,
            formatValue(_chooseCdeOrCdt(controlChartStats?.cdeControlLimitMRChart?.cl, controlChartStats?.cdtControlLimitMRChart?.cl))),

      // if (formatValue(controlChartStats?.controlLimitIChart?.lcl) != 'N/A')
      //   buildLegendItem('LCL', Colors.orange, false,
      //       formatValue(controlChartStats?.controlLimitIChart?.lcl)),

      // if (formatValue(controlChartStats?.specAttribute?.surfaceHardnessLowerSpec) != 'N/A')
      //   buildLegendItem('Spec', Colors.red, false,
      //       formatValue(controlChartStats?.specAttribute?.surfaceHardnessLowerSpec)),
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
  String formatValue(double? value) {
    if (value == null || value <= 0) return 'N/A';
    return value.toStringAsFixed(3);
  }
}