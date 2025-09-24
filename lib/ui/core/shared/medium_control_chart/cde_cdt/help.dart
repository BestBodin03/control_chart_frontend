import 'package:control_chart/data/bloc/search_chart_details/extension/search_state_extension.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/domain/models/chart_data_point.dart';
import 'package:control_chart/domain/models/control_chart_stats.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';
import 'package:control_chart/ui/core/shared/medium_control_chart/cde_cdt/control_chart_template.dart';
import 'package:control_chart/ui/core/shared/violations_component.dart';
import 'package:control_chart/ui/screen/screen_content/home_screen_content/home_content_var.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/component/temp.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Keep a separate typedef name to avoid clashing with Surface's ZoomBuilder.
typedef CdeCdtZoomBuilder = Widget Function(
  BuildContext context,
  HomeContentVar settingProfile,
  SearchState searchState,
);

/// Public builder — Surface-like: uses time window (xStart/xEnd) from settingProfile,
/// shows 2 charts (Control & MR), and keeps the selected attribute logic.
Widget buildChartsSectionCdeCdt(
  List<HomeContentVar> profiles,
  int currentIndex,
  SearchState searchState, {
  CdeCdtZoomBuilder? zoomBuilder,
  int? externalStart,        // kept for API parity
  int? externalWindowSize,   // kept for API parity
  int? xAxisStart,           // reserved for parity
  int? xAxisWinSize,         // reserved for parity
  DateTime? baseStart,       // NEW: for title date range (like Surface)
  DateTime? baseEnd,         // NEW: for title date range (like Surface)
}) {
  final sel = searchState.controlChartStats?.secondChartSelected;
  if (sel == null || sel == SecondChartSelected.na) {
    return const SizedBox.shrink();
  }

  final selectedLabel = switch (sel) {
    SecondChartSelected.cde => 'CDE',
    SecondChartSelected.cdt => 'CDT',
    SecondChartSelected.compoundLayer => 'Compound Layer',
    _ => '-',
  };

  final current = profiles[currentIndex];

  // ---- Build title parts (Furnace | Material | Date), same as Surface ----
  final bool isReady =
      searchState.status == SearchStatus.success &&
      searchState.chartDetails.isNotEmpty;

  final List<String> parts = [];

  // 1) Furnace
  final String? furnaceNo = current.furnaceNo;
  if (furnaceNo != null) parts.add('Furnace $furnaceNo');

  // 2) Material (show partName - matNo if available)
  if (isReady && current.materialNo != null) {
    final partName = searchState.chartDetails.first.chartGeneralDetail.partName?.trim();
    final mat = current.materialNo!;
    parts.add((partName != null && partName.isNotEmpty) ? '$partName - $mat' : mat);
  }

  // 3) Date range (from caller)
  if (baseStart != null && baseEnd != null) {
    parts.add('Date ${DateFormat('dd/MM').format(baseStart)} - ${DateFormat('dd/MM').format(baseEnd)}');
  }

  final title = parts.join(' | ');

  return SizedBox.expand(
    child: _MediumContainerCdeCdt(
      title: title,
      selectedLabel: selectedLabel,
      settingProfile: current,
      searchState: searchState,
      externalStart: externalStart,
      externalWindowSize: externalWindowSize,
      xAxisStart: xAxisStart,
      xAxisWinSize: xAxisWinSize,
      onZoom: (ctx) {
        if (zoomBuilder == null) return;
        showDialog(
          context: ctx,
          builder: (_) => Dialog(
            insetPadding: const EdgeInsets.all(24),
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: zoomBuilder(ctx, current, searchState),
          ),
        );
      },
    ),
  );
}

class _MediumContainerCdeCdt extends StatelessWidget {
  const _MediumContainerCdeCdt({
    required this.title,
    required this.selectedLabel,
    required this.settingProfile,
    required this.searchState,
    this.onZoom,
    this.externalStart,
    this.externalWindowSize,
    this.xAxisStart,
    this.xAxisWinSize,
  });

  final String title;
  final String selectedLabel;
  final HomeContentVar settingProfile;
  final SearchState searchState;
  final void Function(BuildContext)? onZoom;

  // Kept for API parity with Surface (not used when time-windowing).
  final int? externalStart;
  final int? externalWindowSize;
  final int? xAxisStart;
  final int? xAxisWinSize;

  @override
  Widget build(BuildContext context) {
    final state = searchState;

    // ---- Guards (same as Surface) ----
    if (state.status == SearchStatus.loading) {
      return const Center(
        child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (state.status == SearchStatus.failure) {
      return const _SmallError();
    }
    if (state.controlChartStats == null || state.chartDetails.isEmpty) {
      return const _SmallNoData();
    }

  T? _sel<T>(T? cde, T? cdt, T? comp) {
    switch (state.controlChartStats?.secondChartSelected) {
      case SecondChartSelected.cde:
        return cde;
      case SecondChartSelected.cdt:
        return cdt;
      case SecondChartSelected.compoundLayer:
        return comp;
      default:
        return null;
    }
  }

    // Use Surface-like time window: pass full data and the explicit xStart/xEnd to the templates.
    final allPoints = state.chartDataPointsCdeCdt;
    final records = allPoints.length; // simple count pill

    final q = settingProfile;
    final uniqueKey = '${q.startDate?.millisecondsSinceEpoch ?? 0}-'
        '${q.endDate?.millisecondsSinceEpoch ?? 0}-'
        '${q.furnaceNo ?? ''}-'
        '${q.materialNo ?? ''}-';

    final xStart = q.startDate;
    final xEnd = q.endDate;

    final int? vOverControl = _sel(
      state.controlChartStats?.cdeViolations?.beyondControlLimit ?? 0,
      state.controlChartStats?.cdtViolations?.beyondControlLimit ?? 0,
      state.controlChartStats?.compoundLayerViolations?.beyondControlLimit ?? 0,
    );

    final int? vOverSpec = _sel(
      state.controlChartStats?.cdeViolations?.beyondSpecLimit ?? 0,
      state.controlChartStats?.cdtViolations?.beyondSpecLimit ?? 0,
      state.controlChartStats?.compoundLayerViolations?.beyondSpecLimit ?? 0,
    );

    final int? vTrend = _sel(
      state.controlChartStats?.cdeViolations?.trend ?? 0,
      state.controlChartStats?.cdtViolations?.trend ?? 0,
      state.controlChartStats?.compoundLayerViolations?.trend ?? 0,
    );

    final bgColor = _getViolationBgColor(vOverControl!, vOverSpec!, vTrend!);
    final borderColor = _getViolationBorderColor(vOverControl, vOverSpec, vTrend);

    return Container(
      color: Colors.transparent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const sectionLabelH = 20.0;
          const gapV = 8.0;
          final eachChartH = ((constraints.maxHeight - (sectionLabelH + gapV) * 2 - 108) / 2)
              .clamp(0.0, double.infinity);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- Title row (centered), like Surface ----
              Row(
                children: [
                  Expanded(
                    child: Center(child: Text(title, style: AppTypography.textBody3BBold)),
                  ),
                ],
              ),

              // ---- Card w/ violation color + header similar to Surface ----
              DecoratedBox(
                decoration: BoxDecoration(
                  color: bgColor,
                  border: Border.all(color: borderColor, width: 1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                  child: Column(
                    children: [
                      // Header Top (left: label + count pill, right: Violations + zoom)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "$selectedLabel | Control Chart",
                                  style: AppTypography.textBody3BBold,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(width: 1, color: Colors.grey.shade500),
                                  ),
                                  child: Text(
                                    '$records Records',
                                    style: AppTypography.textBody3BBold,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 220,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(width: 1, color: Colors.grey.shade500),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withValues(alpha: 0.8),
                                        offset: const Offset(0, -2),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: ViolationsColumn(
                                      beyondControlLimit: vOverControl,
                                      beyondSpecLimit: vOverSpec,
                                      trend: vTrend,
                                    ),
                                  ),
                                ),
                              ),
                              // IconButton(
                              //   tooltip: 'Zoom',
                              //   icon: const Icon(Icons.fullscreen, size: 18),
                              //   splashRadius: 8,
                              //   onPressed: onZoom == null ? null : () => onZoom!(context),
                              // ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // ---- Control Chart (time-windowed) ----
                      SizedBox(
                        width: double.infinity,
                        height: eachChartH,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: ControlChartTemplateCdeCdt(
                              key: ValueKey('${uniqueKey}_cdecdt_top'.hashCode.toString()),
                              isMovingRange: false,
                              height: eachChartH,
                              frozenDataPoints: List<ChartDataPointCdeCdt>.from(allPoints),
                              frozenStats: state.controlChartStats!,
                              frozenStatus: state.status,
                              xStart: xStart,
                              xEnd: xEnd,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // ---- Header bottom (MR label) ----
                      Row(
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(
                                "$selectedLabel |  Moving Range",
                                style: AppTypography.textBody3B,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // ---- MR Chart (time-windowed) ----
                      SizedBox(
                        width: double.infinity,
                        height: eachChartH,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: ControlChartTemplateCdeCdt(
                              key: ValueKey('${uniqueKey}_cdecdt_mr'.hashCode.toString()),
                              isMovingRange: true,
                              height: eachChartH,
                              frozenDataPoints: List<ChartDataPointCdeCdt>.from(allPoints),
                              frozenStats: state.controlChartStats!,
                              frozenStatus: state.status,
                              xStart: xStart,
                              xEnd: xEnd,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ---- Reuse the same helpers as Surface (or keep these if you want a local copy) ----
// Decide background color based on violation hierarchy
Color _getViolationBgColor(int overControl, int overSpec, int trend) {
  if (overSpec > 0) {
    return Colors.red.withValues(alpha: 0.15);
    // return Colors.pink.shade200.withValues(alpha: 0.15);
  } else if (overControl > 0) {
    return Colors.orange.withValues(alpha: 0.15);
    // return Colors.red.shade200.withValues(alpha: 0.15);
  } else if (trend > 0) {
    return Colors.pink.withValues(alpha: 0.15);
  }
  return AppColors.colorBrandTp.withValues(alpha: 0.15);
}

// Decide border color in same hierarchy
Color _getViolationBorderColor(int overControl, int overSpec, int trend) {
  if (overSpec > 0) {
    return Colors.red.withValues(alpha: 0.70);
    // return Colors.pink.shade200.withValues(alpha: 0.15);
  } else if (overControl > 0) {
    return Colors.orange.withValues(alpha: 0.70);
    // return Colors.red.shade200.withValues(alpha: 0.15);
  } else if (trend > 0) {
    return Colors.pinkAccent.withValues(alpha: 0.70);
  }
  return AppColors.colorBrandTp.withValues(alpha: 0.70);
}

class _SmallError extends StatelessWidget {
  const _SmallError();
  @override
  Widget build(BuildContext context) => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 16, color: Colors.red),
            SizedBox(height: 4),
            Text('จำนวนข้อมูลไม่เพียงพอ ต้องการข้อมูลอย่างน้อย 5 รายการ',
                style: TextStyle(fontSize: 10, color: Colors.red)),
          ],
        ),
      );
}

class _SmallNoData extends StatelessWidget {
  const _SmallNoData();
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('ไม่มีข้อมูลสำหรับแสดงผล', style: TextStyle(fontSize: 12, color: Colors.grey)));
}


