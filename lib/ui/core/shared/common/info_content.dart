import 'package:control_chart/apis/settings/setting_apis.dart';
import 'package:control_chart/domain/types/chart_atrribute.dart';
import 'package:control_chart/ui/core/shared/large_control_chart/surface_hardness/help.dart';
import 'package:control_chart/ui/core/shared/searching_form_horizon.dart';
import 'package:flutter/material.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:intl/intl.dart';
import '../../design_system/app_color.dart';
import 'display_selector.dart';

class InfoContent extends StatefulWidget {
  const InfoContent({
    super.key,
    required this.searchState,
    required this.chartAttribute,
    required this.selectedPeriodType,
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
  int _winSize = 6;
  bool _hasUserMovedSlider = false;

  // ----- Helpers -----
  List<DateTime> _labelsFromState(SearchState st) {
    final raw = st.controlChartStats?.xAxisMediumLabel ?? const [];
    return raw.map<DateTime?>((e) {
      if (e is DateTime) return e.toLocal();
      if (e is String) {
        try { return (e).toLocal(); } catch (_) { return null; }
      }
      return null;
    }).whereType<DateTime>().toList();
  }


  void _recalcWindow(SearchState st) {
    final labels = _labelsFromState(st);
    final labelCount = labels.length;
    final int xTick = (st.controlChartStats?.xTick ?? 6).clamp(1, 100);
    _winSize = labelCount > 0 ? xTick.clamp(1, labelCount) : xTick;
    _winMaxStart = (labelCount - _winSize).clamp(0, labelCount);
    if (!_hasUserMovedSlider) {
      _winStart = _winMaxStart; // show latest by default
    }
    if (_winStart > _winMaxStart) _winStart = _winMaxStart;
    if (_winStart < 0) _winStart = 0;
  }

  (DateTime?, DateTime?) _currentWindowRange(SearchState st) {
    final labels = _labelsFromState(st);
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

  @override
  Widget build(BuildContext context) {
    final settingApis = SettingApis();
    final searchState = widget.searchState;
    _recalcWindow(searchState);
    final (left, right) = _currentWindowRange(searchState);
    final labelText = _formatDateRange(left, right);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---------- Header ----------
        Row(
          children: [
            Expanded(
              child: SearchingFormHorizon(settingApis: settingApis),
            ),
            const SizedBox(width: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 160, maxWidth: 260),
              child: DisplaySelector(
                initialPeriod: widget.selectedPeriodType,
                initialLayout: 1,
                onPeriodChanged: (period) {},
                onLayoutChanged: (screens) {},
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.cancel_rounded),
              tooltip: 'Close',
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ---------- Chart fills remaining height (no scroll / no overflow) ----------
        Expanded(
          child: ClipRect(
            child: buildChartsSectionSurfaceHardnessLarge(
              searchState,
            ),
          ),
        ),

        const SizedBox(height: 8),

        // ---------- Slider (small fixed height) ----------
        SizedBox(
          height: 56,
          child: _buildLabelSlider(searchState, labelText),
        ),

        const SizedBox(height: 8),
      ],
    );
  }

Widget _buildLabelSlider(SearchState st, String labelText) {
  final labels = _labelsFromState(st);
  final showSlider = labels.length > _winSize;

  return LayoutBuilder(
    builder: (context, box) {
      // Short slider on the left (responsive but capped)
      final maxW = box.maxWidth;
      final sliderW = (maxW * 0.28).clamp(140.0, 220.0);

      return Row(
        children: [
          // Left: short slider (or a fixed spacer to keep alignment)
          if (showSlider)
            SizedBox(
              width: sliderW,
              child: SliderTheme(
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
              ),
            )
          else
            SizedBox(width: sliderW),

          // const Spacer(),

          // Right: minimal pill label
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
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  labelText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade800,
                    height: 1.0,
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

// Optional helper if you later want to pass a narrowed date range into the chart.
/*
extension _StateRangeCopy on SearchState {
  SearchState copyWithRange({DateTime? startDate, DateTime? endDate}) {
    final newQuery = currentQuery.copyWith(
      startDate: startDate ?? currentQuery.startDate,
      endDate: endDate ?? currentQuery.endDate,
    );
    return copyWith(currentQuery: newQuery);
  }
}
*/
