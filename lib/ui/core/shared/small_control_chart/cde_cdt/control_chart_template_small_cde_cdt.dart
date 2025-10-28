import 'package:control_chart/data/bloc/search_chart_details/extension/search_state_extension.dart';
import 'package:control_chart/ui/core/shared/small_control_chart/cde_cdt/control_chart_component_small.dart';
import 'package:control_chart/ui/core/shared/small_control_chart/cde_cdt/mr_chart_component_small.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/domain/models/chart_data_point.dart' show ChartDataPointCdeCdt;
import 'package:control_chart/domain/models/control_chart_stats.dart';
import 'package:control_chart/domain/models/setting.dart' show SecondChartSelected;
import 'package:control_chart/domain/types/chart_component.dart';

import 'package:control_chart/ui/core/design_system/app_color.dart';

import 'control_chart_component_small.dart' as ctrl;
import 'mr_chart_component_small.dart' as mr;

class ControlChartTemplateSmallCdeCdt extends StatefulWidget {
  final String xAxisLabel;
  final String yAxisLabel;
  final Color? dataLineColor;
  final Color? backgroundColor;
  final double? height; // can be overridden by parent
  final double? width;
  final bool isMovingRange;

  /// Optional frozen overrides (bypass Bloc)
  final ControlChartStats? frozenStats;
  final List<ChartDataPointCdeCdt>? frozenDataPoints;
  final SearchStatus? frozenStatus;

  /// Parent-controlled windowing
  final int? externalStart;
  final int? externalWindowSize;

  /// ช่วงเวลาเป้าหมายที่ parent ต้องการให้กราฟใช้
  final DateTime? xStart;
  final DateTime? xEnd;
  final int? xTick;

  const ControlChartTemplateSmallCdeCdt({
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
    this.externalStart,
    this.externalWindowSize,
    this.xStart,
    this.xEnd,
    this.xTick,
  });

  @override
  State<ControlChartTemplateSmallCdeCdt> createState() =>
      _ControlChartTemplateSmallCdeCdtState();
}

class _ControlChartTemplateSmallCdeCdtState
    extends State<ControlChartTemplateSmallCdeCdt> {
  List<ChartDataPointCdeCdt> _fromBloc() {
    final state = context.read<SearchBloc>().state;
    return state.chartDataPointsCdeCdt;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.xStart == null || widget.xEnd == null) {
      return const Center(child: Text('ช่วงเวลาไม่ถูกต้อง'));
    }

    if (widget.frozenStats != null && widget.frozenDataPoints != null) {
      if (widget.frozenDataPoints!.isEmpty) {
        return const Center(child: Text('ไม่มีข้อมูลสำหรับแสดงผล'));
      }
      return _buildFromData(
        dataPoints: widget.frozenDataPoints!,
        stats: widget.frozenStats!,
        status: widget.frozenStatus ?? SearchStatus.success,
      );
    }

    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (state.status == SearchStatus.loading) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }
        if (state.status == SearchStatus.failure) {
          return const Center(
            child: Text('จำนวนข้อมูลไม่เพียงพอ ต้องการข้อมูลอย่างน้อย 5 รายการ'),
          );
        }

        final stats = state.controlChartStats;
        if (stats == null ||
            stats.secondChartSelected == SecondChartSelected.na) {
          return const SizedBox.shrink();
        }

        final full = _fromBloc();
        if (full.isEmpty) {
          return const Center(child: Text('ไม่มีข้อมูลสำหรับแสดงผล'));
        }

        return _buildFromData(
          dataPoints: full,
          stats: stats,
          status: state.status,
        );
      },
    );
  }

Widget _buildFromData({
    required List<ChartDataPointCdeCdt> dataPoints,
    required ControlChartStats stats,
    required SearchStatus status,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = widget.width ?? constraints.maxWidth;
        final h = widget.height ?? constraints.maxHeight;

        debugPrint('CDE CDE Template h, w = $h, $w');

        // ใช้ช่วงของ parent (ต้องไม่เป็น null ถึงมาถึงฟังก์ชันนี้ได้)
        final DateTime start = widget.xStart!;
        final DateTime end   = widget.xEnd!;

        final useI = ControlChartComponentSmallCdeCdt(
          dataPoints: dataPoints,
          controlChartStats: stats,
          dataLineColor: widget.dataLineColor,
          backgroundColor: widget.backgroundColor,
          height: h,
          width: w,
          xStart: start, // ✅ ช่วงจริงจาก parent
          xEnd: end,     // ✅ ช่วงจริงจาก parent
          // ถ้ามีพารามิเตอร์ minY/maxY ในคอมโพเนนต์ของคุณ
          minY: stats.yAxisRange?.minYsurfaceHardnessControlChart,
          maxY: stats.yAxisRange?.maxYsurfaceHardnessControlChart,
        );

        final useMr = MrChartComponentSmallCdeCdt(
          dataPoints: dataPoints,
          controlChartStats: stats,
          dataLineColor: widget.dataLineColor,
          backgroundColor: widget.backgroundColor,
          height: h,
          width: w,
          xStart: start,
          xEnd: end,
        );

        final ChartComponent selectedWidget = widget.isMovingRange ? useMr : useI;

        const legendRightPad = 16.0;
        const legendHeight = 28.0;
        const gapLegendToChart = 4.0;

        return SizedBox(
          width: w,
          height: h,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, legendRightPad, 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Legend
                  SizedBox(
                    height: legendHeight,
                    child: Align(
                      alignment: Alignment.center,
                      child: selectedWidget.buildLegend(context),
                    ),
                  ),
                  const SizedBox(height: gapLegendToChart),

                  // ✅ ใช้ component ที่มี LineChart ภายในอยู่แล้ว
                  Expanded(child: selectedWidget as Widget),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}      
