import 'package:control_chart/data/bloc/search_chart_details/extension/search_state_extension.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/domain/models/chart_data_point.dart';
import 'package:control_chart/domain/models/control_chart_stats.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';
import 'package:control_chart/ui/core/shared/common/chart/medium_chart_size_scaler.dart';
import 'package:control_chart/ui/core/shared/common/chart/size_scaler.dart';
import 'package:control_chart/ui/core/shared/violations_component.dart';
import 'package:control_chart/ui/screen/screen_content/home_screen_content/home_content_var.dart';
import 'package:control_chart/utils/app_route.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:control_chart/ui/core/shared/chart_selection.dart';
import '../../common/chart/font_scaler.dart';
import '../../fg_last_four_chars.dart';
import '../../spec_validation.dart';
import '../../violation_specific_card.dart';
import 'control_chart_template.dart';

typedef CdeCdtZoomBuilder = Widget Function(
  BuildContext context,
  HomeContentVar settingProfile,
  SearchState searchState,
);

Widget buildChartsSectionCdeCdt(
  List<HomeContentVar> profiles,
  int currentIndex,
  SearchState searchState, {
  int? externalStart,
  int? externalWindowSize,
  int? xAxisStart,
  int? xAxisWinSize,
  DateTime? baseStart,
  DateTime? baseEnd,
}) {
  final sel = searchState.controlChartStats?.secondChartSelected;
  if (sel == null || sel == SecondChartSelected.na) {
    return const SizedBox.shrink();
  }

  final selectedLabel = switch (sel) {
    SecondChartSelected.cde => 'CDE',
    SecondChartSelected.cdt => 'CDT',
    SecondChartSelected.compoundLayer => 'Compound Layer',
    _ => '-',
  };

  final current = profiles[currentIndex];
  final bool isReady =
      searchState.status == SearchStatus.success &&
      searchState.chartDetails.isNotEmpty;

  final List<String> parts = [];

  // Furnace
  if (current.furnaceNo != null) {
    parts.add('Furnace ${current.furnaceNo}');
  }

  // Material
  if (isReady && current.materialNo != null) {
    final partName = searchState.chartDetails.first.chartGeneralDetail.partName?.trim();
    final mat = current.materialNo!;
    parts.add((partName != null && partName.isNotEmpty) ? '$partName - $mat' : mat);
  }

  // Date range
  if (baseStart != null && baseEnd != null) {
    parts.add('Date ${DateFormat('dd/MM').format(baseStart)} - ${DateFormat('dd/MM').format(baseEnd)}');
  }

  final title = parts.join(' | ');

  return  _MediumContainerCdeCdt(
      title: title,
      selectedLabel: selectedLabel,
      settingProfile: current,
      searchState: searchState,
      currentIndex: currentIndex,
  );
}

class _MediumContainerCdeCdt extends StatelessWidget {
  const _MediumContainerCdeCdt({
    required this.title,
    required this.selectedLabel,
    required this.settingProfile,
    required this.searchState,
    this.currentIndex,
  });

  final String title;
  final String selectedLabel;
  final HomeContentVar settingProfile;
  final SearchState searchState;
  final int? currentIndex;

  T? _sel<T>(T? comp, T? cde, T? cdt) {
    switch (searchState.controlChartStats?.secondChartSelected) {
      case SecondChartSelected.compoundLayer:
        return comp;
      case SecondChartSelected.cde:
        return cde;
      case SecondChartSelected.cdt:
        return cdt;
      default:
        return null;
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

    final allPoints = state.chartDataPointsCdeCdt;
    final spotCount = allPoints.length;

    final q = settingProfile;
    final uniqueKey = '${q.startDate?.millisecondsSinceEpoch ?? 0}-'
        '${q.endDate?.millisecondsSinceEpoch ?? 0}-'
        '${q.furnaceNo ?? ''}-'
        '${q.materialNo ?? ''}-';

    final xStart = q.startDate;
    final xEnd = q.endDate;

    // ---- Violation counts (selected chart only) ----
    final int vOverControl = _sel(
          (state.controlChartStats?.compoundLayerViolations?.beyondControlLimitLower ?? 0) +
              (state.controlChartStats?.compoundLayerViolations?.beyondControlLimitUpper ?? 0),
          (state.controlChartStats?.cdeViolations?.beyondControlLimitLower ?? 0) +
              (state.controlChartStats?.cdeViolations?.beyondControlLimitUpper ?? 0),
          (state.controlChartStats?.cdtViolations?.beyondControlLimitLower ?? 0) +
              (state.controlChartStats?.cdtViolations?.beyondControlLimitUpper ?? 0),
        ) ?? 0;

    final int vOverSpec = _sel(
          (state.controlChartStats?.compoundLayerViolations?.beyondSpecLimitLower ?? 0) +
              (state.controlChartStats?.compoundLayerViolations?.beyondSpecLimitUpper ?? 0),
          (state.controlChartStats?.cdeViolations?.beyondSpecLimitLower ?? 0) +
              (state.controlChartStats?.cdeViolations?.beyondSpecLimitUpper ?? 0),
          (state.controlChartStats?.cdtViolations?.beyondSpecLimitLower ?? 0) +
              (state.controlChartStats?.cdtViolations?.beyondSpecLimitUpper ?? 0),
        ) ?? 0;

    final int vTrend = _sel(
          state.controlChartStats?.compoundLayerViolations?.trend,
          state.controlChartStats?.cdeViolations?.trend,
          state.controlChartStats?.cdtViolations?.trend,
        ) ?? 0;

    final int vUpperControl = _sel(
          state.controlChartStats?.compoundLayerViolations?.beyondControlLimitUpper,
          state.controlChartStats?.cdeViolations?.beyondControlLimitUpper,
          state.controlChartStats?.cdtViolations?.beyondControlLimitUpper,
        ) ?? 0;

    final int vLowerControl = _sel(
          state.controlChartStats?.compoundLayerViolations?.beyondControlLimitLower,
          state.controlChartStats?.cdeViolations?.beyondControlLimitLower,
          state.controlChartStats?.cdtViolations?.beyondControlLimitLower,
        ) ?? 0;

    final int vUpperSpec = _sel(
          state.controlChartStats?.compoundLayerViolations?.beyondSpecLimitUpper,
          state.controlChartStats?.cdeViolations?.beyondSpecLimitUpper,
          state.controlChartStats?.cdtViolations?.beyondSpecLimitUpper,
        ) ?? 0;

    final int vLowerSpec = _sel(
          state.controlChartStats?.compoundLayerViolations?.beyondSpecLimitLower,
          state.controlChartStats?.cdeViolations?.beyondSpecLimitLower,
          state.controlChartStats?.cdtViolations?.beyondSpecLimitLower,
        ) ?? 0;

    final bgColor = _getViolationBgColor(vLowerSpec, vUpperSpec, vLowerControl, vUpperControl, vTrend);
    final borderColor = _getViolationBorderColor(vLowerSpec, vUpperSpec, vLowerControl, vUpperControl, vTrend);

    const sectionLabelH = 20.0;
    const gapV = 8.0;
    final stats = searchState.controlChartStats;

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


    return Container(
      color: Colors.transparent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final eachChartH = ((constraints.maxHeight - (sectionLabelH + gapV)
           * 2 - mediumChartSizeScaler(context)) / 2 + 6)
              .clamp(0.0, double.infinity);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row (InkWell navigation like Surface)
              Row(
                children: [
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          final snap = HomeContentVar(
                            startDate: settingProfile.startDate,
                            endDate: settingProfile.endDate,
                            furnaceNo: settingProfile.furnaceNo,
                            materialNo: settingProfile.materialNo,
                          );
                          AppRoute.instance.searchSnapshot.value = snap;
                          AppRoute.instance.navIndex.value = 1;
                        },
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min, // shrink to fit contents
                            children: [
                              Text(
                                title,
                                style: AppTypography.textBody3BBold,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  '| $spotCount Records',
                                  style: AppTypography.textBody3BBold,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Card
              DecoratedBox(
                decoration: BoxDecoration(
                  color: bgColor,
                  border: Border.all(color: borderColor, width: 1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      // Header Top
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // LEFT: labels + Records chip
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(selectedLabel, style: AppTypography.textBody3BBold),
                                      Text("Control Chart", style: AppTypography.textBody3B),
                                    ],
                                  ),
                                  // Bottom: Records chip
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4.0),
                                    child: SizedBox(
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.6),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(width: 1, color: Colors.grey.shade500),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                          child: hasSpec
                                              ? Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    if (hasSpecL)
                                                      Text(
                                                        'CPL = ${_capabilityProcess(stats)?.cpl?.toStringAsFixed(2) ?? 'N/A'}',
                                                        style: AppTypography.textBody3BBold,
                                                      )
                                                    else if (hasSpecU)
                                                      Text(
                                                        'CPU = ${_capabilityProcess(stats)?.cpu?.toStringAsFixed(2) ?? 'N/A'}',
                                                        style: AppTypography.textBody3BBold,
                                                      )
                                                    else ...[
                                                      Text(
                                                        'CP = ${_capabilityProcess(stats)?.cp?.toStringAsFixed(2) ?? 'N/A'}',
                                                        style: AppTypography.textBody3BBold,
                                                      ),
                                                      Text(
                                                        'CPK = ${_capabilityProcess(stats)?.cpk?.toStringAsFixed(2) ?? 'N/A'}',
                                                        style: AppTypography.textBody3BBold,
                                                      ),
                                                    ],
                                                  ],
                                                )
                                              : null,
                                        ),
                                      ),
                                    ),
                                  )

                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: ViolationSpecificQueueCard(
                                violations: _buildViolationsFromStateCdeCdt(searchState),
                              ),
                            ),
                            // RIGHT: Violations card
                            Padding(
                              padding: const EdgeInsets.all(4),
                              child: SizedBox(
                                width: sizeScaler(context, 200, 1.4),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha:0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(width: 1, color: Colors.grey.shade500),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.colorBg.withValues(alpha:0.4),
                                        offset: const Offset(0, -2),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: ViolationsColumn(
                                      combinedControlLimit: vOverControl,
                                      combinedSpecLimit: vOverSpec,
                                      trend: vTrend,
                                      overCtrlLower: vLowerControl,
                                      overCtrlUpper: vUpperControl,
                                      overSpecLower: vLowerSpec,
                                      overSpecUpper: vUpperSpec,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Control Chart
                      SizedBox(
                        width: double.infinity,
                        height: eachChartH,
                        child: ControlChartTemplateCdeCdt(
                          key: ValueKey('${uniqueKey}_cc'),
                          isMovingRange: false,
                          height: eachChartH,
                          frozenDataPoints: List<ChartDataPointCdeCdt>.from(allPoints),
                          frozenStats: state.controlChartStats!,
                          frozenStatus: state.status,
                          xStart: xStart,
                          xEnd: xEnd,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                                Text(
                                  "Moving Range",
                                  style: AppTypography.textBody3B,
                                  textAlign: TextAlign.start,
                                ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // MR Chart
                      SizedBox(
                        width: double.infinity,
                        height: eachChartH,
                        child: ControlChartTemplateCdeCdt(
                          key: ValueKey('${uniqueKey}_mr'),
                          isMovingRange: true,
                          height: eachChartH,
                          frozenDataPoints: List<ChartDataPointCdeCdt>.from(allPoints),
                          frozenStats: state.controlChartStats!,
                          frozenStatus: state.status,
                          xStart: xStart,
                          xEnd: xEnd,
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

Color _getViolationBgColor(int overControlLower, int overControlUpper, 
int overSpecLower, int overSpecUpper, int trend) {
  if (overSpecUpper > 0 || overSpecLower > 0) {
    return Colors.red.withValues(alpha: 0.15);
    // return Colors.pink.shade200.withValues(alpha: 0.15);
  } else if (overControlUpper > 0 || overControlLower > 0) {
    return Colors.orange.withValues(alpha: 0.15);
    // return Colors.red.shade200.withValues(alpha: 0.15);
  } else if (trend > 0) {
    return Colors.pink.withValues(alpha: 0.15);
  }
  return AppColors.colorBrandTp.withValues(alpha: 0.15);
}

// Decide border color in same hierarchy
Color _getViolationBorderColor(int overControlLower, int overControlUpper, 
int overSpecLower, int overSpecUpper, int trend) {
  if (overSpecUpper > 0 || overSpecLower > 0) {
    return Colors.red.withValues(alpha: 0.70);
    // return Colors.pink.shade200.withValues(alpha: 0.15);
  } else if (overControlUpper > 0 || overControlLower > 0) {
    return Colors.orange.withValues(alpha: 0.70);
    // return Colors.red.shade200.withValues(alpha: 0.15);
  } else if (trend > 0) {
    return Colors.pinkAccent.withValues(alpha: 0.70);
  }
  return AppColors.colorBrandTp.withValues(alpha: 0.70);
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

List<ViolationItem> _buildViolationsFromStateCdeCdt(SearchState state) {
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
      violations.add(ViolationItem(fgNo: fgNoLast4(s.fgNo), value: s.value ?? 0,
          type: "Over Control (L)", color: Colors.orange));
    }
    if (s.isViolatedR1BeyondUCL == true) {
      violations.add(ViolationItem(fgNo: fgNoLast4(s.fgNo), value: s.value ?? 0,
          type: "Over Control (U)", color: Colors.orange));
    }
    if (s.isViolatedR1BeyondLSL == true) {
      violations.add(ViolationItem(fgNo: fgNoLast4(s.fgNo), value: s.value ?? 0,
          type: "Over Spec (L)", color: Colors.red));
    }
    if (s.isViolatedR1BeyondUSL == true) {
      violations.add(ViolationItem(fgNo: fgNoLast4(s.fgNo), value: s.value ?? 0,
          type: "Over Spec (U)", color: Colors.red));
    }
  }
  return violations;
}

class _SmallNoData extends StatelessWidget {
  const _SmallNoData();
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('ไม่มีข้อมูลสำหรับแสดงผล', style: TextStyle(fontSize: 12, color: Colors.grey)));
}