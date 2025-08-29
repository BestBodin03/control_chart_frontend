import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';

abstract class ChartComponent {
  FlGridData buildGridData();
  ExtraLinesData buildControlLines();
  FlTitlesData buildTitlesData();
  FlBorderData buildBorderData();
  List<LineChartBarData> buildLineBarsData();
  double getMinY();
  double getMaxY();
  LineTouchData buildTouchData();
  Widget? buildLegend();
}