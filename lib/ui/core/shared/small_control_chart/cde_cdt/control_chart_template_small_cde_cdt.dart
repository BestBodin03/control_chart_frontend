import 'package:control_chart/data/bloc/search_chart_details/extension/search_state_extension.dart';
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
  final double? height;
  final double? width;
  final bool isMovingRange;

  final ControlChartStats? frozenStats;
  final List<ChartDataPointCdeCdt>? frozenDataPoints;
  final SearchStatus? frozenStatus;

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

        final DateTime start = widget.xStart!;
        final DateTime end = widget.xEnd!;

        final ctrl.ControlChartComponentSmallCdeCdt useI =
            ctrl.ControlChartComponentSmallCdeCdt(
          dataPoints: dataPoints,
          controlChartStats: stats,
          dataLineColor: widget.dataLineColor,
          backgroundColor: widget.backgroundColor,
          height: h,
          width: w,
          xStart: start,
          xEnd: end,
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
          xEnd: end,
        );

        final ChartComponent selected =
            widget.isMovingRange ? useMr : useI;
        final Widget selectedWidget = selected as Widget;

        const legendRightPad = 16.0;
        const legendHeight = 16.0;
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
              padding: const EdgeInsets.fromLTRB(16, 16, legendRightPad, 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: legendHeight,
                    child: Align(
                      alignment: Alignment.center,
                      child: selected.buildLegend(),
                    ),
                  ),
                  const SizedBox(height: gapLegendToChart),
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
