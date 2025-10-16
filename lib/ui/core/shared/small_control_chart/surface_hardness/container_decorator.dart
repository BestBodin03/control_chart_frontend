import 'package:control_chart/domain/types/chart_atrribute.dart';
import 'package:control_chart/ui/screen/screen_content/searching_screen_content/searching_var.dart';
import 'package:flutter/material.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/data/bloc/search_chart_details/extension/search_state_extension.dart';

import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';
import 'package:control_chart/ui/core/shared/small_control_chart/surface_hardness/control_chart_template_small.dart';

import 'package:control_chart/domain/models/chart_data_point.dart';

import '../../common/chart/small_chart_height_scaler.dart';
import '../../common/info_content.dart';
import '../../common/info_overlay.dart';
import '../../spec_validation.dart';

/// ----------------------------------------------------------------------------
/// Public builder
/// ----------------------------------------------------------------------------
Widget buildChartsSectionSurfaceHardnessSmall(SearchState searchState) {
  // ❌ อย่าใช้ Row+Expanded ที่นี่ เพราะมักถูกวางใต้ SingleChildScrollView
  // ✅ คืนการ์ดตรง ๆ ให้พาเรนต์เป็นคนตัดสินใจว่าจะ Expanded หรือไม่
  return _SmallCard(searchState: searchState);
}

class _SmallCard extends StatefulWidget {
  const _SmallCard({required this.searchState});
  final SearchState searchState;

  @override
  State<_SmallCard> createState() => _SmallCardState();
}

class _SmallCardState extends State<_SmallCard> {
  static const double _chartH = 360; // fixed height ต่อหนึ่งกราฟ
  static const double _gapV = 8;

  bool _showLegend = false;

  @override
  Widget build(BuildContext context) {
    final searchState = widget.searchState;

    // States
    if (searchState.status == SearchStatus.loading) {
      return const _StateBox(child: _Loading());
    }
    if (searchState.status == SearchStatus.failure) {
      return const _StateBox(child: _Error());
    }
    if (searchState.controlChartStats == null || searchState.chartDetails.isEmpty) {
      return const _StateBox(child: _Empty());
    }

    final title = 'Surface Hardness';
    final dataPoints = searchState.chartDataPoints;
    final stats = searchState.controlChartStats?.surfaceHardnessCapabilityProcess;
    final lowerSpec = searchState.controlChartStats?.specAttribute?.surfaceHardnessLowerSpec;
    final upperSpec = searchState.controlChartStats?.specAttribute?.surfaceHardnessUpperSpec;
    final hasSpec  = isValidSpec(lowerSpec) || isValidSpec(upperSpec);
    final hasSpecL = isValidSpec(lowerSpec) && !isValidSpec(upperSpec);
    final hasSpecU = !isValidSpec(lowerSpec) && isValidSpec(upperSpec);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min, // ✅ สำคัญเมื่ออยู่ใต้สกอลล์
      children: [
        // Title row (compact)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8,
          children: [
            Text(title, style: AppTypography.textBody3BBold),
            IconButton(
              hoverColor: AppColors.colorBrandTp,
              splashRadius: 8,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                showDialog(
                  context: context,
                  barrierColor: Colors.transparent, // let InfoOverlay handle dim
                  builder: (_) => InfoOverlay(
                    onClose: () => Navigator.of(context).pop(),
                    child: InfoContent(
                      selectedPeriodType: searchPeriodType,
                      searchState: searchState,
                      chartAttribute: ChartAttribute.SURFACE_HARDNESS,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.info_rounded, size: 24),
              tooltip: 'Info',
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        _ViolationColumn(searchState: searchState),

        const SizedBox(height: 8),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: _showLegend
              ? Padding(
                  key: const ValueKey('legend-on'),
                  padding: const EdgeInsets.only(bottom: 0),
                )
              : const SizedBox.shrink(key: ValueKey('legend-off')),
        ),

        // Blue card (charts only)
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.colorBrandTp.withValues(alpha: 0.15),
            border: Border.all(
              color: AppColors.colorBrandTp.withValues(alpha: 0.35),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min, // ✅
              children: [
                const SizedBox(height: _gapV),
                // --- Control Chart (I) ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline, // ให้ตัวอักษรเสมอ baseline เดียวกัน
                  textBaseline: TextBaseline.alphabetic,           // ต้องระบุเมื่อใช้ Baseline
                  children: [
                    const _SectionLabel('Control Chart'),

                    const Spacer(), // ดันข้อความ CP/CPK ไปชิดขวา แทนการใช้ spaceBetween

                  if (hasSpec)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        hasSpecL
                            ? 'CPL = ${stats?.cpl?.toStringAsFixed(2) ?? 'N/A'}'
                            : hasSpecU
                                ? 'CPU = ${stats?.cpu?.toStringAsFixed(2) ?? 'N/A'}'
                                : 'CP = ${stats?.cp?.toStringAsFixed(2) ?? 'N/A'} | '
                                  'CPK = ${stats?.cpk?.toStringAsFixed(2) ?? 'N/A'}',
                        style: AppTypography.textBody4BBold,
                      ),
                    ),
                  ],
                ),
                _SmallChartBox(
                  searchState: searchState,
                  dataPoints: dataPoints,
                  isMr: false,
                  fixedHeight: _chartH,
                ),

                const SizedBox(height: _gapV),

                // --- MR ---
                const SizedBox(height: 8),
                const _SectionLabel('Moving Range'),
                _SmallChartBox(
                  searchState: searchState,
                  dataPoints: dataPoints,
                  isMr: true,
                  fixedHeight: _chartH,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


class _ViolationColumn extends StatelessWidget {
  const _ViolationColumn({required this.searchState});
  final SearchState searchState;

  @override
  Widget build(BuildContext context) {
    final s = searchState.controlChartStats;
    String fmt(double? v) => (v == null || v == 0.0) ? 'N/A' : v.toStringAsFixed(2);

    // --- Violations ---
    final v = s?.surfaceHardnessViolations;
    final overSpecLower    = v?.beyondSpecLimitLower ?? 0;
    final overSpecUpper    = v?.beyondSpecLimitUpper ?? 0;
    final overControlLower = v?.beyondControlLimitLower ?? 0;
    final overControlUpper = v?.beyondControlLimitUpper ?? 0;
    final trend       = v?.trend ?? 0;
    final showViolations =
        searchState.currentQuery.materialNo != null || searchState.currentQuery.furnaceNo != null;

    return showViolations
    ? Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 8, 8),
        child: SizedBox(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.colorBg,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.6),
                  blurRadius: 10,
                  offset: Offset(-5, -5),
                ),
                BoxShadow(
                  color: AppColors.colorBrandTp.withValues(alpha: 0.4),
                  blurRadius: 4,
                  offset: Offset(5, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              _ViolationChip(
                                label: 'Over Spec (L)',
                                count: overSpecLower,
                                color: Colors.red,
                              ),
                              _ViolationChip(
                                label: 'Over Spec (U)',
                                count: overSpecUpper,
                                color: Colors.red,
                              ),
                              _ViolationChip(
                                label: 'Over Control (L)',
                                count: overControlLower,
                                color: Colors.orange,
                              ),
                              _ViolationChip(
                                label: 'Over Control (U)',
                                count: overControlUpper,
                                color: Colors.orange,
                              ),
                              _ViolationChip(
                                label: 'Trend',
                                count: trend,
                                color: Colors.pinkAccent,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      )
    : const SizedBox.shrink();
  }
}

class _ViolationChip extends StatelessWidget {
  const _ViolationChip({required this.label, this.count, required this.color});
  final String label;
  final int? count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final int c = count ?? 0;
    final bool isZero = c == 0;
    final bool showCount = label != 'Trend';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: isZero ? Colors.white : color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isZero ? Colors.grey.shade400 : color.withValues(alpha: 0.8),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // status dot
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),

          // label
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.colorBlack,
            ),
          ),

          const SizedBox(width: 4),

          // count slot (always there, empty if !showCount)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: showCount
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: isZero ? Colors.grey.shade300 : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$c',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isZero ? Colors.grey.shade700 : AppColors.colorBlack,
                      ),
                    ),
                  )
                : const SizedBox(width: 2, height: 18), // 👈 transparent placeholder only
          ),
        ],
      ),
    );
  }

}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8),
      child: Row(
        children: [
          Text(text, style: AppTypography.textBody4BBold, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _SmallChartBox extends StatelessWidget {
  const _SmallChartBox({
    required this.searchState,
    required this.dataPoints,
    required this.isMr,
    required this.fixedHeight, // kept for API compatibility (not used)
  });

  final SearchState searchState;
  final List<ChartDataPoint> dataPoints;
  final bool isMr;
  final double fixedHeight; // ignored in favor of responsive height

  @override
  Widget build(BuildContext context) {
    final q = searchState.currentQuery;
    final keySeed =
        '${q.startDate?.millisecondsSinceEpoch}-${q.endDate?.millisecondsSinceEpoch}-${q.furnaceNo}-${q.materialNo}-${isMr ? 'mr' : 'i'}';

    final double h = responsiveChartHeight(context); // ✅ smooth 144..248

    return SizedBox(
      width: double.infinity,
      height: h,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: ControlChartTemplateSmall(
            key: ValueKey(keySeed.hashCode.toString()),
            isMovingRange: isMr,
            frozenDataPoints: List<ChartDataPoint>.from(dataPoints),
            frozenStats: searchState.controlChartStats!,
            frozenStatus: searchState.status,
            xStart: q.startDate,
            xEnd: q.endDate,
          ),
        ),
      ),
    );
  }
}



/// ----------------------------------------------------------------------------
/// States
/// ----------------------------------------------------------------------------
class _StateBox extends StatelessWidget {
  const _StateBox({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // ❌ หลีกเลี่ยง SizedBox.expand ใต้ Column/Scroll
    // ✅ ใช้ Center ธรรมดาแทน
    return Center(child: child);
  }
}

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) => const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
}

class _Error extends StatelessWidget {
  const _Error();
  @override
  Widget build(BuildContext context) => const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 16, color: Colors.red),
          SizedBox(height: 4),
          Text('จำนวนข้อมูลไม่เพียงพอ ต้องการข้อมูลอย่างน้อย 5 รายการ',
              style: TextStyle(fontSize: 12, color: Colors.red)),
        ],
      );
}

class _Empty extends StatelessWidget {
  const _Empty();
  @override
  Widget build(BuildContext context) =>
      const Text('ไม่มีข้อมูลสำหรับแสดงผล', style: TextStyle(fontSize: 12, color: Colors.grey));
}
