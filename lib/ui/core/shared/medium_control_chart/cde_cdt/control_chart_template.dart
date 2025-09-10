import 'package:control_chart/data/bloc/search_chart_details/extension/search_state_extension.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/domain/models/chart_data_point.dart';
import 'package:control_chart/domain/models/control_chart_stats.dart';
import 'package:control_chart/domain/types/chart_component.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/shared/medium_control_chart/cde_cdt/control_chart_component.dart';
import 'package:control_chart/ui/core/shared/medium_control_chart/cde_cdt/mr_chart_component.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ControlChartTemplateCdeCdt extends StatelessWidget {
  final String xAxisLabel;
  final String yAxisLabel;
  final Color? dataLineColor;
  final List<ChartDataPointCdeCdt>? dataPoints;
  final ControlChartStats? controlChartStats;
  final Color? backgroundColor;
  final double? height;
  final double? width;
  final bool isMovingRange;

  const ControlChartTemplateCdeCdt({
    super.key,
    this.dataPoints,
    this.controlChartStats,
    this.xAxisLabel = 'Date',
    this.yAxisLabel = 'Attr.',
    this.dataLineColor = AppColors.colorBrand,
    this.backgroundColor = Colors.white,
    this.height = 300,
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

            // --- Loading / Error / Empty guards ---
            if (searchState.status == SearchStatus.loading) {
              return const Center(child: CircularProgressIndicator(strokeWidth: 2));
            }
            if (searchState.status == SearchStatus.failure) {
              return const Center(child: Text('จำนวนข้อมูลไม่เพียงพอ ต้องการข้อมูลอย่างน้อย 5 รายการ'));
            }
            if (searchState.controlChartStats == null ||
                searchState.chartDataPointsCdeCdt.isEmpty) {
              return const Center(child: Text('ไม่มีข้อมูลสำหรับแสดงผล'));
            }

            // --- ใช้ข้อมูลจาก searchState ---
            final dataPoints = searchState.chartDataPointsCdeCdt;
            final stats = searchState.controlChartStats!;

            // component I / MR
            final useIndividual = ControlChartComponent(
              dataPoints: dataPoints,
              controlChartStats: stats,
            );

            final useMr = MrChartComponent(
              dataPoints: dataPoints,
              controlChartStats: stats,
            );

            final ChartComponent selectedWidget = isMovingRange ? useMr : useIndividual;

            const legendTopPad = 0.0;
            const legendLeftPad = 8.0;
            const legendRightPad = 24.0;
            const innerPadBottom = 0.0;
            const legendHeight = 32.0;
            const gapLegendToChart = 16.0;

            return SizedBox(
              width: w,
              height: h,
              child: DecoratedBox(
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
                            maxX: dataPoints.length.toDouble() - 1,
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
              ),
            );
          },
        );
      },
    );
  }
}
