import 'package:control_chart/data/bloc/search_chart_details/extension/search_state_extension.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/domain/models/chart_data_point.dart';
import 'package:control_chart/domain/models/control_chart_stats.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';
import 'package:control_chart/ui/core/shared/medium_control_chart/cde_cdt/control_chart_template.dart';
import 'package:control_chart/ui/screen/screen_content/home_screen_content/home_content_var.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/component/temp.dart';
import 'package:flutter/material.dart';

/// Public builder — uses parent-controlled window when provided.
Widget buildChartsSectionCdeCdt(
  HomeContentVar settingProfile,
  SearchState searchState, [
  int? externalStart,
  int? externalWindowSize,
]) {
  final sel = searchState.controlChartStats?.secondChartSelected;
  if (sel == null || sel == SecondChartSelected.na) {
    return const SizedBox.shrink();
  }

  final isReady = searchState.status == SearchStatus.success && searchState.chartDetails.isNotEmpty;

  final label = switch (sel) {
    SecondChartSelected.cde => 'CDE',
    SecondChartSelected.cdt => 'CDT',
    SecondChartSelected.compoundLayer => 'Compound Layer',
    _ => '-',
  };

  final partName =
      isReady ? (searchState.chartDetails.first.chartGeneralDetail.partName ?? '-') : '-';

  final title = "Furnace ${settingProfile.furnaceNo ?? "-"} "
      " | $partName - ${settingProfile.materialNo ?? '-'}"
      " | Date ${fmtDate(settingProfile.startDate)} - ${fmtDate(settingProfile.endDate)}";

  return SizedBox.expand(
    child: _MediumContainerCdeCdt(
      title: title,
      selectedLabel: label,
      settingProfile: settingProfile,
      searchState: searchState,
      externalStart: externalStart,
      externalWindowSize: externalWindowSize,
    ),
  );
}

class _MediumContainerCdeCdt extends StatelessWidget {
  const _MediumContainerCdeCdt({
    required this.title,
    required this.selectedLabel,
    required this.settingProfile,
    required this.searchState,
    this.externalStart,
    this.externalWindowSize,
  });

  final String title;
  final String selectedLabel;
  final HomeContentVar settingProfile;
  final SearchState searchState;

  final int? externalStart;
  final int? externalWindowSize;

  static const int _defaultWindow = 24;

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

    // Visible window for both charts (CDE/CDT data)
    final visiblePoints = _slice<ChartDataPointCdeCdt>(state.chartDataPointsCdeCdt);

    final q = settingProfile;
    final uniqueKey = '${q.startDate?.millisecondsSinceEpoch ?? 0}-'
        '${q.endDate?.millisecondsSinceEpoch ?? 0}-'
        '${q.furnaceNo ?? ''}-'
        '${q.materialNo ?? ''}-';

    return Container(
      color: Colors.transparent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const sectionLabelH = 20.0;
          const gapV = 8.0;
          final eachChartH = ((constraints.maxHeight - (sectionLabelH + gapV) * 2 - 40) / 2)
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
                  // padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      // Header Top
                      Row(
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(
                                "$selectedLabel | Control Chart",
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
                              frozenDataPoints:
                                  List<ChartDataPointCdeCdt>.from(visiblePoints),
                              frozenStats: state.controlChartStats!,
                              frozenStatus: state.status,
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
                              frozenDataPoints:
                                  List<ChartDataPointCdeCdt>.from(visiblePoints),
                              frozenStats: state.controlChartStats!,
                              frozenStatus: state.status,
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