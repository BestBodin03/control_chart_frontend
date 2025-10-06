import 'package:control_chart/domain/extension/map.dart';
import 'package:control_chart/domain/types/chart_atrribute.dart';
import 'package:control_chart/ui/core/shared/chart_selection.dart';
import 'package:control_chart/ui/screen/screen_content/searching_screen_content/searching_var.dart';
import 'package:flutter/material.dart';
import 'package:control_chart/domain/models/chart_data_point.dart' show ChartDataPointCdeCdt;
import 'package:control_chart/domain/models/control_chart_stats.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/data/bloc/search_chart_details/extension/search_state_extension.dart';

import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';
import 'package:control_chart/ui/core/shared/small_control_chart/cde_cdt/control_chart_template_small_cde_cdt.dart';

import '../../common/info_content.dart';
import '../../common/info_overlay.dart';
import '../../spec_validation.dart';

/// ============================================================================
/// Public builder
/// ============================================================================
Widget buildChartsSectionCdeCdtSmall(SearchState searchState) {
  return _SmallCardCdeCdt(searchState: searchState);
}

/// ============================================================================
/// Card (CDE/CDT/Compound Layer) — same design as Surface Hardness
/// ============================================================================
class _SmallCardCdeCdt extends StatefulWidget {
  const _SmallCardCdeCdt({required this.searchState});
  final SearchState searchState;

  @override
  State<_SmallCardCdeCdt> createState() => _SmallCardCdeCdtState();
}

class _SmallCardCdeCdtState extends State<_SmallCardCdeCdt> {
  static const double _chartH = 144; // fixed height ต่อหนึ่งกราฟ
  static const double _gapV = 4;

  bool _showLegend = false;

  String _titleFromSelected(SecondChartSelected? sel, String? labelFromModel) {
    if (labelFromModel != null && labelFromModel.isNotEmpty) return labelFromModel;
    switch (sel) {
      case SecondChartSelected.cde:
        return 'CDE';
      case SecondChartSelected.cdt:
        return 'CDT';
      case SecondChartSelected.compoundLayer:
        return 'Compound Layer';
      default:
        return 'CDE/CDT';
    }
  }

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
    if (searchState.chartDataPointsCdeCdt.isEmpty) {
      return const _StateBox(child: _Empty());
    }

    final stats = searchState.controlChartStats;
    final title = _titleFromSelected(stats.selType, stats.selType?.label);

    double? _upperSpec(ControlChartStats? s) =>
        s.sel<double?>(s?.specAttribute?.cdeUpperSpec, s?.specAttribute?.cdtUpperSpec, s?.specAttribute?.compoundLayerUpperSpec);

    double? _lowerSpec(ControlChartStats? s) =>
        s.sel<double?>(s?.specAttribute?.cdeLowerSpec, s?.specAttribute?.cdtLowerSpec, s?.specAttribute?.compoundLayerLowerSpec);
    
    CapabilityProcess? _capabilityProcess(ControlChartStats? s) =>
        s.sel<CapabilityProcess?>(
          (s?.cdeCapabilityProcess?.std ?? 0) != 0 ? s?.cdeCapabilityProcess : null,
          (s?.cdtCapabilityProcess?.std ?? 0) != 0 ? s?.cdtCapabilityProcess : null,
          (s?.compoundLayerCapabilityProcess?.std ?? 0) != 0 ? s?.compoundLayerCapabilityProcess : null,
        );


    final hasSpec  = isValidSpec((_lowerSpec(stats))) || isValidSpec((_upperSpec(stats)));
    final hasSpecL = isValidSpec((_lowerSpec(stats))) && !isValidSpec((_upperSpec(stats)));
    final hasSpecU = !isValidSpec((_lowerSpec(stats))) && isValidSpec((_upperSpec(stats)));

    final capability = _capabilityProcess(stats);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min, // สำคัญเมื่ออยู่ใต้สกอลล์
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
                      chartAttribute: ChartAttribute.OTHERS,
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

        // // Legend toggle
        // AnimatedSwitcher(
        //   duration: const Duration(milliseconds: 180),
        //   child: _showLegend
        //       ? Padding(
        //           key: const ValueKey('legend-on-cde'),
        //           padding: const EdgeInsets.only(bottom: 8),
        //           child: _LegendColumnCdeCdt(searchState: searchState),
        //         )
        //       : const SizedBox.shrink(key: ValueKey('legend-off-cde')),
        // ),

        // Blue card (charts only) — same as non-CDE
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
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: _gapV),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const _SectionLabel('Control Chart'),
                    const Spacer(),

                  if (hasSpec)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        hasSpecL
                            ? 'CPL = ${capability?.cpl?.toStringAsFixed(2) ?? 'N/A'}'
                            : hasSpecU
                                ? 'CPU = ${capability?.cpu?.toStringAsFixed(2) ?? 'N/A'}'
                                : 'CP = ${capability?.cp?.toStringAsFixed(2) ?? 'N/A'} | '
                                  'CPK = ${capability?.cpk?.toStringAsFixed(2) ?? 'N/A'}',
                        style: AppTypography.textBody4BBold,
                      ),
                    ),

                  ],
                ),
                _SmallChartBoxCdeCdt(searchState: searchState, isMr: false, fixedHeight: _chartH),
                const SizedBox(height: _gapV),
                const SizedBox(height: 8),
                const _SectionLabel('Moving Range'),
                _SmallChartBoxCdeCdt(searchState: searchState, isMr: true, fixedHeight: _chartH),
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

    // เลือก violations ให้ตรงกับกราฟปัจจุบัน
    final v = () {
      switch (s?.selType) {
        case SecondChartSelected.cde:
          return s?.cdeViolations;
        case SecondChartSelected.cdt:
          return s?.cdtViolations;
        case SecondChartSelected.compoundLayer:
          return s?.compoundLayerViolations;
        default:
          return s?.surfaceHardnessViolations;
      }
    }();

    final overSpecLower    = v?.beyondSpecLimitLower ?? 0;
    final overSpecUpper    = v?.beyondSpecLimitUpper ?? 0;
    final overControlLower = v?.beyondControlLimitLower ?? 0;
    final overControlUpper = v?.beyondControlLimitUpper ?? 0;
    final trend            = v?.trend ?? 0;
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
                              _ViolationChip(label: 'Over Spec (L)', 
                              count: overSpecLower, 
                              color: Colors.red),
                              _ViolationChip(label: 'Over Spec (U)', 
                              count: overSpecUpper, 
                              color: Colors.red),
                              _ViolationChip(label: 'Over Control (L)', 
                              count: overControlLower, 
                              color: Colors.orange),
                              _ViolationChip(label: 'Over Control (U)', 
                              count: overControlUpper, 
                              color: Colors.orange),
                              _ViolationChip(label: 'Trend', 
                              count: trend, 
                              color: Colors.pinkAccent),
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

/// ============================================================================
/// Small chart box (CDE/CDT)
/// ============================================================================
class _SmallChartBoxCdeCdt extends StatelessWidget {
  const _SmallChartBoxCdeCdt({
    required this.searchState,
    required this.isMr,
    required this.fixedHeight,
  });

  final SearchState searchState;
  final bool isMr;
  final double fixedHeight;

  @override
  Widget build(BuildContext context) {
    final q = searchState.currentQuery;
    final keySeed =
        '${q.startDate?.millisecondsSinceEpoch}-${q.endDate?.millisecondsSinceEpoch}-${q.furnaceNo}-${q.materialNo}-${isMr ? 'mr' : 'i'}';

    return SizedBox(
      width: double.infinity,
      height: fixedHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ControlChartTemplateSmallCdeCdt(
          key: ValueKey(keySeed.hashCode.toString()),
          isMovingRange: isMr,
          frozenDataPoints: List<ChartDataPointCdeCdt>.from(searchState.chartDataPointsCdeCdt),
          frozenStats: searchState.controlChartStats!,
          frozenStatus: searchState.status,
          xStart: q.startDate,
          xEnd: q.endDate,
        ),
      ),
    );
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

/// ============================================================================
/// Simple states
/// ============================================================================
class _StateBox extends StatelessWidget {
  const _StateBox({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Center(child: child);
}

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) =>
      const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2));
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