import 'package:control_chart/data/bloc/search_chart_details/extension/search_state_extension.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';
import 'package:control_chart/ui/core/shared/large_control_chart/surface_hardness/control_chart_template.dart';
import 'package:control_chart/ui/screen/screen_content/home_screen_content/home_content_var.dart';
import 'package:flutter/material.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/component/temp.dart';

/// ใช้ใน Dialog: ส่ง HomeContentVar + SearchState (snapshot ตอนกดซูม)
Widget buildChartsSectionSurfaceHardnessLarge(
  HomeContentVar settingProfile,
  SearchState searchState, {
  VoidCallback? onClose, // optional: ปิดจากภายนอกได้
}) {
  final title =
      "Furnace ${settingProfile.furnaceNo ?? "-"} "
      " | Material ${settingProfile.materialNo ?? '-'}"
      " | Date ${fmtDate(settingProfile.startDate)} - ${fmtDate(settingProfile.endDate)}";

  return SizedBox.expand(
    child: _LargeContainer(
      title: title,
      settingProfile: settingProfile,
      searchState: searchState,
      onClose: onClose,
    ),
  );
}

class _LargeContainer extends StatelessWidget {
  const _LargeContainer({
    required this.title,
    required this.settingProfile,
    required this.searchState,
    this.onClose,
  });

  final String title;
  final HomeContentVar settingProfile;
  final SearchState searchState;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const outerPadTop = 8.0;
        const outerPadBottom = 16.0;
        const titleH = 24.0;
        const sectionLabelH = 20.0;
        const gapV = 8.0;

        final totalH = constraints.maxHeight;
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
            // Title (center)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text(title, style: AppTypography.textBody2BBold)],
              ),
            ),
            // Card ครอบสองกราฟ
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0, 16, 16),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.colorBgGrey,
                    border: Border.all(color: AppColors.colorBrandTp, width: 1),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Column(
                      children: [
                        // Header แถวบน: ข้อความกลาง + ปุ่มปิดขวาสุด
                        Row(
                          children: [
                            const SizedBox(width: 20), // balance ซ้าย
                            Expanded(
                              child: Center(
                                child: Text(
                                  "Surface Hardness | Control Chart",
                                  style: AppTypography.textBody3BBold,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: onClose ?? () => Navigator.of(context).maybePop(),
                                child: const Padding(
                                  padding: EdgeInsets.all(6.0),
                                  child: Icon(Icons.cancel_rounded, size: 18),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Chart 1
                        _buildSingleChart(
                          settingProfile: settingProfile,
                          searchState: searchState,
                          height: eachChartH,
                        ),

                        const SizedBox(height: 8),

                        // Header + Chart 2 (MR)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            "Surface Hardness | Moving Range",
                            style: AppTypography.textBody3BBold,
                          ),
                        ),
                        _buildMrChart(
                          settingProfile: settingProfile,
                          searchState: searchState,
                          height: eachChartH,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// large/help.dart (ส่วน _buildSingleChart)
Widget _buildSingleChart({
  required HomeContentVar settingProfile,
  required SearchState searchState,  // ← snapshot ที่รับมาตอนเปิด dialog
  required double height,
}) {
  if (searchState.status == SearchStatus.loading) {
    return const Center(
      child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
  if (searchState.status == SearchStatus.failure) return const _SmallError();
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
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: ControlChartTemplate(
          key: ValueKey(uniqueKey.hashCode.toString()),
          isMovingRange: false, // หรือ true สำหรับ MR
          height: height,
          // 👇 ใส่ snapshot เพื่อ “ล็อก” กราฟ
          frozenStats:   searchState.controlChartStats,
          frozenDataPoints: searchState.chartDataPoints,
          frozenStatus:  searchState.status,
        ),

      ),
    ),
  );
}

// large/help.dart (ส่วน _buildMrChart)
Widget _buildMrChart({
  required HomeContentVar settingProfile,
  required SearchState searchState,
  required double height,
}) {
  if (searchState.status == SearchStatus.loading) {
    return const Center(
      child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
  if (searchState.status == SearchStatus.failure) return const _SmallError();
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
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: ControlChartTemplate(
          key: ValueKey(uniqueKey.hashCode.toString()),
          isMovingRange: false, // หรือ true สำหรับ MR
          height: height,
          // 👇 ใส่ snapshot เพื่อ “ล็อก” กราฟ
          frozenStats:   searchState.controlChartStats,
          frozenDataPoints: searchState.chartDataPoints,
          frozenStatus:  searchState.status,
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
      const Center(child: Text('ไม่พบข้อมูล', style: TextStyle(fontSize: 12, color: Colors.grey)));
}