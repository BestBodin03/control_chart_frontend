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
Widget buildChartsSectionSurfaceHardnessSmallLikeMedium(SearchState searchState) {
  return Row(
    children: [
      Expanded(
        child: _SmallLikeMediumCard(searchState: searchState),
      ),
    ],
  );
}

/// ----------------------------------------------------------------------------
/// Card
/// ----------------------------------------------------------------------------
class _SmallLikeMediumCard extends StatefulWidget {
  const _SmallLikeMediumCard({required this.searchState});
  final SearchState searchState;

  @override
  State<_SmallLikeMediumCard> createState() => _SmallLikeMediumCardState();
}

class _SmallLikeMediumCardState extends State<_SmallLikeMediumCard> {
  static const double _chartH = 144; // fixed height
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
      children: [
        // Title row (compact)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8,
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

        // Legend as a COLUMN (not overlay), above the blue card
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
              children: [
                const SizedBox(height: _gapV),

                // --- Control Chart (I) ---
                _SectionLabel('Control Chart'),
                _SmallChartBox(
                  searchState: searchState,
                  dataPoints: dataPoints,
                  isMr: false,
                  fixedHeight: _chartH,
                ),

                const SizedBox(height: _gapV),

                // --- MR ---
                const SizedBox(height: 8),
                _SectionLabel('Moving Range'),
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

  static const double _labelColWidth = 120; // ปรับได้ตามต้องการ

  @override
  Widget build(BuildContext context) {
    final s = searchState.controlChartStats;

    String fmt(double? v) => (v == null || v == 0.0) ? 'N/A' : v.toStringAsFixed(2);

    // --- Control Chart (I) ---
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
    final overSpec    = v?.beyondSpecLimit ?? 0;
    final overControl = v?.beyondControlLimit ?? 0;
    final trend       = v?.trend ?? 0;

    final controlEntries = <_LegendEntry>[
      _LegendEntry('Spec',   Colors.red,                 usl),
      _LegendEntry('UCL',    Colors.orange,              ucl),
      _LegendEntry('Target', Colors.deepPurple.shade300, target),
      _LegendEntry('AVG',    Colors.green,               avg),
      _LegendEntry('LCL',    Colors.orange,              lcl),
      _LegendEntry('Spec',   Colors.red,                 lsl),
    ].where((e) => e.value != 'N/A').toList();

    final mrEntries = <_LegendEntry>[
      _LegendEntry('UCL', Colors.orange, mrUcl),
      _LegendEntry('AVG',  Colors.green,  mrCl),
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
            // ===== Control Chart (3 ต่อแถว) =====
            if (controlChunks.isNotEmpty)
              _legendLabeledRow(
                label: 'Control Chart',
                entries: controlChunks[0],
                labelColWidth: _labelColWidth,
              ),
            if (controlChunks.length > 1)
              _legendLabeledRow(
                label: null, // แถวต่อไปไม่แสดงชื่อซ้ำ
                entries: controlChunks[1],
                labelColWidth: _labelColWidth,
              ),

            if (controlChunks.isNotEmpty) ...[
              const SizedBox(height: 4),
              // const Divider(height: 2),
              // const SizedBox(height: 4),
            ],

            // ===== MR (แถวเดียว inline) =====
            if (mrEntries.isNotEmpty) ...[
              _legendLabeledRow(
                label: 'Moving Range',
                entries: mrEntries,
                labelColWidth: _labelColWidth,
                maxPerRow: mrEntries.length, // ให้แสดงทั้งหมดในบรรทัดเดียว
              ),
              const SizedBox(height: 4),
              const Divider(height: 2),
              const SizedBox(height: 4),
            ],

            // ===== Violations (กลับมาแล้ว) =====
            if (showViolations)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // คอลัมน์ชื่อ
                    SizedBox(
                      width: _labelColWidth,
                      child: Text('Violations', style: AppTypography.textBody4BBold),
                    ),
                    // const SizedBox(width: 4),
                    // เส้นคั่นแนวตั้ง
                    // Container(width: 1, height: 16, color: Colors.grey.shade400),
                    // const SizedBox(width: 8),
                    // ชิป violations
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _ViolationChip(label: 'Spec',    count: overSpec,    color: Colors.red),
                          _ViolationChip(label: 'Control', count: overControl, color: Colors.orange),
                          _ViolationChip(label: 'Trend',   count: trend,       color: Colors.pink),
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


/// Row ที่มีคอลัมน์ชื่อซ้าย + เส้นกั้นแนวตั้ง + legends ทางขวา
Widget _legendLabeledRow({
  required String? label,
  required List<_LegendEntry> entries,
  required double labelColWidth,
  int maxPerRow = 3, // ค่าเริ่มต้น: 3 ชิ้น/แถว
}) {
  // ถ้าอยากให้ Control บังคับ 3 ชิ้น/แถว ให้ใช้ค่า default
  // ถ้าเป็น MR อยากให้ต่อแถวเดียว → ส่ง maxPerRow = entries.length

  final rowItems = _padToN(entries, maxPerRow); // เติมช่องว่างให้ครบจำนวนคอลัมน์

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label column
        SizedBox(
          width: labelColWidth,
          child: (label == null)
              ? const SizedBox.shrink()
              : Text(label, style: AppTypography.textBody4BBold),
        ),

        // const SizedBox(width: 8),

        // Vertical divider (แทนเครื่องหมาย '|')
        // Container(width: 1, height: 16, color: Colors.grey.shade400),

        // const SizedBox(width: 8),

        // Legend items (fixed columns)
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(rowItems.length, (i) {
              final item = rowItems[i];
              final widget = item == null
                  ? const SizedBox.shrink()
                  : _LegendItemRow(entry: item);
              return Expanded(
                child: Align(alignment: Alignment.centerLeft, child: widget),
              );
            }).expand((w) sync* {
              // แทรกช่องว่างคั่นระหว่างคอลัมน์
              yield w;
              if (w != rowItems.isNotEmpty) yield const SizedBox(width: 8);
            }).toList(),
          ),
        ),
      ],
    ),
  );
}

/// เติมให้ครบ N ช่อง (ถ้ารายการไม่ครบ)
List<_LegendEntry?> _padToN(List<_LegendEntry> list, int n) {
  final out = List<_LegendEntry?>.from(list);
  while (out.length < n) {
    out.add(null);
  }
  return out.take(n).toList();
}

/// แบ่งลิสต์เป็นก้อนละ 3
List<List<_LegendEntry>> _chunk3(List<_LegendEntry> list) {
  final chunks = <List<_LegendEntry>>[];
  for (var i = 0; i < list.length; i += 3) {
    chunks.add(list.sublist(i, (i + 3).clamp(0, list.length)));
  }
  return chunks;
}

/// แถว legend เดียว (แท่งสี + label + value)
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
              decoration: BoxDecoration(color: entry.color, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(width: 4),
          Text(entry.label,
              style: const TextStyle(fontSize: 10, color: AppColors.colorBlack, fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          Text(entry.value,
              style: const TextStyle(fontSize: 10, color: AppColors.colorBlack, fontWeight: FontWeight.bold)),
        ],
      );
}

/// โมเดล legend
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
    final bool showCount = label != 'Trend'; // 🔹 Trend ไม่แสดงกล่องตัวเลข

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
          // tiny dot
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

          // 🔹 ใช้ ternary ให้เว้นระยะ/กล่องตัวเลข เฉพาะเมื่อไม่ใช่ Trend
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
              : Container(
                  padding: EdgeInsets.symmetric( vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.transparent,
                    ),
                  ),
                )
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
  Widget build(BuildContext context) => SizedBox.expand(
        child: Center(child: child),
      );
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
