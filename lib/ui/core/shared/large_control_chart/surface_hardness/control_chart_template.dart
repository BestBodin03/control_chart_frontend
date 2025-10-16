import 'dart:developer' as dev;

import 'package:control_chart/data/bloc/search_chart_details/extension/search_state_extension.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/domain/models/chart_data_point.dart';
import 'package:control_chart/domain/models/control_chart_stats.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/shared/medium_control_chart/surface_hardness/control_chart_component.dart';
import 'package:control_chart/ui/core/shared/medium_control_chart/surface_hardness/mr_chart_component.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../domain/types/chart_component.dart';

class ControlChartTemplateLarge extends StatefulWidget {
  final String xAxisLabel;
  final String yAxisLabel;
  final Color? dataLineColor;
  final Color? backgroundColor;
  final double? height; // can be overridden by parent
  final double? width;
  final bool isMovingRange;

  /// Parent-driven slider window (indexes over labels)
  final int? externalStart;
  final int? externalWindowSize;

  /// Optional explicit range override (if parent already resolved them)
  final DateTime? xStart;
  final DateTime? xEnd;

  /// Optional desired tick count (not used here but kept for API compat)
  final int? xTick;

  const ControlChartTemplateLarge({
    super.key,
    this.xAxisLabel = 'Date',
    this.yAxisLabel = 'Attr.',
    this.dataLineColor = AppColors.colorBrand,
    this.backgroundColor = Colors.white,
    this.height,
    this.width,
    required this.isMovingRange,
    this.externalStart,
    this.externalWindowSize,
    this.xStart,
    this.xEnd,
    this.xTick,
  });

  @override
  State<ControlChartTemplateLarge> createState() => _ControlChartTemplateLargeState();
}

class _ControlChartTemplateLargeState extends State<ControlChartTemplateLarge> {
  // -------------------- logging helpers --------------------
  void _log(String msg) {
    if (!kDebugMode) return;
    dev.log('[ControlChartTemplateLarge] $msg');
  }

  // ---------- Helpers: labels -> DateTime window ----------
  List<DateTime> _labelsFromState(SearchState st) {
    final raw = st.controlChartStats?.xAxisMediumLabel ?? const [];
    final labels = raw.map<DateTime?>((e) {
      if (e is DateTime) return e.toLocal();
      if (e is String) {
        try {
          return (e).toLocal();
        } catch (err) {
          _log('Failed to parse label String("$e"): $err');
        }
      }
      return null;
    }).whereType<DateTime>().toList();

    _log('labelsFromState -> count=${labels.length}'
        ' | first=${labels.isNotEmpty ? labels.first : '-'}'
        ' | last=${labels.isNotEmpty ? labels.last : '-'}');
    return labels;
  }

  /// Resolve the effective [xStart, xEnd] using precedence:
  /// 1) If widget.xStart/xEnd provided -> use them.
  /// 2) Else, if externalStart/windowSize set -> map to labels to derive dates.
  /// 3) Else, fallback to state's current query start/end (if available).
  (DateTime?, DateTime?) _resolveEffectiveRange(SearchState st) {
    // (1) Explicit override from parent
    if (widget.xStart != null && widget.xEnd != null) {
      _log('Using explicit range from widget: '
          'xStart=${widget.xStart}, xEnd=${widget.xEnd}');
      return (widget.xStart, widget.xEnd);
    }

    final labels = _labelsFromState(st);

    // (2) Window driven by slider over labels
    if (labels.isNotEmpty &&
        widget.externalStart != null &&
        widget.externalWindowSize != null &&
        widget.externalWindowSize! > 0) {
      final maxStart = (labels.length - widget.externalWindowSize!).clamp(0, labels.length - 1);
      final startIdx = widget.externalStart!.clamp(0, maxStart);
      final endIdx = (startIdx + widget.externalWindowSize! - 1).clamp(0, labels.length - 1);
      final left = labels[startIdx];
      final right = labels[endIdx];
      _log('Using slider window over labels: '
          'extStart=${widget.externalStart}, extWin=${widget.externalWindowSize} '
          '-> startIdx=$startIdx, endIdx=$endIdx, '
          'left=$left, right=$right');
      return (left, right);
    }

    // (3) Fallback to the state's current query
    final left = st.currentQuery.startDate;
    final right = st.currentQuery.endDate;
    _log('Fallback to state query range: xStart=$left, xEnd=$right');
    return (left, right);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        _log('build() status=${state.status}'
            ' | points=${state.chartDataPoints.length}'
            ' | stats=${state.controlChartStats != null}');

        // Failure
        if (state.status == SearchStatus.failure) {
          _log('State failure -> show error');
          return const Center(
            child: Text('จำนวนข้อมูลไม่เพียงพอ ต้องการข้อมูลอย่างน้อย 5 รายการ'),
          );
        }

        // No data
        if (state.controlChartStats == null || state.chartDataPoints.isEmpty) {
          _log('No stats or empty data -> show no data');
          return const Center(child: Text('ไม่มีข้อมูลสำหรับแสดงผล'));
        }

        // Resolve window dates (driven by slider/labels or explicit overrides)
        final (effectiveStart, effectiveEnd) = _resolveEffectiveRange(state);
        if (effectiveStart == null || effectiveEnd == null) {
          _log('Effective range is null -> show invalid range');
          return const Center(child: Text('ช่วงเวลาไม่ถูกต้อง'));
        }

        // Keep full data; filtering by xStart/xEnd happens in child component.
        final data = state.chartDataPoints;
        _log('Render with effective range: $effectiveStart -> $effectiveEnd | totalPoints=${data.length}');

        return _buildFromData(
          dataPoints: data,
          stats: state.controlChartStats!,
          status: state.status,
          xStart: effectiveStart,
          xEnd: effectiveEnd,
        );
      },
    );
  }

  Widget _buildFromData({
    required List<ChartDataPoint> dataPoints,
    required ControlChartStats stats,
    required SearchStatus status,
    required DateTime xStart,
    required DateTime xEnd,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = widget.width ?? constraints.maxWidth;
        final h = widget.height ?? constraints.maxHeight;
        _log('_buildFromData: box w=$w, h=$h, isMR=${widget.isMovingRange}');

        final useI = ControlChartComponent(
          dataPoints: dataPoints,
          controlChartStats: stats,
          dataLineColor: widget.dataLineColor,
          backgroundColor: widget.backgroundColor,
          height: h,
          width: w,
          xStart: xStart, // ✅ range from slider/labels
          xEnd: xEnd,     // ✅ range from slider/labels
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
          xStart: xStart,
          xEnd: xEnd,
        );

        final ChartComponent selectedWidget = widget.isMovingRange ? useMr : useI;

        const legendRightPad = 16.0;
        const legendHeight = 28.0;
        const gapLegendToChart = 4.0;

        // ⚠️ Design/layout kept exactly the same.
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
                      child: selectedWidget.buildLegend(context),
                    ),
                  ),
                  const SizedBox(height: gapLegendToChart),

                  // Chart (expanded)
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
