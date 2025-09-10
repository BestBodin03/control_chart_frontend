import 'package:control_chart/data/bloc/search_chart_details/extension/search_state_extension.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/domain/types/chart_filter_query.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';
import 'package:control_chart/ui/core/shared/medium_control_chart/surface_hardness/control_chart_template.dart';
import 'package:control_chart/ui/screen/screen_content/home_screen_content/home_content_var.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/component/temp.dart';
import 'package:flutter/material.dart';

// file: cde_cdt_section.dart
import 'package:control_chart/data/bloc/search_chart_details/extension/search_state_extension.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';
import 'package:control_chart/ui/core/shared/medium_control_chart/cde_cdt/control_chart_template.dart';
import 'package:control_chart/ui/screen/screen_content/home_screen_content/home_content_var.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/component/temp.dart';
import 'package:flutter/material.dart';

/// ==============================
/// Public builder
/// ==============================
Widget buildChartsSectionCdeCdt(
  HomeContentVar settingProfile,
  SearchState searchState,
) {
  return SizedBox.expand(
    child: _buildChartContainerCdeCdt(
      title:
          "Furnace ${settingProfile.furnaceNo ?? "-"} "
          " | Material ${settingProfile.materialNo ?? '-'}"
          " | Date ${fmtDate(settingProfile.startDate)} - ${fmtDate(settingProfile.endDate)}",
      settingProfile: settingProfile,
      searchState: searchState,
    ),
  );
}

/// ==============================
/// Container (title + 2 charts)
/// ==============================
Widget _buildChartContainerCdeCdt({
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
              - 8.0 // padding top inside card
              - sectionLabelH
              - gapV
              - sectionLabelH
              - 8.0 // padding bottom inside card
          ).clamp(0.0, double.infinity);

      final eachChartH = (chartsAreaH / 2).clamp(0.0, double.infinity);

      String cdeOrCdtLabel(num? cde, num? cdt, num? compoundLayer) {
        final a = (cde ?? 0).toDouble();
        final b = (cdt ?? 0).toDouble();
        final c = (compoundLayer ?? 0).toDouble();
        int nonZero = 0;
        if (a != 0) nonZero++;
        if (b != 0) nonZero++;
        if (c != 0) nonZero++;
        if (nonZero > 1) return 'N/A';
        if (a != 0) return 'CDE';
        if (b != 0) return 'CDT';
        if (c != 0) return 'Compound Layer';
        return 'N/A';
      }

      final label = cdeOrCdtLabel(
        searchState.controlChartStats?.cdeAverage,
        searchState.controlChartStats?.cdtAverage,
        searchState.controlChartStats?.compoundLayerAverage,
      );

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
                    // Label บน: Control Chart
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        "$label | Control Chart",
                        style: AppTypography.textBody3BBold,
                      ),
                    ),
                    _buildSingleChart(
                      settingProfile: settingProfile,
                      searchState: searchState,
                      isMovingRange: false,
                      height: eachChartH,
                    ),

                    const SizedBox(height: 8),

                    // Label ล่าง: Moving Range
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        "$label | Moving Range",
                        style: AppTypography.textBody3BBold,
                      ),
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

/// ==============================
/// Upper chart (Control Chart)
/// ==============================
Widget _buildSingleChart({
  required HomeContentVar settingProfile,
  required SearchState searchState,
  required bool isMovingRange,
  required double height,
}) {
  if (searchState.status == SearchStatus.loading) {
    return const Center(
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
  if (searchState.status == SearchStatus.failure) {
    return const _SmallError();
  }
  if (searchState.controlChartStats == null ||
      searchState.chartDetails.isEmpty) {
    return const _SmallNoData();
  }

  final uniqueKey = '${settingProfile.startDate?.millisecondsSinceEpoch ?? 0}-'
      '${settingProfile.endDate?.millisecondsSinceEpoch ?? 0}-'
      '${settingProfile.furnaceNo ?? ''}-'
      '${settingProfile.materialNo ?? ''}-';

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
        child: ControlChartTemplateCdeCdt(
          key: ValueKey(uniqueKey.hashCode.toString()),
          isMovingRange: false,
          height: height,
        ),
      ),
    ),
  );
}

/// ==============================
/// Lower chart (Moving Range)
/// ==============================
Widget _buildMrChart({
  required HomeContentVar settingProfile,
  required SearchState searchState,
  required bool isMovingRange,
  required double height,
}) {
  if (searchState.status == SearchStatus.loading) {
    return const Center(
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
  if (searchState.status == SearchStatus.failure) {
    return const _SmallError();
  }
  if (searchState.controlChartStats == null ||
      searchState.chartDetails.isEmpty) {
    return const _SmallNoData();
  }

  final uniqueKey = '${settingProfile.startDate?.millisecondsSinceEpoch ?? 0}-'
      '${settingProfile.endDate?.millisecondsSinceEpoch ?? 0}-'
      '${settingProfile.furnaceNo ?? ''}-'
      '${settingProfile.materialNo ?? ''}-';

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
        child: ControlChartTemplateCdeCdt(
          key: ValueKey(uniqueKey.hashCode.toString()),
          isMovingRange: true,
          height: height,
        ),
      ),
    ),
  );
}

/// ==============================
/// Small states
/// ==============================
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
  Widget build(BuildContext context) => const Center(
        child: Text('No Data',
            style: TextStyle(fontSize: 12, color: Colors.grey)),
      );
}
