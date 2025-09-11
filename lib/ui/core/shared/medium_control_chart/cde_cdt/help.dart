import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/domain/models/control_chart_stats.dart';
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
  // ถ้าไม่ได้เลือกอะไรหรือเลือก NA -> ไม่แสดง
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
    _                                 => '-', // กันกรณีอื่น ๆ
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
      settingProfile: settingProfile,
      searchState: searchState,
      selectedLabel: label,
    ),
  );
}

/// ==============================
/// Container (title + 2 charts)
/// ==============================
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
      const outerPadBottom = 16.0; // <- fixed from 'outerPom'
      const titleH = 24.0;
      const sectionLabelH = 20.0;
      const gapV = 8.0;

      // คำนวณพื้นที่กราฟ
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

      // guard state
      if (searchState.status == SearchStatus.loading) {
        return const Center(
          child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
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

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title (ให้สอดคล้องกับ Surface Hardness ส่วนบน)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(title, style: AppTypography.textBody3BBold),
                  ),
                ),
                // ตำแหน่ง actions เพิ่มเติม (เช่น Zoom builder) ถ้าต้องการภายหลัง
              ],
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
                    // Header บนของกราฟ (Control Chart) + ปุ่ม Zoom
                    Row(
                      children: [
                        const SizedBox(width: 8),
                        Expanded(
                          child: Center(
                            child: Text(
                              "$selectedLabel | Control Chart",
                              style: AppTypography.textBody3BBold,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text("Zoom"),
                                  content: const Text("ใส่ widget ขยายที่คุณมีอยู่แล้วในที่นี้"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text("Close"),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const Icon(Icons.zoom_out_map_rounded, size: 16),
                          ),
                        ),
                      ],
                    ),

                    // กราฟบน (Control Chart)
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

                    // Header ล่าง (Moving Range)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        "$selectedLabel | Moving Range",
                        style: AppTypography.textBody3BBold,
                      ),
                    ),

                    // กราฟล่าง (MR Chart)
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
          ),
        ],
      );
    },
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
