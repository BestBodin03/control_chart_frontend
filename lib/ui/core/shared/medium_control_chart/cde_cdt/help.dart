import 'package:control_chart/data/bloc/search_chart_details/extension/search_state_extension.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/domain/models/chart_data_point.dart';
import 'package:control_chart/domain/models/control_chart_stats.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';
import 'package:control_chart/ui/core/shared/medium_control_chart/cde_cdt/control_chart_template.dart';
import 'package:control_chart/ui/core/shared/violationRow.dart';
import 'package:control_chart/ui/screen/screen_content/home_screen_content/home_content_var.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/component/temp.dart';
import 'package:flutter/material.dart';

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
  int? externalStart,        // kept for compatibility; not used when time-windowing
  int? externalWindowSize,   // kept for compatibility; not used when time-windowing
  int? xAxisStart,           // reserved for parity with Surface; handled inside templates
  int? xAxisWinSize,         // reserved for parity with Surface; handled inside templates
}) {
  final sel = searchState.controlChartStats?.secondChartSelected;
  if (sel == null || sel == SecondChartSelected.na) {
    return const SizedBox.shrink();
  }

  final label = switch (sel) {
    SecondChartSelected.cde => 'CDE',
    SecondChartSelected.cdt => 'CDT',
    SecondChartSelected.compoundLayer => 'Compound Layer',
    _ => '-',
  };
  final current = profiles[currentIndex];

  final bool isReady =
      searchState.status == SearchStatus.success &&
      searchState.chartDetails.isNotEmpty;

  final List<String> parts = [];

 // 1) Furnace (แสดงเมื่อมี furnaceNo)
  final String? furnaceNo = current.furnaceNo;
  if (furnaceNo != null) {
    parts.add('Furnace $furnaceNo');
  }

  // 2) Material (แสดงเมื่อ ready + มี materialNo)
  if (isReady && current.materialNo != null) {
    final partName = searchState
        .chartDetails.first.chartGeneralDetail.partName
        ?.trim();
    final mat = current.materialNo!;
    parts.add(
      (partName != null && partName.isNotEmpty) ? '$partName - $mat' : '$mat',
    );
  }

  // 3) Date (แสดงเมื่อมี start & end ครบ)
  final s = current.startDate;
  final e = current.endDate;
  if (s != null && e != null) {
    parts.add('Date ${fmtDate(s)} - ${fmtDate(e)}');
  }

  // ผลลัพธ์: จะมีเฉพาะส่วนที่มีข้อมูลจริง และคั่นด้วย " | "
  final title = parts.join(' | ');


  return SizedBox.expand(
    child: _MediumContainerCdeCdt(
      title: title,
      settingProfile: current,
      searchState: searchState,
      externalStart: externalStart,
      externalWindowSize: externalWindowSize,
      xAxisStart: xAxisStart,
      xAxisWinSize: xAxisWinSize,
      onZoom: (ctx) {
        showDialog(
          context: ctx,
          builder: (_) => Dialog(
            insetPadding: const EdgeInsets.all(24),
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: zoomBuilder!(ctx, current, searchState),
          ),
        );
      }, selectedLabel: label,
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
    // state.controlChartStats?.controlChartSpots?.surfaceHardness

    // Guards
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

    // Use Surface-like time window: pass full data and the explicit xStart/xEnd to the templates.
    final allPoints = state.chartDataPointsCdeCdt;

    final q = settingProfile;
    final uniqueKey = '${q.startDate?.millisecondsSinceEpoch ?? 0}-'
        '${q.endDate?.millisecondsSinceEpoch ?? 0}-'
        '${q.furnaceNo ?? ''}-'
        '${q.materialNo ?? ''}-';

    final xStart = q.startDate;
    final xEnd = q.endDate;

    return Container(
      color: Colors.transparent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const sectionLabelH = 20.0;
          const gapV = 8.0;
          final eachChartH = ((constraints.maxHeight - (sectionLabelH + gapV) * 2 - 72) / 2)
              .clamp(0.0, double.infinity);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row (centered) — no slider; slider is in HomeContent
              Row(
                children: [
                  Expanded(
                    child: Center(child: Text(title, style: AppTypography.textBody3BBold)),
                  ),
                  // if (onZoom != null) ...[
                  //   // const SizedBox(width: 8),
                  //   IconButton(
                  //     tooltip: 'Zoom',
                  //     icon: const Icon(Icons.fullscreen, size: 18),
                  //     onPressed: () => onZoom!(context),
                  //   ),
                  // ],
                ],
              ),

              // Card
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.colorBrandTp.withValues(alpha: 0.15),
                  border: Border.all(color: AppColors.colorBrandTp.withValues(alpha: 0.35), width: 1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      // Header Top
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "$selectedLabel | Control Chart",
                            style: AppTypography.textBody3B,
                            textAlign: TextAlign.center,
                          ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Beyond Spec Limit",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12
                                ),
                                textAlign: TextAlign.center
                                ),
                              Text(
                                "Beyond Control Limit",
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 12
                                ),
                                textAlign: TextAlign.center
                                ),
                              Text(
                                "Trend",
                                style: TextStyle(
                                  color: Colors.teal,
                                  fontSize: 12
                                ),
                                textAlign: TextAlign.center
                                )
                            ],
                          ),

                          if (onZoom != null) ...[
                            IconButton(
                              tooltip: 'Zoom',
                              icon: const Icon(Icons.fullscreen, size: 18),
                              onPressed: () => onZoom!(context),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Control Chart (Surface-like: pass explicit time window)
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

                      // Header bottom
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

                      // MR Chart (Surface-like: pass explicit time window)
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

class _SmallError extends StatelessWidget {
  const _SmallError({super.key});
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
  const _SmallNoData({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('No Data', style: TextStyle(fontSize: 12, color: Colors.grey)));
}

class _ViolationRow extends StatelessWidget {
  const _ViolationRow({
    required this.label,
    required this.labelColor,
    required this.wrongIconColor,
    required this.correctIconColor,
    required this.count,
  });

  final String label;
  final Color labelColor;
  final Color wrongIconColor;
  final Color correctIconColor;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(color: labelColor, fontSize: 12)),
        const SizedBox(width: 8),
        // wrong / correct circles
        Icon(Icons.circle, size: 10, color: wrongIconColor),
        const SizedBox(width: 4),
        Icon(Icons.circle, size: 10, color: correctIconColor),
        const SizedBox(width: 8),
        // count pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.06),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _TrendIconsRow extends StatelessWidget {
  const _TrendIconsRow({
    required this.label,
    required this.labelColor,
    required this.iconColor,
    this.showActiveHint = false,
  });

  final String label;
  final Color labelColor;
  final Color iconColor;
  final bool showActiveHint;

  @override
  Widget build(BuildContext context) {
    // slightly emphasize the first icon when trend exists
    final Color firstColor = showActiveHint
        ? iconColor.withOpacity(0.95)
        : iconColor.withOpacity(0.65);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(color: labelColor, fontSize: 12)),
        const SizedBox(width: 8),
        Icon(Icons.trending_up_rounded, size: 14, color: firstColor),
        const SizedBox(width: 4),
        Icon(Icons.show_chart_rounded, size: 14, color: iconColor.withOpacity(0.85)),
      ],
    );
  }
}



