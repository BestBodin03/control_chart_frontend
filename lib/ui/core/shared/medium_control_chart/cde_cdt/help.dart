import 'package:control_chart/data/bloc/search_chart_details/extension/search_state_extension.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/domain/models/chart_data_point.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';
// import 'package:control_chart/ui/core/shared/medium_control_chart/cde_cdt/control_chart_template_cde_cdt.dart';
import 'package:control_chart/ui/core/shared/violations_component.dart';
import 'package:control_chart/ui/screen/screen_content/home_screen_content/home_content_var.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../domain/models/control_chart_stats.dart';
import '../../../../../utils/app_route.dart';
import 'control_chart_template.dart';

typedef CdeCdtZoomBuilder = Widget Function(
  BuildContext context,
  HomeContentVar settingProfile,
  SearchState searchState,
);

Widget buildChartsSectionCdeCdt(
  List<HomeContentVar> profiles,
  int currentIndex,
  SearchState searchState, {
  // ZoomBuilder? zoomBuilder,
  int? externalStart,
  int? externalWindowSize,
  int? xAxisStart,
  int? xAxisWinSize,
  DateTime? baseStart,
  DateTime? baseEnd
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

  // ---- Title: Furnace | Material | Date (เหมือน Surface) ----
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
      currentIndex: currentIndex,
      // onZoom: (ctx) {
      //   if (zoomBuilder == null) return;
      //   showDialog(
      //     context: ctx,
      //     builder: (_) => Dialog(
      //       insetPadding: const EdgeInsets.all(24),
      //       clipBehavior: Clip.antiAlias,
      //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      //       child: zoomBuilder(ctx, current, searchState),
      //     ),
      //   );
      // },
    ),
  );
}

class _MediumContainerCdeCdt extends StatelessWidget {
  const _MediumContainerCdeCdt({
    required this.title,
    required this.selectedLabel,
    required this.settingProfile,
    required this.searchState,
    this.currentIndex
    // this.onZoom,
  });

  final String title;
  final String selectedLabel;
  final HomeContentVar settingProfile;
  final SearchState searchState;
  // final void Function(BuildContext)? onZoom;
  final int? currentIndex;

  T? _sel<T>(T? cde, T? cdt, T? comp) {
    switch (searchState.controlChartStats?.secondChartSelected) {
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

  @override
  Widget build(BuildContext context) {
    final state = searchState;

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

    // ใช้ช่วงเวลาแบบ Surface: ส่ง full data + xStart/xEnd ให้ template
    final allPoints = state.chartDataPointsCdeCdt;
    final records = allPoints.length;

    final q = settingProfile;
    final uniqueKey = '${q.startDate?.millisecondsSinceEpoch ?? 0}-'
        '${q.endDate?.millisecondsSinceEpoch ?? 0}-'
        '${q.furnaceNo ?? ''}-'
        '${q.materialNo ?? ''}-';

    final xStart = q.startDate;
    final xEnd = q.endDate;

    final int vOverControl = _sel(
          state.controlChartStats?.cdeViolations?.beyondControlLimit,
          state.controlChartStats?.cdtViolations?.beyondControlLimit,
          state.controlChartStats?.compoundLayerViolations?.beyondControlLimit,
        ) ??
        0;

    final int vOverSpec = _sel(
          state.controlChartStats?.cdeViolations?.beyondSpecLimit,
          state.controlChartStats?.cdtViolations?.beyondSpecLimit,
          state.controlChartStats?.compoundLayerViolations?.beyondSpecLimit,
        ) ??
        0;

    final int vTrend = _sel(
          state.controlChartStats?.cdeViolations?.trend,
          state.controlChartStats?.cdtViolations?.trend,
          state.controlChartStats?.compoundLayerViolations?.trend,
        ) ??
        0;

    final bgColor = _getViolationBgColor(vOverControl, vOverSpec, vTrend);
    final borderColor = _getViolationBorderColor(vOverControl, vOverSpec, vTrend);

    const sectionLabelH = 20.0;
    const gapV = 8.0;

    return Container(
      color: Colors.transparent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final eachChartH = ((constraints.maxHeight - (sectionLabelH + gapV) * 2 - 108) / 2)
              .clamp(0.0, double.infinity);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row
              Row(
                children: [
                  Expanded(
                    child: Material( // ✅ เพิ่มแค่ Material ครอบ InkWell
                      color: Colors.transparent, // ให้ใช้พื้นหลังเดิม ไม่ทับธีม/สีของ Home
                      child: InkWell(
                        onTap: () {
                          // current คือ HomeContentVar ของการ์ดนี้
                          final snap = HomeContentVar(
                            startDate:  settingProfile.startDate,
                            endDate:    settingProfile.endDate,
                            furnaceNo:  settingProfile.furnaceNo,
                            materialNo: settingProfile.materialNo,
                            // เติม field อื่นที่จำเป็นต่อการค้นหา/แสดงผล
                          );

                            AppRoute.instance.searchSnapshot.value = snap; // ✅ ส่ง snapshot ข้ามหน้า
                            AppRoute.instance.navIndex.value = 1;          // ไปแท็บ Search
                          },
                        child: Center(
                          child: Text(title, style: AppTypography.textBody3BBold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Card
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
                      // Header Top
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
                                  "$selectedLabel",
                                  style: AppTypography.textBody3BBold,
                                ),
                                Text(
                                  "Control Chart",
                                  style: AppTypography.textBody3B,
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

                      // Control Chart
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
                                "$selectedLabel | Moving Range",
                                style: AppTypography.textBody3B,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // MR Chart
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

// ---- Helpers: สีพื้น/เส้นกรอบตาม violation (เหมือน Surface) ----
Color _getViolationBgColor(int overControl, int overSpec, int trend) {
  if (overSpec > 0)   return Colors.red.withValues(alpha: 0.15);
  if (overControl > 0) return Colors.orange.withValues(alpha: 0.15);
  if (trend > 0)      return Colors.pink.withValues(alpha: 0.15);
  return AppColors.colorBrandTp.withValues(alpha: 0.15);
}

Color _getViolationBorderColor(int overControl, int overSpec, int trend) {
  if (overSpec > 0)   return Colors.red.withValues(alpha: 0.70);
  if (overControl > 0) return Colors.orange.withValues(alpha: 0.70);
  if (trend > 0)      return Colors.pinkAccent.withValues(alpha: 0.70);
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
