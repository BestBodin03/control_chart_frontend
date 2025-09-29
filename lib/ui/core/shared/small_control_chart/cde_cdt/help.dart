import 'package:control_chart/domain/models/chart_data_point.dart';
import 'package:flutter/material.dart';
import 'package:control_chart/domain/extension/map.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/data/bloc/search_chart_details/extension/search_state_extension.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';
import 'package:control_chart/ui/core/shared/small_control_chart/cde_cdt/control_chart_template_small_cde_cdt.dart';
import '../../../../../domain/models/control_chart_stats.dart';

// ---------- Builder ----------
Widget buildChartsSectionCdeCdtSmall(SearchState searchState) {
  final title = searchState.controlChartStats?.secondChartSelected?.label ?? 'N/A';
  return _CdeCdtSmallCard(title: title, searchState: searchState);
}

// ---------- Card (เหมือน Surface Hardness) ----------
class _CdeCdtSmallCard extends StatefulWidget {
  const _CdeCdtSmallCard({required this.title, required this.searchState});
  final String title;
  final SearchState searchState;

  @override
  State<_CdeCdtSmallCard> createState() => _CdeCdtSmallCardState();
}

class _CdeCdtSmallCardState extends State<_CdeCdtSmallCard> {
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

    final title = widget.title;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min, // ✅ เหมือนตัวบน
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

        // Legend toggle (ใช้คลาสเดียวกับของคุณ)
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: _showLegend
              ? Padding(
                  key: const ValueKey('legend-on'),
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _LegendColumnCdeCdt(searchState: searchState),
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
                _SmallChartBoxCdeCdt(
                  searchState: searchState,
                  isMr: false,
                  fixedHeight: _chartH,
                ),

                const SizedBox(height: _gapV),

                // --- MR ---
                const SizedBox(height: 8),
                const _SectionLabel('Moving Range'),
                _SmallChartBoxCdeCdt(
                  searchState: searchState,
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

// ---------- SmallChartBox (ยกพฤติกรรมให้เหมือน _SmallChartBox) ----------
class _SmallChartBoxCdeCdt extends StatelessWidget {
  const _SmallChartBoxCdeCdt({
    required this.searchState,
    required this.isMr,
    required this.fixedHeight,
  });

  final SearchState searchState;
  final bool isMr;
  final double fixedHeight;

  (DateTime? start, DateTime? end) _resolveRange() {
    DateTime? start = searchState.currentQuery.startDate;
    DateTime? end = searchState.currentQuery.endDate;

    final pts = searchState.chartDataPointsCdeCdt;
    if ((start == null || end == null) && pts.isNotEmpty) {
      final sorted = [...pts]..sort((a, b) => a.collectDate.compareTo(b.collectDate));
      start ??= sorted.first.collectDate;
      end ??= sorted.last.collectDate;
    }
    return (start, end);
  }

  @override
  Widget build(BuildContext context) {
    final (start, end) = _resolveRange();
    final q = searchState.currentQuery;

    // ✅ คีย์ seed ให้เหมือน Surface Hardness เพื่อบังคับ rebuild ถูกต้อง
    final keySeed =
        '${start?.millisecondsSinceEpoch}-${end?.millisecondsSinceEpoch}-${q.furnaceNo}-${q.materialNo}-${isMr ? 'mr' : 'i'}';

    return SizedBox(
      width: double.infinity,
      height: fixedHeight, // ✅ fixed เหมือนกัน
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: ControlChartTemplateSmallCdeCdt(
            key: ValueKey(keySeed.hashCode.toString()),
            // ถ้าต้อง “freeze” ข้อมูล ปลดคอมเมนต์สองบรรทัดนี้:
            // frozenDataPoints: List<ChartDataPoint>.from(searchState.chartDataPointsCdeCdt),
            // frozenStats: searchState.controlChartStats!,
            dataLineColor: AppColors.colorBrand,
            width: double.infinity,
            height: fixedHeight,
            isMovingRange: isMr,
            // ถ้าคอมโพเนนต์รองรับช่วงเวลาให้ส่งด้วย:
            // xStart: start,
            // xEnd: end,
          ),
        ),
      ),
    );
  }
}

// ---------- Reuse state widgets / section label ให้เหมือนตัวบน ----------
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

class _StateBox extends StatelessWidget {
  const _StateBox({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Center(child: child);
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


class _Empty extends StatelessWidget {
  const _Empty();
  @override
  Widget build(BuildContext context) =>
      const Text('ไม่มีข้อมูลสำหรับแสดงผล', style: TextStyle(fontSize: 12, color: Colors.grey));
}


/// ----------------------------------------------------------------------------
/// Legend (เวอร์ชัน CDE/CDT/Compound Layer)
/// ----------------------------------------------------------------------------
class _LegendColumnCdeCdt extends StatelessWidget {
  const _LegendColumnCdeCdt({required this.searchState});
  final SearchState searchState;

  static const double _labelColWidth = 120;

  SecondChartSelected? get _selType =>
      searchState.controlChartStats?.secondChartSelected;

  T? _sel<T>(T? cde, T? cdt, T? comp) {
    switch (_selType) {
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

  // ---------- SPEC / TARGET ----------
  double? _upperSpec(ControlChartStats? s) => _sel<double?>(
        s?.specAttribute?.cdeUpperSpec,
        s?.specAttribute?.cdtUpperSpec,
        s?.specAttribute?.compoundLayerUpperSpec,
      );

  double? _lowerSpec(ControlChartStats? s) => _sel<double?>(
        s?.specAttribute?.cdeLowerSpec,
        s?.specAttribute?.cdtLowerSpec,
        s?.specAttribute?.compoundLayerLowerSpec,
      );

  double? _target(ControlChartStats? s) => _sel<double?>(
        s?.specAttribute?.cdeTarget,
        s?.specAttribute?.cdtTarget,
        s?.specAttribute?.compoundLayerTarget,
      );

  // ---------- CONTROL LIMITS (เลือกตามชนิด; มี fallback) ----------
  // NOTE: เปลี่ยนชื่อฟิลด์ให้ตรงโมเดลคุณ:
  //  - cdeControlIChart / cdtControlIChart / compoundLayerControlIChart
  //  - cdeControlMRChart / cdtControlMRChart / compoundLayerControlMRChart
  _iLimit(ControlChartStats? s) =>
      _sel(
        s?.cdeControlLimitIChart,
        s?.cdtControlLimitIChart,
        s?.compoundLayerControlLimitIChart,
      ) ??
      s?.controlLimitIChart; // fallback ถ้ายังไม่มีแยก

  _mrLimit(ControlChartStats? s) =>
      _sel(
        s?.cdeControlLimitMRChart,
        s?.cdtControlLimitMRChart,
        s?.compoundLayerControlLimitMRChart,
      ) ??
      s?.controlLimitMRChart;

  double? _iUcl(ControlChartStats? s) => _iLimit(s)?.ucl;
  double? _iLcl(ControlChartStats? s) => _iLimit(s)?.lcl;
  double? _iCl (ControlChartStats? s) => _iLimit(s)?.cl;

  double? _mrUcl(ControlChartStats? s) => _mrLimit(s)?.ucl;
  double? _mrLcl(ControlChartStats? s) => _mrLimit(s)?.lcl;
  double? _mrCl (ControlChartStats? s) => _mrLimit(s)?.cl;

  // ---------- AVERAGE (เลือกตามชนิด; มีหลายชั้น fallback) ----------
  // หากมี average แยกต่อชนิด ให้ชี้ที่ฟิลด์เหล่านี้ก่อน
  double? _avgSelected(ControlChartStats? s) =>
      _sel<double?>(
        s?.cdeAverage,             // ถ้ามี
        s?.cdtAverage,             // ถ้ามี
        s?.compoundLayerAverage,   // ถ้ามี
      ) ?? s?.cdeAverage;

  // ---------- Violations ----------
  int _violBeyondSpec(ControlChartStats? s) =>
      _sel<int?>(
        s?.cdeViolations?.beyondSpecLimitLower,
        s?.cdtViolations?.beyondSpecLimitLower,
        s?.compoundLayerViolations?.beyondSpecLimitLower,
      ) ?? 0;

  int _violBeyondControl(ControlChartStats? s) =>
      _sel<int?>(
        s?.cdeViolations?.beyondControlLimitLower,
        s?.cdtViolations?.beyondControlLimitLower,
        s?.compoundLayerViolations?.beyondControlLimitLower,
      ) ?? 0;

  int _violTrend(ControlChartStats? s) =>
      _sel<int?>(
        s?.cdeViolations?.trend,
        s?.cdtViolations?.trend,
        s?.compoundLayerViolations?.trend,
      ) ?? 0;

  @override
  Widget build(BuildContext context) {
    final s = searchState.controlChartStats;
    String fmt(double? v) => (v == null || v == 0.0) ? 'N/A' : v.toStringAsFixed(2);

    // ---- I Chart ----
    final usl    = fmt(_upperSpec(s));
    final lsl    = fmt(_lowerSpec(s));
    final target = fmt(_target(s));
    final ucl    = fmt(_iUcl(s));
    final lcl    = fmt(_iLcl(s));
    final avgVal = fmt(_avgSelected(s));

    // ---- MR ----
    final mrUcl  = fmt(_mrUcl(s));
    final mrCl   = fmt(_mrCl(s));
    final mrLcl  = fmt(_mrLcl(s));

    // ---- Violations ----
    final overSpec    = _violBeyondSpec(s);
    final overControl = _violBeyondControl(s);
    final trend       = _violTrend(s);

    final controlEntries = <_LegendEntry>[
      _LegendEntry('Spec',   Colors.red,                 usl),
      _LegendEntry('Spec',   Colors.red,                 lsl),
      _LegendEntry('UCL',    Colors.orange,              ucl),
      _LegendEntry('LCL',    Colors.orange,              lcl),
      _LegendEntry('AVG',    Colors.green,               avgVal),
      _LegendEntry('Target', Colors.deepPurple.shade300, target),
    ].where((e) => e.value != 'N/A').toList();

    final mrEntries = <_LegendEntry>[
      _LegendEntry('UCL', Colors.orange, mrUcl),
      _LegendEntry('AVG', Colors.green,  mrCl),
      _LegendEntry('LCL', Colors.orange, mrLcl),
    ].where((e) => e.value != 'N/A').toList();

    final controlChunks = _chunk3(controlEntries);
    final showViolations =
        searchState.currentQuery.materialNo != null ||
        searchState.currentQuery.furnaceNo != null;

    return Material(
      color: Colors.white,
      elevation: 1.5,
      borderRadius: BorderRadius.circular(8),
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
                        children: [
                          _ViolationChip(label: 'Spec',    count: overSpec,    color: Colors.red),
                          _ViolationChip(label: 'Control', count: overControl, color: Colors.orange),
                          const _ViolationChip(label: 'Trend', color: Colors.pink),
                          // ถ้าต้องการโชว์ค่า trend:
                          // _ViolationChip(label: 'Trend', count: trend, color: Colors.pink),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
    );
  }
}

/// ----------------------------------------------------------------------------
/// Legend helpers (ใช้ร่วมโค้ดกับตัวบนได้)
/// ----------------------------------------------------------------------------
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

