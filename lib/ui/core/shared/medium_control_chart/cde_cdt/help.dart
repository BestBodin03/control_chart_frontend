import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/domain/models/control_chart_stats.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';
import 'package:control_chart/ui/core/shared/medium_control_chart/cde_cdt/control_chart_template.dart';
import 'package:control_chart/ui/screen/screen_content/home_screen_content/home_content_var.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/component/temp.dart';
import 'package:flutter/material.dart';

/// Public builder
Widget buildChartsSectionCdeCdt(
  HomeContentVar settingProfile,
  SearchState searchState,
) {
  final sel = searchState.controlChartStats?.secondChartSelected;
  if (sel == null || sel == SecondChartSelected.na) {
    return const SizedBox.shrink();
  }

  final isReady = searchState.status == SearchStatus.success &&
                  searchState.chartDetails.isNotEmpty;

  final label = switch (sel) {
    SecondChartSelected.cde           => 'CDE',
    SecondChartSelected.cdt           => 'CDT',
    SecondChartSelected.compoundLayer => 'Compound Layer',
    _                                 => '-',
  };

  final partName = isReady
      ? (searchState.chartDetails.first.chartGeneralDetail.partName ?? '-')
      : '-';

  final title =
      "Furnace ${settingProfile.furnaceNo ?? "-"} "
      " | $partName - ${settingProfile.materialNo ?? '-'}"
      " | Date ${fmtDate(settingProfile.startDate)} - ${fmtDate(settingProfile.endDate)}";

  return SizedBox.expand(
    child: _buildChartContainerCdeCdt(
      title: title,
      selectedLabel: label,
      settingProfile: settingProfile,
      searchState: searchState,
    ),
  );
}

/// Container: title + (Control + MR) with same style as surface hardness
Widget _buildChartContainerCdeCdt({
  required String title,
  required String selectedLabel,
  required HomeContentVar settingProfile,
  required SearchState searchState,
}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final totalH = constraints.maxHeight;
      const outerPadTop = 8.0;
      const outerPadBottom = 8.0;
      const titleH = 24.0;
      const sectionLabelH = 20.0;
      const gapV = 8.0;

      final chartsAreaH = (totalH
              - outerPadTop - outerPadBottom
              - titleH - gapV - 8.0
              - sectionLabelH - gapV
              - sectionLabelH - 8.0)
          .clamp(0.0, double.infinity);

      final eachChartH = (chartsAreaH / 2).clamp(0.0, double.infinity);

      // guards
      if (searchState.status == SearchStatus.loading) {
        return const Center(
          child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
        );
      }
      if (searchState.status == SearchStatus.failure) {
        return const _SmallError();
      }
      if (searchState.controlChartStats == null || searchState.chartDetails.isEmpty) {
        return const _SmallNoData();
      }

      final q = settingProfile;
      final uniqueKey = '${q.startDate?.millisecondsSinceEpoch ?? 0}-'
          '${q.endDate?.millisecondsSinceEpoch ?? 0}-'
          '${q.furnaceNo ?? ''}-'
          '${q.materialNo ?? ''}-';

      return Container(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row (centered)
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
                border: Border.all(
                  color: AppColors.colorBrandTp.withValues(alpha: 0.35),
                  width: 1,
                ),
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
                              "$selectedLabel | Control Chart",
                              style: AppTypography.textBody3B,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                      ],
                    ),

                    // Control Chart (with internal slider like surface)
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
                            key: ValueKey('${uniqueKey}_top'.hashCode.toString()),
                            isMovingRange: false,
                            height: eachChartH,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Header bottom
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.0),
                      child: Text("Moving Range", style: AppTypography.textBody3B),
                    ),

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
                            key: ValueKey('${uniqueKey}_mr'.hashCode.toString()),
                            isMovingRange: true,
                            height: eachChartH,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
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
            Text(
              'จำนวนข้อมูลไม่เพียงพอ ต้องการข้อมูลอย่างน้อย 5 รายการ',
              style: TextStyle(fontSize: 10, color: Colors.red),
            ),
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
