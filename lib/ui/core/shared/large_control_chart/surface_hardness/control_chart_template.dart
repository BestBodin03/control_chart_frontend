import 'package:control_chart/data/bloc/search_chart_details/extension/search_state_extension.dart';
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
  final String xAxisLabel;
  final String yAxisLabel;
  final Color? dataLineColor;
  final Color? backgroundColor;
  final double? height; // can be overridden by parent
  final double? width;
  final bool isMovingRange;

  /// 🔒 Snapshot override (ถ้ามี -> จะไม่อ่านค่าจาก Bloc)
  final ControlChartStats? frozenStats;
  final List<ChartDataPoint>? frozenDataPoints;
  final SearchStatus? frozenStatus; // optional: ใช้กำหนด loading/failure/ok

  const ControlChartTemplate({
    super.key,
    this.xAxisLabel = 'Date',
    this.yAxisLabel = 'Attr.',
    this.dataLineColor = AppColors.colorBrand,
    this.backgroundColor = Colors.white,
    this.height,
    this.width,
    required this.isMovingRange,
    this.frozenStats,
    this.frozenDataPoints,
    this.frozenStatus,
  });

  @override
  Widget build(BuildContext context) {
    // ถ้ามี snapshot ครบ -> เรนเดอร์ทันทีโดยไม่พึ่ง Bloc
    if (frozenStats != null && frozenDataPoints != null) {
      return _buildFromData(
        context: context,
        dataPoints: frozenDataPoints!,
        stats: frozenStats!,
        status: frozenStatus ?? SearchStatus.success, // assume ok ถ้าไม่ส่งมา
      );
    }

    // ปกติ: อ่านจาก Bloc
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (state.controlChartStats == null || state.chartDataPoints.isEmpty) {
          // ให้สอดคล้องกับ logic เดิม
          if (state.status == SearchStatus.loading) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          }
          if (state.status == SearchStatus.failure) {
            return const Center(
              child: Text('จำนวนข้อมูลไม่เพียงพอ ต้องการข้อมูลอย่างน้อย 5 รายการ'),
            );
          }
          return const Center(child: Text('ไม่มีข้อมูลสำหรับแสดงผล'));
        }

        return _buildFromData(
          context: context,
          dataPoints: state.chartDataPoints,
          stats: state.controlChartStats!,
          status: state.status,
        );
      },
    );
  }

  Widget _buildFromData({
    required BuildContext context,
    required List<ChartDataPoint> dataPoints,
    required ControlChartStats stats,
    required SearchStatus status,
  }) {
    final size = LayoutBuilder(
      builder: (context, constraints) {
        final w = width ?? constraints.maxWidth;
        final h = height ?? constraints.maxHeight;

        // Guards (ใช้สถานะที่ป้อนมา)
        if (status == SearchStatus.loading) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }
        if (status == SearchStatus.failure) {
          return const Center(
            child: Text('จำนวนข้อมูลไม่เพียงพอ ต้องการข้อมูลอย่างน้อย 5 รายการ'),
          );
        }
        if (dataPoints.isEmpty) {
          return const Center(child: Text('ไม่มีข้อมูลสำหรับแสดงผล'));
        }

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

    return size;
  }
}
