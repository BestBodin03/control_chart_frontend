import 'package:control_chart/data/bloc/search_chart_details/extension/search_state_extension.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/domain/models/chart_data_point.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';
import 'package:control_chart/ui/core/shared/medium_control_chart/surface_hardness/control_chart_template.dart';
import 'package:control_chart/ui/screen/screen_content/home_screen_content/home_content_var.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/component/temp.dart';
import 'package:flutter/material.dart';

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
        ?.trim();
    final mat = current.materialNo!;
    parts.add(
      (partName != null && partName.isNotEmpty) ? '$partName - $mat' : '$mat',
    );
  }

  // 3) Date (แสดงเมื่อมี start & end ครบ)
  final s = baseStart;
  final e = baseEnd;
  if (s != null && e != null) {
    parts.add('Date ${fmtDate(s)} - ${fmtDate(e)}');
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
      },
    ),
  );
}

class _MediumContainer extends StatelessWidget {
  const _MediumContainer({
    required this.title,
    required this.settingProfile,
    required this.searchState,
    required this.onZoom,
    this.externalStart,
    this.externalWindowSize,
    this.xAxisStart,
    this.xAxisWinSize
  });

  final String title;
  final HomeContentVar settingProfile;
  final SearchState searchState;
  final void Function(BuildContext) onZoom;
  // parent-controlled window
  final int? externalStart;
  final int? externalWindowSize;
  final int? xAxisStart;
  final int? xAxisWinSize;


  static const int _defaultWindow = 30;

  List<T> _slice<T>(List<T> full) {
    if (full.isEmpty) return full;

    final win = externalWindowSize ?? _defaultWindow;
    if (full.length <= win) return full;

    final maxStart = full.length - win;
    final start = (externalStart ?? maxStart).clamp(0, maxStart);
    final end = (start + win).clamp(0, full.length);
    return full.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    final state = searchState;

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

    return Container(
      color: Colors.transparent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final eachChartH = ((constraints.maxHeight - (sectionLabelH + gapV) * 2 - 40) / 2)
              .clamp(0.0, double.infinity);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row (centered) — no slider here; slider is in HomeContent
              Row(
                children: [
                  Expanded(
                    child: Center(child: Text(title, style: AppTypography.textBody3BBold)),
                  ),
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
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                  child: Column(
                    children: [
                      // Header Top
                      Row(
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(
                                "Surface Hardness | Control Chart",
                                style: AppTypography.textBody3B,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          // const SizedBox(width: 20),
                        ],
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
                      Row(
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(
                                "Surface Hardness |  Moving Range",
                                style: AppTypography.textBody3B,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
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

Widget _buildSingleChart({
  required HomeContentVar settingProfile,
  required SearchState searchState,
  required bool isMovingRange,
  required double height,
  required List<ChartDataPoint> visiblePoints,
}) {

  final allPoints = searchState.chartDataPoints;
  final q = settingProfile;
  final uniqueKey = '${q.startDate?.microsecondsSinceEpoch}-'
      '${q.endDate?.microsecondsSinceEpoch}-'
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