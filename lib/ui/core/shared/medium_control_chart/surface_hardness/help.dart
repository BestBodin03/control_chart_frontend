import 'package:control_chart/data/bloc/search_chart_details/extension/search_state_extension.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/domain/models/chart_data_point.dart';
import 'package:control_chart/domain/models/setting.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';
import 'package:control_chart/ui/core/shared/medium_control_chart/surface_hardness/control_chart_template.dart';
import 'package:control_chart/ui/core/shared/violations_component.dart';
import 'package:control_chart/ui/screen/screen_content/home_screen_content/home_content_var.dart';
import 'package:control_chart/utils/app_route.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

typedef ZoomBuilder = Widget Function(
  BuildContext context,
  HomeContentVar settingProfile,
  SearchState searchState,
);

Widget buildChartsSectionSurfaceHardness(
  List<HomeContentVar> profiles,
  int currentIndex,
  SearchState searchState, {
  ZoomBuilder? zoomBuilder,
  int? externalStart,
  int? externalWindowSize,
  int? xAxisStart,
  int? xAxisWinSize,
  DateTime? baseStart,
  DateTime? baseEnd
}) {
  assert(currentIndex >= 0 && currentIndex < profiles.length, 'currentIndex out of range');

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
        .trim();
    final mat = current.materialNo!;
    parts.add(
      (partName != null && partName.isNotEmpty) ? '$partName - $mat' : mat,
    );
  }

  // 3) Date (แสดงเมื่อมี start & end ครบ)
  final s = baseStart;
  final e = baseEnd;
  if (s != null && e != null) {
    parts.add('Date ${DateFormat('dd/MM').format(s)} - ${DateFormat('dd/MM').format(e)}');
  }

  // ผลลัพธ์: จะมีเฉพาะส่วนที่มีข้อมูลจริง และคั่นด้วย " | "
  final title = parts.join(' | ');

  return SizedBox.expand(
    child: _MediumContainer(
      title: title,
      settingProfile: current,
      searchState: searchState,
      externalStart: externalStart,
      externalWindowSize: externalWindowSize,
      xAxisStart: xAxisStart,
      xAxisWinSize: xAxisWinSize,
      currentIndex: currentIndex,
    ),
  );
}

class _MediumContainer extends StatelessWidget {
  const _MediumContainer({
    required this.title,
    required this.settingProfile,
    required this.searchState,
    // required this.onZoom,
    this.externalStart,
    this.externalWindowSize,
    this.xAxisStart,
    this.xAxisWinSize,
    this.currentIndex
  });

  final String title;
  final HomeContentVar settingProfile;
  final SearchState searchState;
  // final void Function(BuildContext) onZoom;
  // parent-controlled window
  final int? externalStart;
  final int? externalWindowSize;
  final int? xAxisStart;
  final int? xAxisWinSize;
  final int? currentIndex;


  // static const int _defaultWindow = 30;

  // List<T> _slice<T>(List<T> full) {
  //   if (full.isEmpty) return full;

  //   final win = externalWindowSize ?? _defaultWindow;
  //   if (full.length <= win) return full;

  //   final maxStart = full.length - win;
  //   final start = (externalStart ?? maxStart).clamp(0, maxStart);
  //   final end = (start + win).clamp(0, full.length);
  //   return full.sublist(start, end);
  // }

  @override
  Widget build(BuildContext context) {
    final state = searchState;
    final spotCount = state.controlChartStats?.numberOfSpots;

    final violations = state.controlChartStats?.surfaceHardnessViolations;
    final bgColor = _getViolationBgColor(
      violations?.beyondControlLimitLower ?? 0,
      violations?.beyondControlLimitUpper ?? 0,
      violations?.beyondSpecLimitLower ?? 0,
      violations?.beyondSpecLimitUpper ?? 0,
      violations?.trend ?? 0,
    );
    final borderColor = _getViolationBorderColor(
      violations?.beyondControlLimitLower ?? 0,
      violations?.beyondControlLimitUpper ?? 0,
      violations?.beyondSpecLimitLower ?? 0,
      violations?.beyondSpecLimitUpper ?? 0,
      violations?.trend ?? 0,
    );

// used only for proportions inside layout
    const sectionLabelH = 20.0;
    const gapV = 8.0;

    final allPoints = searchState.chartDataPoints;

    // windowed (visible) data used by both charts
    // final visiblePoints = _slice<ChartDataPoint>(state.chartDataPoints);

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

    debugPrint('in help MAX ${searchState.controlChartStats?.yAxisRange?.maxYsurfaceHardnessControlChart}');

    return Container(
      color: Colors.transparent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final eachChartH = ((constraints.maxHeight - (sectionLabelH + gapV) * 2 - 120) / 2)
              .clamp(0.0, double.infinity);
          final combineControlLimit = (violations?.beyondControlLimitLower ?? 0) + (violations?.beyondControlLimitUpper ?? 0);
          final combineSpecLimit    = (violations?.beyondSpecLimitLower ?? 0) + (violations?.beyondSpecLimitUpper ?? 0);
          final hasSpec = searchState.controlChartStats?.specAttribute?.surfaceHardnessLowerSpec != null ||
                searchState.controlChartStats?.specAttribute?.surfaceHardnessUpperSpec != null;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row (centered) — no slider here; slider is in HomeContent
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
                      IntrinsicHeight(
                      child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                      // LEFT: title/subtitle on top, Records at bottom
                      Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween, // ⬅️ push Records to bottom
                      children: [
                        // Top block
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Surface Hardness",
                              style: AppTypography.textBody3BBold,
                              textAlign: TextAlign.start,
                            ),
                            Text(
                              "Control Chart",
                              style: AppTypography.textBody3B,
                              textAlign: TextAlign.start,
                            ),
                            if (hasSpec)
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text(
                                'CP = ${searchState.controlChartStats?.surfaceHardnessCapabilityProcess?.cp?.toStringAsFixed(2) ?? 'N/A'} | '
                                'CPK = ${searchState.controlChartStats?.surfaceHardnessCapabilityProcess?.cpk?.toStringAsFixed(2) ?? 'N/A'}',
                                style: AppTypography.textBody3BBold,
                              ),
                            ),
                          ],
                        ),

                        // Bottom: Records chip
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: SizedBox(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha:0.6),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(width: 1, color: Colors.grey.shade500),
                              ),
                              child: Text(
                                '$spotCount Records',
                                style: AppTypography.textBody3BBold,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                      ),
                      ),

                      // RIGHT: violations card (unchanged)
                      Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: SizedBox(
                          width: 292,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha:0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(width: 1, color: Colors.grey.shade500),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.colorBg.withValues(alpha:0.4),
                                  offset: const Offset(0, -2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: ViolationsColumn(
                                combinedControlLimit: combineControlLimit,
                                combinedSpecLimit:    combineSpecLimit,
                                trend: violations?.trend ?? 0,
                                overCtrlLower: violations?.beyondControlLimitLower ?? 0,
                                overCtrlUpper: violations?.beyondControlLimitUpper ?? 0,
                                overSpecLower: violations?.beyondSpecLimitLower ?? 0,
                                overSpecUpper: violations?.beyondSpecLimitUpper ?? 0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      ],
                      ),
                      ],
                      ),
                      ),


                      const SizedBox(height: 4),

                      // Control Chart
                      _buildSingleChart(
                        settingProfile: settingProfile,
                        searchState: state,
                        height: eachChartH,
                        visiblePoints: allPoints,
                        isMovingRange: false,
                      ),

                      const SizedBox(height: 8),

                      // Header bottom
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                                Text(
                                  "Moving Range",
                                  style: AppTypography.textBody3B,
                                  textAlign: TextAlign.start,
                                ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // MR Chart
                      _buildSingleChart(
                        settingProfile: settingProfile,
                        searchState: state,
                        height: eachChartH,
                        visiblePoints: allPoints,
                        isMovingRange: true,
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

Color _getViolationBgColor(int overControlLower, int overControlUpper, 
int overSpecLower, int overSpecUpper, int trend) {
  if (overSpecUpper > 0 || overSpecLower > 0) {
    return Colors.red.withValues(alpha: 0.15);
    // return Colors.pink.shade200.withValues(alpha: 0.15);
  } else if (overControlUpper > 0 || overControlLower > 0) {
    return Colors.orange.withValues(alpha: 0.15);
    // return Colors.red.shade200.withValues(alpha: 0.15);
  } else if (trend > 0) {
    return Colors.pink.withValues(alpha: 0.15);
  }
  return AppColors.colorBrandTp.withValues(alpha: 0.15);
}

// Decide border color in same hierarchy
Color _getViolationBorderColor(int overControlLower, int overControlUpper, 
int overSpecLower, int overSpecUpper, int trend) {
  if (overSpecUpper > 0 || overSpecLower > 0) {
    return Colors.red.withValues(alpha: 0.70);
    // return Colors.pink.shade200.withValues(alpha: 0.15);
  } else if (overControlUpper > 0 || overControlLower > 0) {
    return Colors.orange.withValues(alpha: 0.70);
    // return Colors.red.shade200.withValues(alpha: 0.15);
  } else if (trend > 0) {
    return Colors.pinkAccent.withValues(alpha: 0.70);
  }
  return AppColors.colorBrandTp.withValues(alpha: 0.70);
}


Widget _buildSingleChart({
  required HomeContentVar settingProfile,
  required SearchState searchState,
  required bool isMovingRange,
  required double height,
  required List<ChartDataPoint> visiblePoints,
}) {

  final allPoints = searchState.chartDataPoints;
  final q = settingProfile;
  final uniqueKey = '${q.startDate?.millisecondsSinceEpoch}-'
      '${q.endDate?.millisecondsSinceEpoch}-'
      '${q.furnaceNo}-'
      '${q.materialNo}-';

  // print('in help ${q.startDate!.millisecondsSinceEpoch}');

  return SizedBox(
    width: double.infinity,
    height: height,
    child: DecoratedBox(
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: ControlChartTemplate(
          key: ValueKey(uniqueKey.hashCode.toString() + (isMovingRange ? '_mr' : '_cc')),
          isMovingRange: isMovingRange,
          height: height,
          // freeze same window for both charts
          frozenDataPoints: List<ChartDataPoint>.from(allPoints),
          frozenStats: searchState.controlChartStats!,
          frozenStatus: searchState.status,
          // xTick: searchState.controlChartStats?.xTick,
          xStart: settingProfile.startDate,
          xEnd: settingProfile.endDate,
        ),
      ),
    ),
  );
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

  double getXInterval(PeriodType periodType, double startMs, double endMs) {
    const double dayMs = 86400000.0;

    int stepDays;
    switch (periodType) {
      case PeriodType.ONE_MONTH:
        stepDays = 7;
        break;
      case PeriodType.THREE_MONTHS:
        stepDays = 14;
        break;
      case PeriodType.SIX_MONTHS:
        stepDays = 30;
        break;
      case PeriodType.ONE_YEAR:
      default:
        stepDays = 60;
        break;
    }
    // interval ของแกน X (หน่วย ms)
    return stepDays * dayMs;
  }