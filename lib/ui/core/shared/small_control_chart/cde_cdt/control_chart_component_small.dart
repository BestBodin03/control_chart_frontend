import 'dart:math';

import 'package:control_chart/domain/models/chart_data_point.dart';
import 'package:control_chart/domain/models/control_chart_stats.dart';
import 'package:control_chart/domain/types/chart_component.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
  
class ControlChartComponentSmall extends StatelessWidget implements ChartComponent {
  final List<ChartDataPointCdeCdt>? dataPoints;
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
      horizontalInterval: _calculateXInterval(),
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
        // axisNameSize: 36, // กำหนดขนาด axis name
        axisNameWidget: SizedBox(
          width: width,
        ),
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 16, // เพิ่มขนาดสำหรับ X-axis labels
          interval: _calculateXInterval(),
          getTitlesWidget: (value, meta) {
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
        if ((_chooseCdeOrCdt(controlChartStats?.specAttribute?.cdeUpperSpec, controlChartStats?.specAttribute?.cdtUpperSpec)) > 0.0)
          HorizontalLine(
            y: controlChartStats!.specAttribute!.surfaceHardnessUpperSpec!,
            color: Colors.red.shade400,
            strokeWidth: 2,
          ),
        
        HorizontalLine(
          y: _chooseCdeOrCdt(controlChartStats?.cdeControlLimitIChart?.ucl, controlChartStats?.cdtControlLimitIChart?.ucl),
          color: Colors.amberAccent,
          strokeWidth: 1.5,
        ),
        
        // Average Line
        HorizontalLine(
          y: _chooseCdeOrCdt(controlChartStats?.cdeAverage, controlChartStats?.cdtAverage),
          color: AppColors.colorSuccess1,
          strokeWidth: 2,
        ),

        HorizontalLine(
          y: _chooseCdeOrCdt(controlChartStats?.cdeControlLimitIChart?.lcl, controlChartStats?.cdtControlLimitIChart?.lcl),
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
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) {
            final realIndex = spot.x.toInt();
            final value = dataPoints![realIndex].value;
            Color dotColor = dataLineColor!;

            // RULE 1 # OVER CONTROL
            dotColor = (
              (_chooseCdeOrCdt(controlChartStats?.specAttribute?.cdeUpperSpec,
                              controlChartStats?.specAttribute?.cdtUpperSpec))
                               > 0.0 &&
              (value > _chooseCdeOrCdt(controlChartStats?.specAttribute?.cdeUpperSpec,
                                      controlChartStats?.specAttribute?.cdtUpperSpec) ||
              value < _chooseCdeOrCdt(controlChartStats?.specAttribute?.cdeLowerSpec,
                                      controlChartStats?.specAttribute?.cdtLowerSpec)))
              ? Colors.red // Out of spec
              : (value >= _chooseCdeOrCdt(controlChartStats?.cdeControlLimitIChart!.ucl,
                                          controlChartStats?.cdtControlLimitIChart?.ucl) ||
                value <= _chooseCdeOrCdt(controlChartStats?.cdeControlLimitIChart!.lcl,
                                          controlChartStats?.cdtControlLimitIChart?.lcl))
                ? Colors.orange // Warning zone
                : dotColor; // unchanged (safe zone)

            
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
  double _getInterval() {
    final spotMin = getMinSpot();
    final spotMax = getMaxY();
    final range = (spotMax - spotMin).abs();

    // debugPrint('The Range = $range, max - min: ($spotMax - $spotMin)');

    return range < 0.25 ? 0.05
        : range < 0.5  ? 0.10
        : range < 1.0  ? 0.20
        : 0.20;
  }


  @override
  double getMinY() {
    return 0.0;
  }

  @override
  double getMaxY() {
    final ucl = _chooseCdeOrCdt(controlChartStats?.cdeControlLimitIChart?.ucl ?? 0.0, 
    controlChartStats?.cdtControlLimitIChart?.ucl ?? 0.0);
    final usl = _chooseCdeOrCdt(controlChartStats?.specAttribute?.cdeUpperSpec ?? 0.0, 
    controlChartStats?.specAttribute?.cdtUpperSpec ?? 0.0);
    final maxY = max(getMaxSpot(), max(ucl, usl));
    return maxY <= 0.25 ? 0.25 : maxY <= 0.5 ? 0.5 : 1.0;
  }


  double _calculateYAxisInterval() {
    return _getInterval();
  }
    
  double _calculateXInterval() {
    int pointCount = dataPoints!.length;
    
    if (pointCount <= 10) return 1.0;
    return (pointCount / 10).ceilToDouble();
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
  Widget? buildLegend() {
    // TODO: implement buildLegend
    throw UnimplementedError();
  }
}
