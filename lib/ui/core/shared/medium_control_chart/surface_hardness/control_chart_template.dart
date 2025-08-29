import 'package:control_chart/domain/models/chart_data_point.dart';
import 'package:control_chart/domain/types/chart_component.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../data/bloc/search_chart_details/search_bloc.dart';
import '../../../../../domain/models/control_chart_stats.dart';
import '../../../design_system/app_color.dart';
import 'control_chart_component.dart';
import 'mr_chart_component.dart';

class ControlChartTemplate extends StatelessWidget {
  final List<ChartDataPoint>? dataPoints;
  final ControlChartStats? controlChartStats;
  final String xAxisLabel;
  final String yAxisLabel;
  final Color? dataLineColor;
  final Color? backgroundColor;
  final double? height; // ไม่จำเป็นเมื่อใช้ LayoutBuilder แต่คงไว้เผื่อ override
  final double? width;
  final bool isMovingRange;

  const ControlChartTemplate({
    super.key,
    this.dataPoints,
    this.controlChartStats,
    this.xAxisLabel = 'Date',
    this.yAxisLabel = 'Attr.',
    this.dataLineColor = AppColors.colorBrand,
    this.backgroundColor = Colors.white,
    this.height,
    this.width,
    required this.isMovingRange,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, searchState) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final w = width ?? constraints.maxWidth;
            final h = height ?? constraints.maxHeight;
            return SizedBox(
              width: w,
              height: h,
              child: _buildChart(w, h),
            );
          },
        );
      },
    );
  }

  Widget _buildChart(double w, double h) {
    if (dataPoints == null || dataPoints!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.data_usage_outlined, size: 64),
            SizedBox(height: 8),
            Text('ไม่มีข้อมูลสำหรับแสดงผล'),
          ],
        ),
      );
    }

    // สร้าง component ที่จะใช้จริง (Individual หรือ MR)
    final useIndividual = ControlChartComponent(
      dataPoints: dataPoints,
      controlChartStats: controlChartStats,
    );

    final useMr = MrChartComponent(
      dataPoints: dataPoints,
      controlChartStats: controlChartStats,
    );

    final ChartComponent selectedWidget = isMovingRange ? useMr : useIndividual;

    const legendTopPad = 0.0;
    const legendLeftPad = 8.0;
    const legendRightPad = 24.0;
    const innerPadBottom = 0.0;
    const legendHeight = 32.0;
    const gapLegendToChart = 16.0;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          legendLeftPad, legendTopPad, legendRightPad, innerPadBottom),
        child: Stack(
          children: [
            Positioned(
              top: 8,
              left: 16,
              right: 0,
              height: legendHeight,
              child: Align(
                alignment: Alignment.center,
                child: selectedWidget.buildLegend(),
              ),
            ),

            Positioned.fill(
              top: legendHeight + gapLegendToChart,
              child: LineChart(
                LineChartData(
                gridData: selectedWidget.buildGridData(),
                extraLinesData: selectedWidget.buildControlLines(),
                titlesData: selectedWidget.buildTitlesData(),
                borderData: selectedWidget.buildBorderData(),
                lineBarsData: selectedWidget.buildLineBarsData(),
                minX: 0,
                maxX: dataPoints!.length.toDouble() - 1,
                minY: selectedWidget.getMinY(),
                maxY: selectedWidget.getMaxY(),
                lineTouchData: selectedWidget.buildTouchData(),
                clipData: FlClipData.none(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
