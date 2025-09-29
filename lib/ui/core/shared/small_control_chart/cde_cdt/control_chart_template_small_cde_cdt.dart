import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/data/bloc/search_chart_details/extension/search_state_extension.dart';
import 'package:control_chart/domain/models/chart_data_point.dart';
import 'package:control_chart/domain/models/control_chart_stats.dart';
import 'package:control_chart/domain/types/chart_component.dart';

import 'control_chart_component_small.dart' as ctrl;
import 'mr_chart_component_small.dart' as mr;

class ControlChartTemplateSmallCdeCdt extends StatefulWidget {
  final String xAxisLabel;
  final String yAxisLabel;
  final Color? dataLineColor;
  final Color? backgroundColor;
  final double? height; // sized by parent constraints
  final double? width;
  final bool isMovingRange;

  /// Frozen (bypass Bloc)
  final ControlChartStats? frozenStats;
  final List<ChartDataPointCdeCdt>? frozenDataPoints;
  final SearchStatus? frozenStatus;

  /// Optional time range (if your components support it)
  final DateTime? xStart;
  final DateTime? xEnd;

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
    this.xStart,
    this.xEnd,
  });

  @override
  State<ControlChartTemplateSmallCdeCdt> createState() =>
      _ControlChartTemplateSmallCdeCdtState();
}

class _ControlChartTemplateSmallCdeCdtState
    extends State<ControlChartTemplateSmallCdeCdt> {
  List<ChartDataPointCdeCdt> _fullDataPoints() {
    if (widget.frozenDataPoints != null) return widget.frozenDataPoints!;
    final state = context.read<SearchBloc>().state;
    return state.chartDataPointsCdeCdt;
  }

  @override
  Widget build(BuildContext context) {
    // ---------- Frozen path ----------
    if (widget.frozenStats != null && widget.frozenDataPoints != null) {
      return _buildFromData(
        dataPoints: widget.frozenDataPoints!,
        stats: widget.frozenStats!,
        status: widget.frozenStatus ?? SearchStatus.success,
      );
    }

    // ---------- Bloc path ----------
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        final stats = state.controlChartStats;
        if (state.status == SearchStatus.loading) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }
        if (state.status == SearchStatus.failure) {
          return const Center(
            child: Text('จำนวนข้อมูลไม่เพียงพอ ต้องการข้อมูลอย่างน้อย 5 รายการ'),
          );
        }
        if (stats == null || stats.secondChartSelected == SecondChartSelected.na) {
          return const SizedBox.shrink();
        }

        final full = _fullDataPoints();
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

        // ถ้าคอมโพเนนต์รองรับช่วงเวลา ให้คำนวณแล้วส่งต่อได้ (ตอนนี้ไม่บังคับ)
        DateTime? start = widget.xStart, end = widget.xEnd;
        if ((start == null || end == null) && dataPoints.isNotEmpty) {
          dataPoints.sort((a, b) => a.collectDate.compareTo(b.collectDate));
          start ??= dataPoints.first.collectDate;
          end ??= dataPoints.last.collectDate;
        }

        // Components (both implement ChartComponent & Widget)
        final ctrl.ControlChartComponentSmallCdeCdt useI =
            ctrl.ControlChartComponentSmallCdeCdt(
          dataPoints: dataPoints,
          controlChartStats: stats,
          dataLineColor: widget.dataLineColor,
          backgroundColor: widget.backgroundColor,
          height: h,
          width: w,
          xStart: start!,
          xEnd: end!,
        );

        final mr.MrChartComponentSmallCdeCdt useMr =
            mr.MrChartComponentSmallCdeCdt(
          dataPoints: dataPoints,
          controlChartStats: stats,
          dataLineColor: widget.dataLineColor,
          backgroundColor: widget.backgroundColor,
          height: h,
          width: w,
          xStart: start, 
          xEnd: end, // uncomment if supported
        );

        final ChartComponent comp = widget.isMovingRange ? useMr : useI;
        final Widget selectedWidget = comp as Widget;

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
              padding: const EdgeInsets.fromLTRB(16, 0, legendRightPad, 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Legend (จาก component — ภายในควรมี _sel เลือก CDE/CDT/Compound)
                  SizedBox(
                    height: legendHeight,
                    child: Align(
                      alignment: Alignment.center,
                      child: comp.buildLegend(),
                    ),
                  ),
                  const SizedBox(height: gapLegendToChart),

                  // Chart
                  Expanded(child: selectedWidget),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
