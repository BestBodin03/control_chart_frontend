import 'package:control_chart/data/bloc/search_chart_details/extension/search_state_extension.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/domain/models/chart_data_point.dart';
import 'package:control_chart/domain/models/control_chart_stats.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/shared/medium_control_chart/surface_hardness/control_chart_component.dart';
import 'package:control_chart/ui/core/shared/medium_control_chart/surface_hardness/mr_chart_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../domain/types/chart_component.dart';

class ControlChartTemplate extends StatefulWidget {
  final String xAxisLabel;
  final String yAxisLabel;
  final Color? dataLineColor;
  final Color? backgroundColor;
  final double? height; // can be overridden by parent
  final double? width;
  final bool isMovingRange;

  /// Optional frozen overrides (bypass Bloc)
  final ControlChartStats? frozenStats;
  final List<ChartDataPoint>? frozenDataPoints;
  final SearchStatus? frozenStatus;

  /// Parent-controlled windowing
  final int? externalStart;
  final int? externalWindowSize;

  /// ช่วงเวลาเป้าหมายที่ parent ต้องการให้กราฟใช้
  final DateTime? xStart;
  final DateTime? xEnd;
  final int? xTick;

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
    this.externalStart,
    this.externalWindowSize,
    this.xStart,
    this.xEnd,
    this.xTick,
  });

  @override
  State<ControlChartTemplate> createState() => _ControlChartTemplateState();
}

class _ControlChartTemplateState extends State<ControlChartTemplate> {
  // ---------- utils ----------

  List<ChartDataPoint> _visible(List<ChartDataPoint> full) {
    if (full.isEmpty) return const <ChartDataPoint>[];
    final start = (widget.externalStart ?? 0).clamp(0, full.length - 1);
    final win = widget.externalWindowSize;
    if (win == null || full.length <= win) return full;
    final end = (start + win).clamp(0, full.length);
    return full.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    // ---------- Frozen path (ไม่พึ่ง Bloc) ----------
    if (widget.frozenStats != null && widget.frozenDataPoints != null) {
      final data = _visible(widget.frozenDataPoints!);
      return _buildFromData(
        dataPoints: data,
        stats: widget.frozenStats!,
        status: widget.frozenStatus ?? SearchStatus.success,
      );
    }

    // ---------- Bloc path ----------
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        // 1) ยังไม่มีช่วงเป้าหมายจาก parent → แจ้งช่วงไม่ถูกต้อง
        if (widget.xStart == null || widget.xEnd == null) {
          return const Center(child: Text('ช่วงเวลาไม่ถูกต้อง'));
        }

        // 3) error
        if (state.status == SearchStatus.failure) {
          return const Center(
            child: Text('จำนวนข้อมูลไม่เพียงพอ ต้องการข้อมูลอย่างน้อย 5 รายการ'),
          );
        }

        // 4) ไม่มีข้อมูล
        if (state.controlChartStats == null || state.chartDataPoints.isEmpty) {
          return const Center(child: Text('ไม่มีข้อมูลสำหรับแสดงผล'));
        }

        // 5) พร้อมวาด (state ตรงช่วงที่ต้องการแล้ว)
        final data = _visible(state.chartDataPoints);
        return _buildFromData(
          dataPoints: data,
          stats: state.controlChartStats!,
          status: state.status,
        );
      },
    );
  }

  Widget _buildFromData({
    required List<ChartDataPoint> dataPoints,
    required ControlChartStats stats,
    required SearchStatus status,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = widget.width ?? constraints.maxWidth;
        final h = widget.height ?? constraints.maxHeight;

        // ใช้ช่วงของ parent (ต้องไม่เป็น null ถึงมาถึงฟังก์ชันนี้ได้)
        final DateTime start = widget.xStart!;
        final DateTime end   = widget.xEnd!;

        final useI = ControlChartComponent(
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

        final useMr = MrChartComponent(
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

        const legendRightPad = 24.0;
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
                  // Legend
                  SizedBox(
                    height: legendHeight,
                    child: Align(
                      alignment: Alignment.center,
                      child: selectedWidget.buildLegend(),
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
