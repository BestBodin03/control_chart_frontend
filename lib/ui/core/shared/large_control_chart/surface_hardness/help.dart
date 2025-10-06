import 'package:control_chart/data/bloc/search_chart_details/extension/search_state_extension.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/domain/models/chart_data_point.dart';
// import 'package:control_chart/domain/models/setting.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';
import 'package:control_chart/ui/core/shared/medium_control_chart/surface_hardness/control_chart_template.dart';
import 'package:flutter/material.dart';

Widget buildChartsSectionSurfaceHardnessLarge(
  // List<HomeContentVar> profiles,
  // int currentIndex,
 SearchState searchState
 ) {

  final current = searchState.currentQuery;
  final isReady = searchState.status == SearchStatus.success &&
                searchState.chartDetails.isNotEmpty;
  final partName = isReady
    ? (searchState.chartDetails.first.chartGeneralDetail.partName)
    : '-';
  final title =
      "Furnace ${current.furnaceNo ?? "-"} "
      " | $partName - ${current.materialNo ?? '-'}"
      " | Date ${(current.startDate)} - ${(current.endDate)}";

      // "Furnace ${current.furnaceNo ?? "-"} "
      // " | Material ${current.materialNo ?? '-'}"
      // " | Date ${fmtDate(current.startDate)} - ${fmtDate(current.endDate)}";

  return SizedBox.expand(
    child: _LargeContainer(
      title: title,
      // settingProfile: current,
      searchState: searchState,
    ),
  );
}

class _LargeContainer extends StatefulWidget {
  const _LargeContainer({
    required this.title,
    // required this.settingProfile,
    required this.searchState,
    // required this.onZoom,
  });

  final String title;
  // final HomeContentVar settingProfile;
  final SearchState searchState;
  // final void Function(BuildContext) onZoom;

  @override
  State<_LargeContainer> createState() => _LargeContainerState();
}

class _LargeContainerState extends State<_LargeContainer> {
  static const int _windowSize = 24;
  int _start = 0;          // inclusive
  int _maxStart = 0;       // max value for _start
  bool _sliderOpen = false;

  @override
  void initState() {
    super.initState();
    _recomputeWindow();
  }

  @override
  void didUpdateWidget(covariant _LargeContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchState.chartDataPoints.length !=
        widget.searchState.chartDataPoints.length) {
      _recomputeWindow();
    }
  }

  void _recomputeWindow() {
    final n = widget.searchState.chartDataPoints.length;
    if (n <= _windowSize) {
      _start = 0;
      _maxStart = 0;
    } else {
      _maxStart = n - _windowSize;
      // default: latest window
      _start = _maxStart;
    }
    setState(() {});
  }

  List<T> _slice<T>(List<T> full) {
    if (full.length <= _windowSize) return full;
    final end = (_start + _windowSize).clamp(0, full.length);
    return full.sublist(_start, end);
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.searchState;
    final canSlide = state.chartDataPoints.length > _windowSize;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalH = constraints.maxHeight;
        const outerPadTop = 8.0, outerPadBottom = 8.0;
        const titleH = 24.0, sectionLabelH = 20.0, gapV = 8.0;

        final chartsAreaH = (totalH
                - outerPadTop - outerPadBottom
                - titleH - gapV - 8.0
                - sectionLabelH - gapV
                - sectionLabelH - 8.0)
            .clamp(0.0, double.infinity);
        final eachChartH = (chartsAreaH / 2).clamp(0.0, double.infinity);

        // windowed (visible) data used by both charts
        final visiblePoints = _slice(state.chartDataPoints);

        return Container(
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row + actions (zoom + slider toggle / slider)
              // Padding(
              //   padding: const EdgeInsets.only(bottom: 8)
              // ),
          
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
                    // padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: Column(
                      children: [
                        // Control Chart header (centered)
                        Row(
                          children: [
                            // const SizedBox(width: 20),
                            Expanded(
                              child: Center(
                                child: Text(
                                  "Surface Hardness | Control Chart",
                                  style: AppTypography.textBody3B,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                          ],
                        ),
          
                        _buildSingleChart(
                          // settingProfile: widget.searchState,
                          searchState: state,
                          height: eachChartH,
                          isMovingRange: false,
                          // pass same window to control both charts
                          visiblePoints: visiblePoints,
                        ),
          
                        const SizedBox(height: 8),
          
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            "Surface Hardness | Moving Range",
                            style: AppTypography.textBody3B,
                          ),
                        ),
                        _buildMrChart(
                          // settingProfile: widget.settingProfile,
                          searchState: state,
                          height: eachChartH,
                          isMovingRange: true,
                          visiblePoints: visiblePoints,
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
}

Widget _buildSingleChart({
  // required HomeContentVar settingProfile,
  required SearchState searchState,
  required bool isMovingRange,
  required double height,
  required List<dynamic> visiblePoints, // List<ChartDataPoint>
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

  final q = searchState.currentQuery;
  final uniqueKey = '${q.startDate?.millisecondsSinceEpoch}-'
      '${q.endDate?.millisecondsSinceEpoch}-'
      '${q.furnaceNo}-'
      '${q.materialNo}-';

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
          // 🔒 freeze the same window for both charts
          frozenDataPoints: List<ChartDataPoint>.from(visiblePoints),
          frozenStats: searchState.controlChartStats,
          frozenStatus: searchState.status,
        ),
      ),
    ),
  );
}

Widget _buildMrChart({
  // required HomeContentVar settingProfile,
  required SearchState searchState,
  required bool isMovingRange,
  required double height,
  required List<dynamic> visiblePoints, // List<ChartDataPoint>
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

  final q = searchState.currentQuery;
  final uniqueKey = '${q.startDate?.millisecondsSinceEpoch}-'
      '${q.endDate?.millisecondsSinceEpoch}-'
      '${q.furnaceNo}-'
      '${q.materialNo}-';

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
          // 🔒 same window slice
          frozenDataPoints: List<ChartDataPoint>.from(visiblePoints),
          frozenStats: searchState.controlChartStats,
          frozenStatus: searchState.status,
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
      const Center(child: Text('No Data', style: TextStyle(fontSize: 12, color: Colors.grey)));
}