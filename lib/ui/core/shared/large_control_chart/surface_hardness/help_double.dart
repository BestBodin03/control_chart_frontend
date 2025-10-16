import 'package:control_chart/data/bloc/search_chart_details/extension/search_state_extension.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/domain/models/chart_data_point.dart';
import 'package:control_chart/domain/models/setting.dart';
import 'package:control_chart/domain/types/period_duration.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';
import 'package:control_chart/ui/core/shared/medium_control_chart/surface_hardness/control_chart_template.dart';
import 'package:control_chart/ui/core/shared/violation_for_dashboard.dart';
import 'package:control_chart/ui/core/shared/violations_component.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../fg_last_four_chars.dart';
import '../../spec_validation.dart';
import '../../violation_specific_card.dart';

/// ✅ FIXED — removed SizedBox.expand (caused overflow)
Widget buildChartsSectionSurfaceHardnessLargeDouble(
  SearchState searchState, {
  int? externalStart,
  int? externalWindowSize,
  required double xIntervalSize,
  DateTime? windowStart,
  DateTime? windowEnd,
}) {
  return _LargeContainer(
    searchState: searchState,
    externalStart: externalStart,
    externalWindowSize: externalWindowSize,
    xIntervalSize: xIntervalSize,
    windowStart: windowStart,
    windowEnd: windowEnd,
  );
}

class _LargeContainer extends StatelessWidget {
  const _LargeContainer({
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

  @override
  Widget build(BuildContext context) {
    final state = searchState;

    final violations = state.controlChartStats?.surfaceHardnessViolations;
    final bgColor = _getViolationBgColor(
      violations?.beyondControlLimitLower ?? 0,
      violations?.beyondControlLimitUpper ?? 0,
      violations?.beyondSpecLimitLower ?? 0,
      violations?.beyondSpecLimitUpper ?? 0,
      violations?.trend ?? 0,
    );
    final borderColor = _getViolationBorderColor(
      violations?.beyondControlLimitLower ?? 0,
      violations?.beyondControlLimitUpper ?? 0,
      violations?.beyondSpecLimitLower ?? 0,
      violations?.beyondSpecLimitUpper ?? 0,
      violations?.trend ?? 0,
    );

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
      color: AppColors.colorBg,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;

          final combineControlLimit =
              (violations?.beyondControlLimitLower ?? 0) + (violations?.beyondControlLimitUpper ?? 0);
          final combineSpecLimit =
              (violations?.beyondSpecLimitLower ?? 0) + (violations?.beyondSpecLimitUpper ?? 0);

          final lowerSpec = searchState.controlChartStats?.specAttribute?.surfaceHardnessLowerSpec;
          final upperSpec = searchState.controlChartStats?.specAttribute?.surfaceHardnessUpperSpec;
          final hasSpec = isValidSpec(lowerSpec) || isValidSpec(upperSpec);
          final hasSpecL = isValidSpec(lowerSpec) && !isValidSpec(upperSpec);
          final hasSpecU = !isValidSpec(lowerSpec) && isValidSpec(upperSpec);
          final spotCount = state.controlChartStats?.numberOfSpots;

          // ---- Left info panel ----
          final leftPanel = ConstrainedBox(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.35),
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
              child:  Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Surface Hardness", style: AppTypography.textBody3BBold),
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
                                          'CPL = ${searchState.controlChartStats?.surfaceHardnessCapabilityProcess?.cpl?.toStringAsFixed(2) ?? 'N/A'}',
                                          style: AppTypography.textBody3BBold,
                                        )
                                      else if (hasSpecU)
                                        Text(
                                          'CPU = ${searchState.controlChartStats?.surfaceHardnessCapabilityProcess?.cpu?.toStringAsFixed(2) ?? 'N/A'}',
                                          style: AppTypography.textBody3BBold,
                                        )
                                      else ...[
                                        Text(
                                          'CP = ${searchState.controlChartStats?.surfaceHardnessCapabilityProcess?.cp?.toStringAsFixed(2) ?? 'N/A'}',
                                          style: AppTypography.textBody3BBold,
                                        ),
                                        Text(
                                          'CPK = ${searchState.controlChartStats?.surfaceHardnessCapabilityProcess?.cpk?.toStringAsFixed(2) ?? 'N/A'}',
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
                    padding: const EdgeInsets.only(top: 4.0),
                    child: ViolationSpecificQueueCard(
                        violations: _buildViolationsFromState(searchState),
                      ),
                  ),
                  
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
                            width: 280,
                          child: ViolationsColumn(
                            combinedControlLimit: combineControlLimit,
                            combinedSpecLimit: combineSpecLimit,
                            trend: violations?.trend ?? 0,
                            overCtrlLower: violations?.beyondControlLimitLower ?? 0,
                            overCtrlUpper: violations?.beyondControlLimitUpper ?? 0,
                            overSpecLower: violations?.beyondSpecLimitLower ?? 0,
                            overSpecUpper: violations?.beyondSpecLimitUpper ?? 0,
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

          // ---- Charts area ----
          final chartsExpanded = Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: bgColor,
                border: Border.all(color: borderColor, width: 1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: _ChartsStack(
                  state: state,
                  windowStart: windowStart,
                  windowEnd: windowEnd,
                ),
              ),
            ),
          );

          // ---- Layout ----
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
}

/// ===== chart stack remains the same =====
class _ChartsStack extends StatelessWidget {
  const _ChartsStack({
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
        final allPoints = state.chartDataPoints;

        final effectiveStart = windowStart ?? state.currentQuery.startDate;
        final effectiveEnd = windowEnd ?? state.currentQuery.endDate;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Control Chart", style: AppTypography.textBody3B),
              const SizedBox(height: 8),
              _buildSingleChart(
                searchState: state,
                height: eachChartH,
                visiblePoints: allPoints,
                isMovingRange: false,
                xStartOverride: effectiveStart,
                xEndOverride: effectiveEnd,
              ),
              const SizedBox(height: 8),
              Text("Moving Range", style: AppTypography.textBody3B),
              const SizedBox(height: 8),
              _buildSingleChart(
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

Widget _buildSingleChart({
  required SearchState searchState,
  required bool isMovingRange,
  required double height,
  required List<ChartDataPoint> visiblePoints,
  DateTime? xStartOverride,
  DateTime? xEndOverride,
}) {
  final allPoints = searchState.chartDataPoints;
  final q = searchState.currentQuery;
  final xStart = xStartOverride ?? q.startDate;
  final xEnd = xEndOverride ?? q.endDate;

  final uniqueKey =
      '${xStart?.millisecondsSinceEpoch}-${xEnd?.millisecondsSinceEpoch}-${q.furnaceNo}-${q.materialNo}-';

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
          frozenDataPoints: List<ChartDataPoint>.from(allPoints),
          frozenStats: searchState.controlChartStats!,
          frozenStatus: searchState.status,
          xStart: xStart,
          xEnd: xEnd,
        ),
      ),
    ),
  );
}

/// === helpers ===
Color _getViolationBgColor(int a, int b, int c, int d, int e) {
  if (d > 0 || c > 0) return Colors.red.withValues(alpha: 0.15);
  if (b > 0 || a > 0) return Colors.orange.withValues(alpha: 0.15);
  if (e > 0) return Colors.pink.withValues(alpha: 0.15);
  return AppColors.colorBrandTp.withValues(alpha: 0.15);
}

Color _getViolationBorderColor(int a, int b, int c, int d, int e) {
  if (d > 0 || c > 0) return Colors.red.withValues(alpha: 0.70);
  if (b > 0 || a > 0) return Colors.orange.withValues(alpha: 0.70);
  if (e > 0) return Colors.pinkAccent.withValues(alpha: 0.70);
  return AppColors.colorBrandTp.withValues(alpha: 0.70);
}

List<ViolationItem> _buildViolationsFromState(SearchState state) {
  final spots = state.controlChartStats?.controlChartSpots?.surfaceHardness ?? [];
  final violations = <ViolationItem>[];
  for (final s in spots) {
    if (s.isViolatedR1BeyondLCL == true) {
      violations.add(ViolationItem(fgNo: fgNoLast4(s.fgNo), value: s.value ?? 0, type: "Over Control (L)", color: Colors.orange));
    }
    if (s.isViolatedR1BeyondUCL == true) {
      violations.add(ViolationItem(fgNo: fgNoLast4(s.fgNo), value: s.value ?? 0, type: "Over Control (U)", color: Colors.orange));
    }
    if (s.isViolatedR1BeyondLSL == true) {
      violations.add(ViolationItem(fgNo: fgNoLast4(s.fgNo), value: s.value ?? 0, type: "Over Spec (L)", color: Colors.red));
    }
    if (s.isViolatedR1BeyondUSL == true) {
      violations.add(ViolationItem(fgNo: fgNoLast4(s.fgNo), value: s.value ?? 0, type: "Over Spec (U)", color: Colors.red));
    }
  }
  return violations;
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
