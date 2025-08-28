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
  final List<ChartDataPointCdeCdt>? dataPoints;
  final ControlChartStats? controlChartStats;
  final String xAxisLabel;
  final String yAxisLabel;
  final Color? dataLineColor;
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
        // แสดงข้อมูล query ที่ใช้ค้นหา
        return Column(
          children: [
            SizedBox(
              height: height ?? 300,
              width: width,
              child: _buildChartContent(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChartContent() {
    // ตรวจสอบว่ามีข้อมูลหรือไม่
    if (dataPoints == null || dataPoints!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.data_usage_outlined,
              size: 64,
              // color: Colors.grey[400],
            ),
            // SizedBox(height: 16),
            Text(
              'ไม่มีข้อมูลสำหรับแสดงผล',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

  final useWidget = ControlChartComponent(
    dataPoints: dataPoints,
    controlChartStats: controlChartStats,
  );

  final useMrWidget = MrChartComponent(
    dataPoints: dataPoints,
    controlChartStats: controlChartStats,
  );

  // เลือก widget ตาม isMovingRange
  final ChartComponent selectedWidget = isMovingRange ? useMrWidget : useWidget;

  // // 1) Which widget?
  // debugPrint('Selected chart widget: ${selectedWidget.runtimeType} '
  //           '(isMovingRange=$isMovingRange)');

  // // 2) What values will be plotted?
  // final List<double> shownValues = isMovingRange
  //   ? dataPoints!.map((p) => p.mrValue).toList()
  //   : dataPoints!.map((p) => p.value).toList();

  // debugPrint('Showing ${shownValues.length} points; first 10: '
  //   '${shownValues.take(10).map((v) => v.toStringAsFixed(3)).toList()}');

  // // 3) Index-by-index (best for tracing)
  // for (var i = 0; i < dataPoints!.length; i++) {
  //   final p = dataPoints![i];
  //   final shown = isMovingRange ? p.mrValue : p.value;
  //   debugPrint('[$i] ${p.fullLabel}  -> ${shown.toStringAsFixed(3)} '
  //             '(furnace=${p.furnaceNo}, mat=${p.matNo})');
  // }

  return DecoratedBox(
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Padding(
      padding: EdgeInsets.fromLTRB(4.0, 24.0, 16.0, 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart area
          Expanded(
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
            
            // Legend at right
            // const SizedBox(width: 16),
            // useWidget.buildLegend(),
          ],
        ),
      ),
    );
  }
}