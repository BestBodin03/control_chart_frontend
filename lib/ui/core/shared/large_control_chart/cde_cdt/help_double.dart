import 'package:control_chart/data/bloc/search_chart_details/extension/search_state_extension.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/domain/models/chart_data_point.dart';
import 'package:control_chart/domain/models/control_chart_stats.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';
import 'package:control_chart/ui/core/shared/medium_control_chart/surface_hardness/control_chart_template.dart';
import 'package:control_chart/ui/core/shared/violations_component.dart';
import 'package:control_chart/utils/app_route.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../fg_last_four_chars.dart';
import '../../spec_validation.dart';
import '../../violation_for_dashboard.dart';
import '../../violation_specific_card.dart';
import 'control_chart_template.dart';

/// ------------------------------------------------------------
/// CDE/CDT/Compound — Large (same props/UX as Surface Hardness)
/// ------------------------------------------------------------
Widget buildChartsSectionCdeCdtLargeDouble(
  SearchState searchState, {
  int? externalStart,
  int? externalWindowSize,
  required double xIntervalSize,
  DateTime? windowStart,
  DateTime? windowEnd,
}) {
  final sel = searchState.controlChartStats?.secondChartSelected;
  if (sel == null || sel == SecondChartSelected.na) {
    // ไม่เลือก series ก็ไม่แสดง
    return const SizedBox.shrink();
  }

  // ✅ Removed SizedBox wrapper (caused unbounded height)
  return _LargeContainerCdeCdt(
    searchState: searchState,
    externalStart: externalStart,
    externalWindowSize: externalWindowSize,
    xIntervalSize: xIntervalSize,
    windowStart: windowStart,
    windowEnd: windowEnd,
  );
}

class _LargeContainerCdeCdt extends StatelessWidget {
  const _LargeContainerCdeCdt({
    required this.searchState,
    this.externalStart,
    this.externalWindowSize,
    required this.xIntervalSize,
    this.windowStart,
    this.windowEnd,
  });

  final SearchState searchState;
  final int? externalStart;
  final int? externalWindowSize;
  final double xIntervalSize;
  final DateTime? windowStart;
  final DateTime? windowEnd;

  // ----- helper: select value by current secondChartSelected -----
  T? _sel<T>(T? cde, T? cdt, T? comp) {
    switch (searchState.controlChartStats?.secondChartSelected) {
      case SecondChartSelected.cde:
        return cde;
      case SecondChartSelected.cdt:
        return cdt;
      case SecondChartSelected.compoundLayer:
        return comp;
      default:
        return null;
    }
  }

  String _selectedLabel() {
    switch (searchState.controlChartStats?.secondChartSelected) {
      case SecondChartSelected.cde:
        return 'CDE';
      case SecondChartSelected.cdt:
        return 'CDT';
      case SecondChartSelected.compoundLayer:
        return 'Compound Layer';
      default:
        return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = searchState;

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

    final stats = state.controlChartStats!;
    final q = state.currentQuery;

    final xStart = windowStart ?? q.startDate;
    final xEnd = windowEnd ?? q.endDate;

    final List<String> parts = [];
    if (q.furnaceNo != null) parts.add('Furnace ${q.furnaceNo}');
    final partName = state.chartDetails.first.chartGeneralDetail.partName?.trim();
    final mat = q.materialNo?.toString() ?? '';
    if ((partName ?? '').isNotEmpty) {
      parts.add('$partName - $mat');
    } else if (mat.isNotEmpty) {
      parts.add(mat);
    }
    if (xStart != null && xEnd != null) {
      parts.add('Date ${DateFormat('dd/MM').format(xStart)} - ${DateFormat('dd/MM').format(xEnd)}');
    }

    final allPoints = state.chartDataPointsCdeCdt;
    final spotCount = allPoints.length;

    // ---------- violations ----------
    final int vOverCtrlL = _sel<int?>(
          stats.cdeViolations?.beyondControlLimitLower,
          stats.cdtViolations?.beyondControlLimitLower,
          stats.compoundLayerViolations?.beyondControlLimitLower,
        ) ??
        0;

    final int vOverCtrlU = _sel<int?>(
          stats.cdeViolations?.beyondControlLimitUpper,
          stats.cdtViolations?.beyondControlLimitUpper,
          stats.compoundLayerViolations?.beyondControlLimitUpper,
        ) ??
        0;

    final int vOverSpecL = _sel<int?>(
          stats.cdeViolations?.beyondSpecLimitLower,
          stats.cdtViolations?.beyondSpecLimitLower,
          stats.compoundLayerViolations?.beyondSpecLimitLower,
        ) ??
        0;

    final int vOverSpecU = _sel<int?>(
          stats.cdeViolations?.beyondSpecLimitUpper,
          stats.cdtViolations?.beyondSpecLimitUpper,
          stats.compoundLayerViolations?.beyondSpecLimitUpper,
        ) ??
        0;

    final int vTrend = _sel<int?>(
          stats.cdeViolations?.trend,
          stats.cdtViolations?.trend,
          stats.compoundLayerViolations?.trend,
        ) ??
        0;

    final bgColor = getViolationBgColor(vOverCtrlL, vOverCtrlU, vOverSpecL, vOverSpecU, vTrend);
    final borderColor = getViolationBorderColor(vOverCtrlL, vOverCtrlU, vOverSpecL, vOverSpecU, vTrend);

    double? _upperSpec() => _sel<double?>(
          stats.specAttribute?.cdeUpperSpec,
          stats.specAttribute?.cdtUpperSpec,
          stats.specAttribute?.compoundLayerUpperSpec,
        );

    double? _lowerSpec() => _sel<double?>(
          stats.specAttribute?.cdeLowerSpec,
          stats.specAttribute?.cdtLowerSpec,
          stats.specAttribute?.compoundLayerLowerSpec,
        );

    CapabilityProcess? _capability() => _sel<CapabilityProcess?>(
          (stats.cdeCapabilityProcess?.std ?? 0) != 0 ? stats.cdeCapabilityProcess : null,
          (stats.cdtCapabilityProcess?.std ?? 0) != 0 ? stats.cdtCapabilityProcess : null,
          (stats.compoundLayerCapabilityProcess?.std ?? 0) != 0
              ? stats.compoundLayerCapabilityProcess
              : null,
        );

    final hasSpec = isValidSpec(_lowerSpec()) || isValidSpec(_upperSpec());
    final hasSpecL = isValidSpec(_lowerSpec()) && !isValidSpec(_upperSpec());
    final hasSpecU = !isValidSpec(_lowerSpec()) && isValidSpec(_upperSpec());

    return Container(
      color: AppColors.colorBg,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;

          // LEFT info panel (unchanged)
          final Widget leftPanel = SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.colorBg,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.colorBrandTp.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_selectedLabel(), style: AppTypography.textBody3BBold),
                        const SizedBox(height: 4),
                        Text('$spotCount Records', style: AppTypography.textBody3BBold),
                        const SizedBox(height: 8),
                        if (hasSpec)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(width: 1, color: Colors.grey.shade500),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (hasSpecL)
                                      Text(
                                        'CPL = ${_capability()?.cpl?.toStringAsFixed(2) ?? 'N/A'}',
                                        style: AppTypography.textBody3BBold,
                                      )
                                    else if (hasSpecU)
                                      Text(
                                        'CPU = ${_capability()?.cpu?.toStringAsFixed(2) ?? 'N/A'}',
                                        style: AppTypography.textBody3BBold,
                                      )
                                    else ...[
                                      Text(
                                        'CP = ${_capability()?.cp?.toStringAsFixed(2) ?? 'N/A'}',
                                        style: AppTypography.textBody3BBold,
                                      ),
                                      Text(
                                        'CPK = ${_capability()?.cpk?.toStringAsFixed(2) ?? 'N/A'}',
                                        style: AppTypography.textBody3BBold,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: ViolationSpecificQueueCard(
                        violations: buildViolationsFromStateCdeCdt(searchState),
                      ),
                  ),
                  
                  // const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.colorBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(width: 1, color: Colors.grey.shade500),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.colorBg.withValues(alpha: 0.4),
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: SizedBox(
                            width: 264,
                            child: ViolationsColumn(
                              combinedControlLimit: vOverCtrlL + vOverCtrlU,
                              combinedSpecLimit: vOverSpecL + vOverSpecU,
                              trend: vTrend,
                              overCtrlLower: vOverCtrlL,
                              overCtrlUpper: vOverCtrlU,
                              overSpecLower: vOverSpecL,
                              overSpecUpper: vOverSpecU,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );

          // RIGHT chart area
          final Widget chartsExpanded = Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: bgColor,
                border: Border.all(color: borderColor, width: 1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: _ChartsStackCdeCdt(
                  state: state,
                  windowStart: windowStart,
                  windowEnd: windowEnd,
                ),
              ),
            ),
          );

          if (wide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                leftPanel,
                const SizedBox(width: 16),
                chartsExpanded,
              ],
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                leftPanel,
                const SizedBox(height: 16),
                chartsExpanded,
              ],
            );
          }
        },
      ),
    );
  }

  Color getViolationBgColor(
    int overControlLower,
    int overControlUpper,
    int overSpecLower,
    int overSpecUpper,
    int trend,
  ) {
    if (overSpecUpper > 0 || overSpecLower > 0) {
      return Colors.red.withValues(alpha: 0.15);
    } else if (overControlUpper > 0 || overControlLower > 0) {
      return Colors.orange.withValues(alpha: 0.15);
    } else if (trend > 0) {
      return Colors.pink.withValues(alpha: 0.15);
    }
    return AppColors.colorBrandTp.withValues(alpha: 0.15);
  }

  Color getViolationBorderColor(
    int overControlLower,
    int overControlUpper,
    int overSpecLower,
    int overSpecUpper,
    int trend,
  ) {
    if (overSpecUpper > 0 || overSpecLower > 0) {
      return Colors.red.withValues(alpha: 0.70);
    } else if (overControlUpper > 0 || overControlLower > 0) {
      return Colors.orange.withValues(alpha: 0.70);
    } else if (trend > 0) {
      return Colors.pinkAccent.withValues(alpha: 0.70);
    }
    return AppColors.colorBrandTp.withValues(alpha: 0.70);
  }

  List<ViolationItem> buildViolationsFromStateCdeCdt(SearchState state) {
    final sel = state.controlChartStats?.secondChartSelected;
    if (sel == null) return [];

    final spots = switch (sel) {
      SecondChartSelected.cde => state.controlChartStats?.controlChartSpots?.cde ?? [],
      SecondChartSelected.cdt => state.controlChartStats?.controlChartSpots?.cdt ?? [],
      SecondChartSelected.compoundLayer =>
        state.controlChartStats?.controlChartSpots?.compoundLayer ?? [],
      _ => <dynamic>[],
    };

    final List<ViolationItem> violations = [];
    for (final s in spots) {
      if (s.isViolatedR1BeyondLCL == true) {
        violations.add(ViolationItem(
          fgNo: fgNoLast4(s.fgNo),
          value: s.value ?? 0,
          type: "Over Control (L)",
          color: Colors.orange,
        ));
      }
      if (s.isViolatedR1BeyondUCL == true) {
        violations.add(ViolationItem(
          fgNo: fgNoLast4(s.fgNo),
          value: s.value ?? 0,
          type: "Over Control (U)",
          color: Colors.orange,
        ));
      }
      if (s.isViolatedR1BeyondLSL == true) {
        violations.add(ViolationItem(
          fgNo: fgNoLast4(s.fgNo),
          value: s.value ?? 0,
          type: "Over Spec (L)",
          color: Colors.red,
        ));
      }
      if (s.isViolatedR1BeyondUSL == true) {
        violations.add(ViolationItem(
          fgNo: fgNoLast4(s.fgNo),
          value: s.value ?? 0,
          type: "Over Spec (U)",
          color: Colors.red,
        ));
      }
    }
    return violations;
  }
}

class _ChartsStackCdeCdt extends StatelessWidget {
  const _ChartsStackCdeCdt({
    required this.state,
    this.windowStart,
    this.windowEnd,
  });

  final SearchState state;
  final DateTime? windowStart;
  final DateTime? windowEnd;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final eachChartH = ((c.maxHeight - 16 - 48) / 2).clamp(180.0, double.infinity);
        final allPoints = state.chartDataPointsCdeCdt;

        final effectiveStart = windowStart ?? state.currentQuery.startDate;
        final effectiveEnd = windowEnd ?? state.currentQuery.endDate;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text("Control Chart", style: AppTypography.textBody3B),
              ),
              const SizedBox(height: 8),
              _buildSingleChartCdeCdt(
                searchState: state,
                height: eachChartH,
                visiblePoints: allPoints,
                isMovingRange: false,
                xStartOverride: effectiveStart,
                xEndOverride: effectiveEnd,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text("Moving Range", style: AppTypography.textBody3B),
              ),
              const SizedBox(height: 8),
              _buildSingleChartCdeCdt(
                searchState: state,
                height: eachChartH,
                visiblePoints: allPoints,
                isMovingRange: true,
                xStartOverride: effectiveStart,
                xEndOverride: effectiveEnd,
              ),
            ],
          ),
        );
      },
    );
  }
}

Widget _buildSingleChartCdeCdt({
  required SearchState searchState,
  required bool isMovingRange,
  required double height,
  required List<ChartDataPointCdeCdt> visiblePoints,
  DateTime? xStartOverride,
  DateTime? xEndOverride,
}) {
  final allPoints = searchState.chartDataPointsCdeCdt;
  final q = searchState.currentQuery;

  final xStart = xStartOverride ?? q.startDate;
  final xEnd = xEndOverride ?? q.endDate;

  return SizedBox(
    width: double.infinity,
    height: height,
    child: DecoratedBox(
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: ControlChartTemplateCdeCdtLarge(
          isMovingRange: isMovingRange,
          height: height,
          frozenDataPoints: List<ChartDataPointCdeCdt>.from(allPoints),
          frozenStats: searchState.controlChartStats!,
          frozenStatus: searchState.status,
          xStart: xStart,
          xEnd: xEnd,
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
