

import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/domain/models/chart_data_point.dart';
import 'package:control_chart/domain/models/control_chart_stats.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/shared/medium_control_chart/surface_hardness/control_chart_component.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ControlChartTemplate extends StatelessWidget {
  final List<ChartDataPoint>? dataPoints;
  final ControlChartStats? controlChartStats;
  final String xAxisLabel;
  final String yAxisLabel;
  final Color? dataLineColor;
  final Color? backgroundColor;
  final double? height;
  final double? width;

  const ControlChartTemplate({
    super.key,
    this.dataPoints,
    this.controlChartStats,
    this.xAxisLabel = 'Date',
    this.yAxisLabel = 'Attr.',
    this.dataLineColor = AppColors.colorBrand,
    this.backgroundColor = Colors.white,
    this.height = 300,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, searchState) {
        // แสดงข้อมูล query ที่ใช้ค้นหา
        return Column(
          children: [
            // Header แสดงข้อมูล query
            // SizedBox(
            //   width: 300,
            //   child: DecoratedBox(
            //     decoration: BoxDecoration(
            //       color: AppColors.colorBlack,
            //     ),
            //     child: Padding(
            //       padding: EdgeInsets.all(8.0),
            //       child: Text(
            //         'หมายเลขเตา: ${searchState.currentQuery.furnaceNo ?? '-'} | Material No.: ${searchState.currentQuery.materialNo ?? '-'}',
            //         style: TextStyle(color: Colors.white),
            //       ),
            //     ),
            //   ),
            // ),
            
            // Chart Content
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
            SizedBox(height: 16),
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

    // สร้าง component เมื่อมีข้อมูล
    final useWidget = ControlChartComponent(
      dataPoints: dataPoints,
      controlChartStats: controlChartStats,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(4.0, 24.0, 16.0, 4.0),
        child: Stack(
          children: [
            // Background layout (legend + chart space)
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                
                // Legend at right
                const SizedBox(width: 8),
                useWidget.buildLegend(),
              ],
            ),
            
            // Chart overlay (full width for touch events)
            Positioned.fill(
              right: 72, // เว้นพื้นที่ให้ legend (ปรับตามขนาดจริง)
              child: LineChart(
                LineChartData(
                  lineTouchData: useWidget.buildTouchData(),
                  gridData: useWidget.buildGridData(),
                  extraLinesData: useWidget.buildControlLines(),
                  titlesData: useWidget.buildTitlesData(),
                  borderData: useWidget.buildBorderData(),
                  lineBarsData: useWidget.buildLineBarsData(),
                  minX: 0,
                  maxX: dataPoints!.length.toDouble() - 1,
                  minY: useWidget.getMinY(),
                  maxY: useWidget.getMaxY(),
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