import 'package:control_chart/data/bloc/search_chart_details/extension/search_state_extension.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/domain/models/chart_data_point.dart';
import 'package:control_chart/domain/models/control_chart_stats.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/shared/medium_control_chart/cde_cdt/control_chart_component.dart';
import 'package:control_chart/ui/core/shared/medium_control_chart/cde_cdt/mr_chart_component.dart';
import 'package:control_chart/utils/select_second_chart_attribute.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../domain/types/chart_component.dart';

class ControlChartTemplateCdeCdt extends StatelessWidget {
  final String xAxisLabel;
  final String yAxisLabel;
  final Color? dataLineColor;
  final Color? backgroundColor;
  final double? height;
  final double? width;
  final bool isMovingRange;

  const ControlChartTemplateCdeCdt({
    super.key,
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
      builder: (context, state) {
        // --- Guards ---
        if (state.status == SearchStatus.loading) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }
        if (state.status == SearchStatus.failure) {
          return const Center(child: Text('จำนวนข้อมูลไม่เพียงพอ ต้องการข้อมูลอย่างน้อย 5 รายการ'));
        }
        final stats = state.controlChartStats;
        if (stats == null) {
          return const Center(child: Text('ไม่มีข้อมูลสำหรับแสดงผล'));
        }
        final sel = stats.secondChartSelected;
        if (sel == null || sel == SecondChartSelected.na) {
          // เลือก NA = ไม่ต้องแสดง
          return const SizedBox.shrink();
        }

        // --- เลือกชุดข้อมูลตาม secondChartSelected ---
        final bundle = pickBundle(stats);
        if (bundle == null) {
          return const Center(child: Text('ไม่มีข้อมูลสำหรับแสดงผล'));
        }

        // map values -> ChartDataPoint (ทำ label ง่าย ๆ เป็นลำดับ 1..n)
        final iPoints = List<ChartDataPointCdeCdt>.generate(bundle.values.length, (i) {
          final v = bundle.values[i];
          // final mrv = bundle.mrValue[i];
          return ChartDataPointCdeCdt(
            value: v,
            label: '${i + 1}',
            fullLabel: '${i + 1}',
          );
        });

        final mrPoints = List<ChartDataPointCdeCdt>.generate(bundle.mrValues.length, (i) {
          final mrv = bundle.mrValues[i];
          // final v = bundle.value[i];
          return ChartDataPointCdeCdt(
            // value: v,
            label: '${i + 1}',
            fullLabel: '${i + 1}', mrValue: mrv,
          );
        });

        if (!isMovingRange && iPoints.isEmpty) {
          return const Center(child: Text('ไม่มีข้อมูลสำหรับแสดงผล'));
        }
        if (isMovingRange && mrPoints.isEmpty) {
          return const Center(child: Text('ไม่มีข้อมูลสำหรับแสดงผล'));
        }

        // --- เลือกคอมโพเนนต์ตามโหมด ---
        final ChartComponent selectedWidget = isMovingRange
            ? MrChartComponent(
                dataPoints: mrPoints,
                controlChartStats: stats,
                dataLineColor: dataLineColor,
                backgroundColor: backgroundColor,
                height: height,
                width: width,
              )
            : ControlChartComponent(
                dataPoints: iPoints,
                controlChartStats: stats,
                dataLineColor: dataLineColor,
                backgroundColor: backgroundColor,
                height: height,
                width: width,
              );

        final dataLen = isMovingRange ? mrPoints.length : iPoints.length;

        // --- Layout (legend + chart) ---
        return LayoutBuilder(
          builder: (context, constraints) {
            final w = width ?? constraints.maxWidth;
            final h = height ?? constraints.maxHeight;

            const legendHeight = 32.0;
            const gapLegendToChart = 4.0;

            return SizedBox(
              width: w,
              height: h,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: backgroundColor ?? Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 24, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: legendHeight,
                        child: Align(
                          alignment: Alignment.center,
                          child: selectedWidget.buildLegend(),
                        ),
                      ),
                      const SizedBox(height: gapLegendToChart),

                      Expanded(
                        child: LineChart(
                          LineChartData(
                            gridData: selectedWidget.buildGridData(),
                            extraLinesData: selectedWidget.buildControlLines(),
                            titlesData: selectedWidget.buildTitlesData(),
                            borderData: selectedWidget.buildBorderData(),
                            lineBarsData: selectedWidget.buildLineBarsData(),
                            minX: 0,
                            maxX: (dataLen - 1).toDouble(),
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
