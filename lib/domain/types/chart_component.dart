import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';

abstract class ChartComponent {
  FlGridData buildGridData(double? minX, double? maxX, double? tickInterval);
  ExtraLinesData buildControlLines();
  FlTitlesData buildTitlesData(double? minX, double? maxX, double? tickInterval);
  FlBorderData buildBorderData();
  List<LineChartBarData> buildLineBarsData();
  double getMinY();
  double getMaxY();
  LineTouchData buildTouchData();
  Widget? buildLegend(BuildContext context);
}