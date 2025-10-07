import 'package:control_chart/apis/settings/setting_apis.dart';
import 'package:control_chart/domain/types/chart_atrribute.dart';
import 'package:control_chart/domain/types/period_duration.dart';
import 'package:control_chart/ui/core/shared/large_control_chart/surface_hardness/help.dart';
import 'package:control_chart/ui/core/shared/searching_form_horizon.dart';
import 'package:flutter/material.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../domain/models/control_chart_stats.dart';
import '../../design_system/app_color.dart';
import '../large_control_chart/cde_cdt/help.dart';
import '../large_control_chart/cde_cdt/help_double.dart';
import '../large_control_chart/surface_hardness/help_double.dart' show buildChartsSectionSurfaceHardnessLargeDouble;
import 'display_selector.dart';

class InfoContent extends StatefulWidget {
  const InfoContent({
    super.key,
    required this.searchState,            // initial snapshot (BlocBuilder will keep it live)
    required this.chartAttribute,
    required this.selectedPeriodType,     // '1D'|'1W'|'1M'|'2M' or long forms
  });

  final SearchState searchState;
  final ChartAttribute chartAttribute;
  final String selectedPeriodType;

  @override
  State<InfoContent> createState() => _InfoContentState();
}

class _InfoContentState extends State<InfoContent> {
  // ---- slider window state ----
  int _winStart = 0;
  int _winMaxStart = 0;
  int _winSize = 7; // default visible ticks count
  bool _hasUserMovedSlider = false;
  int _chartIndex = 0; // 0 = Surface, 1 = CDE/CDT

  // Display selector values
  late String _periodShort; // '1D'|'1W'|'1M'|'2M'
  int _layout = 1;          // 1=Single, 2=Double

  @override
  void initState() {
    super.initState();
    _periodShort = _normalizeToShort(widget.selectedPeriodType);
    debugPrint('[InfoContent] initial periodShort=$_periodShort, layout=$_layout');
  }

  List<DateTime> _pointTimesFromState(SearchState st) {
  final pts = st.chartDetails;
  final list = <DateTime>[];
  for (final p in pts) {
    final t = p.chartGeneralDetail.collectedDate; // ปรับ field ให้ตรงกับโมเดลคุณ
    if (t != null) list.add(t.toUtc()); // หรือ toLocal() แต่ต้องคงที่ทั้งสองฝั่ง
  }
  list.sort();
  return list;
}


void _recalcWindow(SearchState st) {
  final times = _pointTimesFromState(st);
  final total = times.length;
  if (total == 0) { _winSize=0; _winMaxStart=0; _winStart=0; return; }

  final p = PeriodDuration.fromLabel(_periodShort);
  final spanMs = (p.milliseconds * 6).round();

  final endTs = times.last.millisecondsSinceEpoch;
  final startExclusive = endTs - spanMs;

  int inWindow = 0;
  for (int i = total - 1; i >= 0; i--) {
    final ts = times[i].millisecondsSinceEpoch;
    if (ts > startExclusive) inWindow++; else break;
  }

  _winSize = inWindow.clamp(1, total);
  _winMaxStart = (total - _winSize).clamp(0, total);
  if (!_hasUserMovedSlider) _winStart = _winMaxStart;
  _winStart = _winStart.clamp(0, _winMaxStart);

  debugPrint('[win] total=$total span=$spanMs inWindow=$inWindow winSize=$_winSize start=$_winStart maxStart=$_winMaxStart');
}


  (DateTime?, DateTime?) _currentWindowRange(SearchState st) {
    final labels = _pointTimesFromState(st);
    if (labels.isEmpty) return (null, null);
    final s = _winStart.clamp(0, labels.length - 1);
    final e = (_winStart + _winSize - 1).clamp(0, labels.length - 1);
    return (labels[s], labels[e]);
  }

  String _formatDateRange(DateTime? a, DateTime? b) {
    final df = DateFormat('d MMM');
    final left = (a != null) ? df.format(a) : '';
    final right = (b != null) ? df.format(b) : '';
    return '$left - $right';
  }

  // ---- DisplaySelector helpers ----
  String _normalizeToShort(String s) {
    final l = s.trim().toLowerCase();
    if (l == '1d' || l == '1 day' || l == '1 days') return '1D';
    if (l == '1w' || l == '1 week' || l == '7d' || l == '7 days') return '1W';
    if (l == '1m' || l == '1 month' || l == '30d' || l == '30 days') return '1M';
    if (l == '2m' || l == '2 months' || l == '60d' || l == '60 days') return '2M';
    return '1W';
  }

  double _xIntervalFromShort(String shortCode) {
    const dayMs = 24 * 60 * 60 * 1000.0;
    switch (shortCode) {
      case '1D': return 1 * dayMs;
      case '1W': return 7 * dayMs;
      case '1M': return 30 * dayMs;
      case '2M': return 60 * dayMs;
      default:   return 7 * dayMs;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingApis = SettingApis();

    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, searchState) {
        _recalcWindow(searchState);
        final (left, right) = _currentWindowRange(searchState);

        // xInterval driven by DisplaySelector
        final xIntervalSize = _xIntervalFromShort(_periodShort);
        debugPrint('[InfoContent] xInterval from period=$_periodShort → $xIntervalSize ms, layout=$_layout');

        final labelText = _formatDateRange(left, right);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- Header ----------
            Row(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 200),
                  child: DisplaySelector(
                    initialPeriod: _periodShort, // '1D'|'1W'|'1M'|'2M'
                    initialLayout: _layout,      // 1 or 2
                    onPeriodChanged: (short) {
                      setState(() => _periodShort = short);
                      debugPrint('[InfoContent] onPeriodChanged → $short');
                    },
                    onLayoutChanged: (screens) {
                      setState(() => _layout = screens);
                      debugPrint('[InfoContent] onLayoutChanged → $screens');
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(child: SearchingFormHorizon(settingApis: settingApis)),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.cancel_rounded),
                  tooltip: 'Close',
                  color: AppColors.colorBrand,
                ),
              ],
            ),

            const SizedBox(height: 16),

Expanded(
  child: Row(
    children: [
      // ---- เนื้อหาแผงกราฟ ----
      Expanded(
        child: (_layout == 2)
            // ====== โหมด Double: โชว์สองกราฟพร้อมกัน ======
            ? Row(
                children: [
                  Expanded(
                    child: buildChartsSectionSurfaceHardnessLargeDouble(
                      searchState,
                      xIntervalSize: xIntervalSize,
                      windowStart: left,
                      windowEnd: right,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: buildChartsSectionCdeCdtLargeDouble(
                      searchState,
                      xIntervalSize: xIntervalSize,
                      windowStart: left,
                      windowEnd: right,
                    ),
                  ),
                ],
              )
            // ====== โหมด Single: สลับกราฟด้วย Next ======
            : AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, anim) => SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0.15, 0), end: Offset.zero).animate(anim),
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: (_chartIndex == 0)
                    ? KeyedSubtree(
                        key: const ValueKey('pane_surface'),
                        child: buildChartsSectionSurfaceHardnessLarge(
                          searchState,
                          xIntervalSize: xIntervalSize,
                          windowStart: left,
                          windowEnd: right,
                        ),
                      )
                    : KeyedSubtree(
                        key: const ValueKey('pane_cde_cdt'),
                        child: buildChartsSectionCdeCdtLarge(
                          searchState,
                          xIntervalSize: xIntervalSize,
                          windowStart: left,
                          windowEnd: right,
                        ),
                      ),
              ),
      ),

      const SizedBox(width: 16),

      // ---- ปุ่ม Next: ปิดและเป็นสีเทาในโหมด Double ----
      Builder(builder: (_) {
        final hasSecond = widget.searchState.controlChartStats?.secondChartSelected != null &&
            widget.searchState.controlChartStats?.secondChartSelected != SecondChartSelected.na;

        final bool disableNext = (_layout == 2) || !hasSecond;

        return Opacity(
          opacity: disableNext ? 0.4 : 1.0, // ทำให้ดูเป็นสีเทา
          child: AbsorbPointer(              // กันการกดจริงๆ
            absorbing: disableNext,
            child: IconButton(
              icon: const Icon(Icons.arrow_circle_right_rounded),
              tooltip: disableNext ? 'Next Chart (disabled in Double layout)' : 'Next Chart',
              color: AppColors.colorBrand,
              onPressed: () {
                setState(() {
                  _chartIndex = (_chartIndex + 1) % 2; // 0 ↔ 1
                });
              },
            ),
          ),
        );
      }),
    ],
  ),
),



            const SizedBox(height: 8),

            // ---------- Slider (small fixed height) ----------
            SizedBox(
              height: 42,
              child: _buildLabelSlider(searchState, labelText),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLabelSlider(SearchState st, String labelText) {
    final labels = _pointTimesFromState(st);
    final showSlider = labels.length > _winSize;

    return Builder(
      builder: (context) {
        final screenW = MediaQuery.of(context).size.width;
        final sliderW = (screenW * 0.28).clamp(140.0, 220.0);

        return Align(
          alignment: Alignment.centerLeft,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.colorBg,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: AppColors.colorBrandTp.withValues(alpha: 0.30),
                  blurRadius: 6,
                  spreadRadius: 2,
                  offset: const Offset(0, 0), // glow all around
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: sliderW,
                    child: showSlider
                        ? SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 3,
                              activeTrackColor: AppColors.colorBrandTp,
                              inactiveTrackColor: AppColors.colorBrandTp.withValues(alpha: 0.25),
                              thumbColor: AppColors.colorBrand,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                            ),
                            child: Slider(
                              min: 0,
                              max: _winMaxStart.toDouble(),
                              divisions: _winMaxStart > 0 ? _winMaxStart : null,
                              value: _winStart.toDouble().clamp(0, _winMaxStart.toDouble()),
                              onChanged: (v) => setState(() {
                                _hasUserMovedSlider = true;
                                _winStart = v.round().clamp(0, _winMaxStart);
                              }),
                            ),
                          )
                        : SliderTheme( // <<<<<< แทน SizedBox.shrink()
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 3,
                              disabledActiveTrackColor: Colors.grey.shade400,
                              disabledInactiveTrackColor: Colors.grey.shade300,
                              disabledThumbColor: Colors.grey.shade500,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                            ),
                            child: Slider(
                              min: 0,
                              max: _winMaxStart.toDouble(),
                              divisions: _winMaxStart > 0 ? _winMaxStart : null,
                              value: _winStart.toDouble().clamp(0, _winMaxStart.toDouble()),
                              onChanged: null, // <- ทำให้กด/ลากไม่ได้ และใช้สี disabled ด้านบน
                            ),
                          ),
                  ),

                  const SizedBox(width: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 220),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      child: Container(
                        key: ValueKey(labelText),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.colorBrand,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          labelText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.colorBg,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
