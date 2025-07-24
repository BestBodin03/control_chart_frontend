
import 'package:control_chart/domain/models/chart_data_point.dart';
import 'package:control_chart/ui/core/shared/control_chart_component.dart';
import 'package:control_chart/ui/core/shared/dashed_line_painter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ControlChartTemplate extends StatelessWidget {
  final List<ChartDataPoint> dataPoints;
  final ControlLimits controlLimits;
  final String xAxisLabel;
  final String yAxisLabel;
  final Color? dataLineColor;
  final Color? backgroundColor;
  final double? height;
  final double? width;

  const ControlChartTemplate({
    super.key,
    required this.dataPoints,
    required this.controlLimits,
    this.xAxisLabel = 'Date',
    this.yAxisLabel = 'Attr.',
    this.dataLineColor = Colors.blue,
    this.backgroundColor = Colors.white,
    this.height = 300,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final useWidget = ControlChartComponent(
      dataPoints: dataPoints, // Pass your data points
      controlLimits: controlLimits, // Pass your control limits
    );
    return Container(
      height: height,
      width: width,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart Area
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: useWidget.buildGridData(),
                titlesData: useWidget.buildTitlesData(),
                borderData: useWidget.buildBorderData(),
                lineBarsData: useWidget.buildLineBarsData(),
                minX: 0,
                maxX: dataPoints.length.toDouble() - 1,
                minY: useWidget.getMinY(),
                maxY: useWidget.getMaxY(),
                extraLinesData: useWidget.buildControlLines(),
                lineTouchData: useWidget.buildTouchData(),
              ),
            ),
          ),
          
          // Legend
          const SizedBox(height: 12),
          useWidget.buildLegend(),
        ],
      ),
    );
  }
}