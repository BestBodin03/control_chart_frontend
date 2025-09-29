import 'package:flutter/material.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/data/bloc/search_chart_details/extension/search_state_extension.dart';

import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';
import 'package:control_chart/ui/core/shared/small_control_chart/surface_hardness/control_chart_template_small.dart';

import 'package:control_chart/domain/models/chart_data_point.dart';

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
  static const double _chartH = 144; // fixed height ต่อหนึ่งกราฟ
  static const double _gapV = 4;

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min, // ✅ สำคัญเมื่ออยู่ใต้สกอลล์
      children: [
        // Title row (compact)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: AppTypography.textBody3BBold),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => setState(() => _showLegend = !_showLegend),
              icon: const Icon(Icons.info_rounded, size: 16),
              tooltip: 'Info',
            ),
          ],
        ),
        
        const SizedBox(height: 8),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: _showLegend
              ? Padding(
                  key: const ValueKey('legend-on'),
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _LegendColumn(searchState: searchState),
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
                const _SectionLabel('Control Chart'),
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

class _LegendColumn extends StatelessWidget {
  const _LegendColumn({required this.searchState});
  final SearchState searchState;

  static const double _labelColWidth = 120;

  @override
  Widget build(BuildContext context) {
    final s = searchState.controlChartStats;
    String fmt(double? v) => (v == null || v == 0.0) ? 'N/A' : v.toStringAsFixed(2);

    // --- I Chart ---
    final usl    = fmt(s?.specAttribute?.surfaceHardnessUpperSpec);
    final lsl    = fmt(s?.specAttribute?.surfaceHardnessLowerSpec);
    final target = fmt(s?.specAttribute?.surfaceHardnessTarget);
    final ucl    = fmt(s?.controlLimitIChart?.ucl);
    final lcl    = fmt(s?.controlLimitIChart?.lcl);
    final avg    = fmt(s?.average);

    // --- MR ---
    final mrUcl  = fmt(s?.controlLimitMRChart?.ucl);
    final mrCl   = fmt(s?.controlLimitMRChart?.cl);
    final mrLcl  = fmt(s?.controlLimitMRChart?.lcl);

    // --- Violations ---
    final v = s?.surfaceHardnessViolations;
    final overSpec    = v?.beyondSpecLimitLower ?? 0;
    final overControl = v?.beyondControlLimitLower ?? 0;
    final trend       = v?.trend ?? 0;

    final controlEntries = <_LegendEntry>[
      _LegendEntry('Spec',   Colors.red,                 usl),
      _LegendEntry('Spec',   Colors.red,                 lsl),
      _LegendEntry('UCL',    Colors.orange,              ucl),
      _LegendEntry('LCL',    Colors.orange,              lcl),
      _LegendEntry('AVG',    Colors.green,               avg),
      _LegendEntry('Target', Colors.deepPurple.shade300, target),
    ].where((e) => e.value != 'N/A').toList();

    final mrEntries = <_LegendEntry>[
      _LegendEntry('UCL', Colors.orange, mrUcl),
      _LegendEntry('AVG', Colors.green,  mrCl),
      _LegendEntry('LCL', Colors.orange, mrLcl),
    ].where((e) => e.value != 'N/A').toList();

    final controlChunks = _chunk3(controlEntries);
    final showViolations =
        searchState.currentQuery.materialNo != null || searchState.currentQuery.furnaceNo != null;

    return Material(
      color: Colors.white,
      elevation: 1.5,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (controlChunks.isNotEmpty)
              _legendLabeledRow(
                label: 'Control Chart',
                entries: controlChunks[0],
                labelColWidth: _labelColWidth,
              ),
            if (controlChunks.length > 1)
              _legendLabeledRow(
                label: null,
                entries: controlChunks[1],
                labelColWidth: _labelColWidth,
              ),
            if (controlChunks.isNotEmpty) ...[
              const SizedBox(height: 4),
              const Divider(height: 2),
              const SizedBox(height: 4),
            ],
            if (mrEntries.isNotEmpty) ...[
              _legendLabeledRow(
                label: 'Moving Range',
                entries: mrEntries,
                labelColWidth: _labelColWidth,
                maxPerRow: 3,
              ),
              const SizedBox(height: 4),
              const Divider(height: 2),
              const SizedBox(height: 4),
            ],
            if (showViolations)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: _labelColWidth,
                      child: Text('Violations', style: AppTypography.textBody4BBold),
                    ),
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: const [
                          _ViolationChip(label: 'Spec',    count: 0, color: Colors.red),
                          _ViolationChip(label: 'Control', count: 0, color: Colors.orange),
                          _ViolationChip(label: 'Trend',   count: 0, color: Colors.pink),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

Widget _legendLabeledRow({
  required String? label,
  required List<_LegendEntry> entries,
  required double labelColWidth,
  int maxPerRow = 3,
  double gap = 8.0,
}) {
  final rowItems = _padToN(entries, maxPerRow);
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Table(
      columnWidths: <int, TableColumnWidth>{
        0: FixedColumnWidth(labelColWidth),
        for (int i = 1; i <= maxPerRow; i++) i: const FlexColumnWidth(1),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          children: [
            (label == null)
                ? const SizedBox.shrink()
                : Text(label, style: AppTypography.textBody4BBold),
            for (int c = 0; c < maxPerRow; c++)
              Padding(
                padding: EdgeInsets.only(right: c < maxPerRow - 1 ? gap : 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: rowItems[c] == null
                      ? const SizedBox.shrink()
                      : _LegendItemRow(entry: rowItems[c]!),
                ),
              ),
          ],
        ),
      ],
    ),
  );
}

List<_LegendEntry?> _padToN(List<_LegendEntry> list, int n) {
  final out = List<_LegendEntry?>.from(list);
  while (out.length < n) out.add(null);
  return out.take(n).toList();
}

List<List<_LegendEntry>> _chunk3(List<_LegendEntry> list) {
  final chunks = <List<_LegendEntry>>[];
  for (var i = 0; i < list.length; i += 3) {
    chunks.add(list.sublist(i, (i + 3).clamp(0, list.length)));
  }
  return chunks;
}

class _LegendItemRow extends StatelessWidget {
  const _LegendItemRow({required this.entry});
  final _LegendEntry entry;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 9,
            height: 3,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: entry.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(entry.label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.colorBlack,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(width: 4),
          Text(entry.value,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.colorBlack,
                fontWeight: FontWeight.bold,
              )),
        ],
      );
}

class _LegendEntry {
  const _LegendEntry(this.label, this.color, this.value);
  final String label;
  final Color color;
  final String value;
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isZero ? Colors.grey.shade500 : color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.colorBlack,
            ),
          ),
          showCount ? const SizedBox(width: 4) : const SizedBox(width: 4),
          showCount
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
              : const SizedBox.shrink(),
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
    required this.fixedHeight,
  });

  final SearchState searchState;
  final List<ChartDataPoint> dataPoints;
  final bool isMr;
  final double fixedHeight;

  @override
  Widget build(BuildContext context) {
    final q = searchState.currentQuery;
    final keySeed =
        '${q.startDate?.millisecondsSinceEpoch}-${q.endDate?.millisecondsSinceEpoch}-${q.furnaceNo}-${q.materialNo}-${isMr ? 'mr' : 'i'}';

    return SizedBox(
      width: double.infinity,
      height: fixedHeight, // ✅ fixed
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
