import 'package:control_chart/data/bloc/search_chart_details/extension/search_state_extension.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/domain/models/chart_data_point.dart';
import 'package:control_chart/domain/models/control_chart_stats.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/shared/medium_control_chart/cde_cdt/control_chart_component.dart';
import 'package:control_chart/ui/core/shared/medium_control_chart/cde_cdt/mr_chart_component.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../domain/types/chart_component.dart';

class ControlChartTemplateCdeCdt extends StatefulWidget {
  final String xAxisLabel;
  final String yAxisLabel;
  final Color? dataLineColor;
  final Color? backgroundColor;
  final double? height;
  final double? width;
  final bool isMovingRange;

  // Frozen overrides (sync window เหมือน surface hardness)
  final ControlChartStats? frozenStats;
  final List<ChartDataPointCdeCdt>? frozenDataPoints;
  final SearchStatus? frozenStatus;

  const ControlChartTemplateCdeCdt({
    super.key,
    this.xAxisLabel = 'Date',
    this.yAxisLabel = 'Attr.',
    this.dataLineColor = AppColors.colorBrand,
    this.backgroundColor = Colors.white,
    this.height = 300,
    this.width,
    required this.isMovingRange,
    this.frozenStats,
    this.frozenDataPoints,
    this.frozenStatus,
  });

  @override
  State<ControlChartTemplateCdeCdt> createState() => _ControlChartTemplateCdeCdtState();
}

class _ControlChartTemplateCdeCdtState extends State<ControlChartTemplateCdeCdt> {
  static const int _windowSize = 24;

  int _start = 0;
  int _maxStart = 0;
  int _lastLen = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncWindowToData();
  }

  @override
  void didUpdateWidget(covariant ControlChartTemplateCdeCdt oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncWindowToData();
  }

  void _syncWindowToData() {
    final full = _fullDataPoints();
    final n = full.length;

    if (n != _lastLen) {
      _lastLen = n;
      if (n <= _windowSize) {
        _start = 0;
        _maxStart = 0;
      } else {
        _maxStart = n - _windowSize;
        _start = _maxStart.clamp(0, _maxStart);
      }
      setState(() {});
    } else {
      if (n <= _windowSize) {
        _start = 0;
        _maxStart = 0;
      } else {
        _maxStart = n - _windowSize;
        _start = _start.clamp(0, _maxStart);
      }
    }
  }

  /// ✅ ใช้ข้อมูลจาก extension (ต้นทางเดียวกับ Surface Hardness)
  List<ChartDataPointCdeCdt> _fullDataPoints() {
    if (widget.frozenDataPoints != null) return widget.frozenDataPoints!;
    final state = context.read<SearchBloc>().state;
    return state.chartDataPointsCdeCdt; // ✅ มี fullLabel/furnaceNo/matNo ครบ
  }


  List<ChartDataPointCdeCdt> _visible(List<ChartDataPointCdeCdt> full) {
    if (full.length <= _windowSize) return full;
    final end = (_start + _windowSize).clamp(0, full.length);
    return full.sublist(_start, end);
  }

  @override
  Widget build(BuildContext context) {
    // frozen path
    if (widget.frozenStats != null && widget.frozenDataPoints != null) {
      return _buildFromData(
        dataPoints: _visible(widget.frozenDataPoints!),
        stats: widget.frozenStats!,
        status: widget.frozenStatus ?? SearchStatus.success,
        showSlider: (widget.frozenDataPoints!.length > _windowSize),
        totalLength: widget.frozenDataPoints!.length,
      );
    }

    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        final stats = state.controlChartStats;
        if (state.status == SearchStatus.loading) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }
        if (state.status == SearchStatus.failure) {
          return const Center(child: Text('จำนวนข้อมูลไม่เพียงพอ ต้องการข้อมูลอย่างน้อย 5 รายการ'));
        }
        if (stats == null || stats.secondChartSelected == SecondChartSelected.na) {
          return const SizedBox.shrink();
        }

        final full = _fullDataPoints(); // ✅ มาจาก chartDetails เดียวกับ surface hardness
        
        if (full.isEmpty) {
          return const Center(child: Text('ไม่มีข้อมูลสำหรับแสดงผล'));
        }


        return _buildFromData(
          dataPoints: _visible(full),
          stats: stats,
          status: state.status,
          showSlider: (full.length > _windowSize),
          totalLength: full.length,
        );
      },
    );
  }

  Widget _buildFromData({
    required List<ChartDataPointCdeCdt> dataPoints,
    required ControlChartStats stats,
    required SearchStatus status,
    required bool showSlider,
    required int totalLength,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = widget.width ?? constraints.maxWidth;
        final h = widget.height ?? constraints.maxHeight;

        final useI = ControlChartComponent(
          dataPoints: dataPoints,
          controlChartStats: stats,
          dataLineColor: widget.dataLineColor,
          backgroundColor: widget.backgroundColor,
          height: h,
          width: w,
        );
        final useMr = MrChartComponent(
          dataPoints: dataPoints,
          controlChartStats: stats,
          dataLineColor: widget.dataLineColor,
          backgroundColor: widget.backgroundColor,
          height: h,
          width: w,
        );
        final ChartComponent selectedWidget =
            widget.isMovingRange ? useMr : useI;

        const legendRightPad = 24.0;
        const legendHeight = 32.0;
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
              padding: const EdgeInsets.fromLTRB(0, 0, legendRightPad, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (showSlider)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 12, right: 12),
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 2,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        ),
                        child: Slider(
                          min: 0,
                          max: _maxStart.toDouble(),
                          value: _start.toDouble().clamp(0, _maxStart.toDouble()),
                          label: '${_start + 1} - ${(_start + _windowSize).clamp(0, totalLength)}',
                          onChanged: (v) => setState(() => _start = v.round()),
                        ),
                      ),
                    ),

                  // Legend
                  SizedBox(
                    height: legendHeight,
                    child: Align(
                      alignment: Alignment.center,
                      child: selectedWidget.buildLegend(),
                    ),
                  ),
                  const SizedBox(height: gapLegendToChart),

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
                        maxX: (dataPoints.length - 1).toDouble(), // เฉพาะ window ที่มองเห็น
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
  }
}
