import 'package:control_chart/data/bloc/search_chart_details/extension/search_state_extension.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/domain/types/chart_filter_query.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';
import 'package:control_chart/ui/core/shared/medium_control_chart/surface_hardness/control_chart_template.dart';
import 'package:control_chart/ui/screen/screen_content/home_screen_content/home_content_var.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/component/temp.dart';
import 'package:flutter/material.dart';

Widget buildChartsSectionSurfaceHardness(
  HomeContentVar settingProfile,
  SearchState searchState,
) {
  return SizedBox.expand(
    child: _buildChartContainer(
      title:
          "Furnace ${settingProfile.furnaceNo ?? "-"} "
          " | Material ${settingProfile.materialNo ?? '-'}"
          " | Date ${fmtDate(settingProfile.startDate)} - ${fmtDate(settingProfile.endDate)}",
      settingProfile: settingProfile,
      searchState: searchState,
    ),
  );
}

Widget _buildChartContainer({
  required String title,
  required HomeContentVar settingProfile,
  required SearchState searchState,
}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final totalH = constraints.maxHeight;
      const outerPadTop = 8.0;
      const outerPadBottom = 16.0;
      const titleH = 24.0;
      const sectionLabelH = 20.0;
      const gapV = 8.0;

      final chartsAreaH = (totalH
              - outerPadTop - outerPadBottom
              - titleH
              - gapV
              - 8.0
              - sectionLabelH
              - gapV
              - sectionLabelH
              - 8.0)
          .clamp(0.0, double.infinity);

      final eachChartH = (chartsAreaH / 2).clamp(0.0, double.infinity);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text(title, style: AppTypography.textBody2BBold)],
            ),
          ),

          // Card ครอบสองกราฟ
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.colorBrandTp.withValues(alpha: 0.15),
                border: Border.all(
                  color: AppColors.colorBrandTp.withValues(alpha: 0.35),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.0),
                      child: Text("Surface Hardness | Control Chart", style: AppTypography.textBody3BBold),
                    ),
                    _buildSingleChart(
                      settingProfile: settingProfile,
                      searchState: searchState,
                      isMovingRange: false,
                      height: eachChartH,
                    ),

                    const SizedBox(height: 8),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.0),
                      child: Text("Surface Hardness | Moving Range", style: AppTypography.textBody3BBold),
                    ),
                    _buildMrChart(
                      settingProfile: settingProfile,
                      searchState: searchState,
                      isMovingRange: true,
                      height: eachChartH,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

Widget _buildSingleChart({
  required HomeContentVar settingProfile,
  required SearchState searchState,
  required bool isMovingRange,
  required double height,
}) {
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

  // unique key ต่อสไลด์ (อิง settingProfile)
  final uniqueKey = '${settingProfile.startDate?.millisecondsSinceEpoch}-'
      '${settingProfile.endDate?.millisecondsSinceEpoch}-'
      '${settingProfile.furnaceNo}-'
      '${settingProfile.materialNo}-';

  return SizedBox(
    width: double.infinity,
    height: height,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: ControlChartTemplate(
          key: ValueKey(uniqueKey.hashCode.toString()),
          isMovingRange: false,
          height: height,
        ),
      ),
    ),
  );
}

Widget _buildMrChart({
  required HomeContentVar settingProfile,
  required SearchState searchState,
  required bool isMovingRange,
  required double height,
}) {
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

  final uniqueKey = '${settingProfile.startDate?.millisecondsSinceEpoch}-'
      '${settingProfile.endDate?.millisecondsSinceEpoch}-'
      '${settingProfile.furnaceNo}-'
      '${settingProfile.materialNo}-';

  return SizedBox(
    width: double.infinity,
    height: height,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: ControlChartTemplate(
          key: ValueKey(uniqueKey.hashCode.toString()),
          isMovingRange: true,
          height: height,
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
            Text('จำนวนข้อมูลไม่เพียงพอ ต้องการข้อมูลอย่างน้อย 5 รายการ', style: TextStyle(fontSize: 10, color: Colors.red)),
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