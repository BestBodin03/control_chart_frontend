import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import 'package:control_chart/domain/models/chart_data_point.dart' show ChartDataPointCdeCdt;
import 'package:control_chart/domain/models/control_chart_stats.dart';
import 'package:control_chart/domain/models/setting.dart' show PeriodType;
import 'package:control_chart/domain/types/chart_component.dart';

import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';

/// ----------------------------------------------------------------------------
/// ControlChartComponentSmallCdeCdt (one-file)
/// - หน้าตา/พฤติกรรมเหมือน Surface Hardness Small
/// - รองรับการเลือกค่าตาม secondChartSelected (CDE/CDT/Compound Layer)
/// - มี _sel สำหรับ Spec/Target, ControlLimit(I), Avg, และ Y-range
/// ----------------------------------------------------------------------------
class ControlChartComponentSmallCdeCdt extends StatefulWidget implements ChartComponent {
  final List<ChartDataPointCdeCdt>? dataPoints; // กรองแล้วหรือทั้งหมดก็ได้
  final ControlChartStats? controlChartStats;

  final Color? dataLineColor;
  final Color? backgroundColor;

  /// ถ้า parent ให้ bounded height จะยืดเต็ม; ถ้าไม่ ให้ใช้ height นี้แทน
  final double? height;
  final double? width;

  /// ช่วงเวลาจริงจาก parent
  final DateTime xStart;
  final DateTime xEnd;

  const ControlChartComponentSmallCdeCdt({
    super.key,
    required this.xStart,
    required this.xEnd,
    this.dataPoints,
    this.controlChartStats,
    this.dataLineColor = AppColors.colorBrand,
    this.backgroundColor,
    this.height,
    this.width,
  });

  // ===== ChartComponent (ไม่ใช้ในเส้นทางนี้ แต่คง interface) =====
  @override
  FlBorderData buildBorderData() => FlBorderData(show: false);
  @override
  ExtraLinesData buildControlLines() => const ExtraLinesData();
  @override
  FlGridData buildGridData(double? minX, double? maxX, double? tickInterval) => const FlGridData(show: false);
  @override
  List<LineChartBarData> buildLineBarsData() => const <LineChartBarData>[];
  @override
  FlTitlesData buildTitlesData(double? minX, double? maxX, double? tickInterval) => const FlTitlesData();
  @override
  LineTouchData buildTouchData() => const LineTouchData();
  @override
  double getMaxY() => 0;
  @override
  double getMinY() => 0;
  @override
  Widget buildLegend() => const SizedBox.shrink();

  @override
  State<ControlChartComponentSmallCdeCdt> createState() => _ControlChartComponentSmallCdeCdtState();
}

class _ControlChartComponentSmallCdeCdtState extends State<ControlChartComponentSmallCdeCdt> {
  // ===== y-scale cache =====
  double? _cachedMinY;
  double? _cachedMaxY;
  double? _cachedInterval;

  // ----------------------------- helpers -----------------------------
  // เลือกค่าตามชนิดที่เลือก (CDE / CDT / CompoundLayer)
  T? _sel<T>(T? cde, T? cdt, T? comp) {
    switch (widget.controlChartStats?.secondChartSelected) {
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

  // ControlLimit ของ I-Chart (ต่อชนิด) + fallback ไป field รวม
  _iLimitSel(ControlChartStats? s) =>
      _sel(
        s?.cdeControlLimitIChart,
        s?.cdtControlLimitIChart,
        s?.compoundLayerControlLimitIChart,
      ) ??
      s?.controlLimitIChart;

  // ค่าเฉลี่ยของกราฟที่สอง (ต่อชนิด) + fallback เป็น second avg -> CL(I) -> avg รวม
  double? _avgSel(ControlChartStats? s) =>
      _sel<double?>(
        s?.cdeAverage,
        s?.cdtAverage,
        s?.compoundLayerAverage,
      ) ??
      // s?.averageSecondChart ??
      _iLimitSel(s)?.cl ??
      s?.cdeAverage;

  // ระยะ tick ของแกน X (พอๆ กับ Surface Small)
  double _xInterval(PeriodType periodType, double minX, double maxX) {
    final safeRange = (maxX - minX).abs().clamp(1.0, double.infinity);
    return safeRange / 6.0;
  }

  // สร้าง/คงค่า y-scale (เลือกจาก yAxisRange ต่อชนิด)
  void _ensureYScale() {
    if (_cachedInterval != null) return;

    const divisions = 4; // ~5 เส้นแนวนอน
    final yr = widget.controlChartStats?.yAxisRange;

    final minSel = _sel<double?>(
          yr?.minYcdeControlChart,
          yr?.minYcdtControlChart,
          yr?.minYcompoundLayerControlChart,
        ) ??
        0.0;
    final maxSel = _sel<double?>(
          yr?.maxYcdeControlChart,
          yr?.maxYcdtControlChart,
          yr?.maxYcompoundLayerControlChart,
        ) ??
        minSel;

    if (maxSel <= minSel) {
      _cachedMinY = minSel;
      _cachedMaxY = minSel + divisions;
      _cachedInterval = 1.0;
      return;
    }

    final ideal = (maxSel - minSel) / divisions;
    double interval = _niceStepCeil(ideal);

    double minY = (minSel / interval).floor() * interval;
    double maxY = minY + divisions * interval;

    while (maxY < maxSel - 1e-12) {
      interval = _nextNiceStep(interval);
      minY = (minSel / interval).floor() * interval;
      maxY = minY + divisions * interval;
    }

    _cachedMinY = minY;
    _cachedMaxY = maxY;
    _cachedInterval = interval;
  }

  double _getMinY() {
    _ensureYScale();
    return _cachedMinY ?? 0.0;
  }

  double _getMaxY() {
    _ensureYScale();
    return _cachedMaxY ?? 0.0;
  }

  double _getInterval() {
    _ensureYScale();
    return _cachedInterval ?? 1.0;
  }

  // ----------------------------- build -----------------------------
  @override
  Widget build(BuildContext context) {
    final pts = widget.dataPoints ?? const <ChartDataPointCdeCdt>[];
    if (pts.isEmpty) {
      return _panel(
        child: const Center(
          child: Text('No data', style: TextStyle(color: Colors.black54)),
        ),
      );
    }

    final double minXv = widget.xStart.millisecondsSinceEpoch.toDouble();
    final double maxXv = widget.xEnd.millisecondsSinceEpoch.toDouble();

    final periodType = widget.controlChartStats?.periodType ?? PeriodType.ONE_MONTH;
    final double xTick = _xInterval(periodType, minXv, maxXv);

    return LayoutBuilder(
      builder: (context, box) {
        final bool bounded = box.hasBoundedHeight && box.maxHeight.isFinite;
        final double w = widget.width ?? box.maxWidth;
        final double h = bounded ? box.maxHeight : (widget.height ?? 180);

        final chart = LineChart(
          LineChartData(
            minX: minXv,
            maxX: maxXv,
            minY: _getMinY(),
            maxY: _getMaxY(),
            gridData: _buildGridData(minXv, maxXv, xTick),
            titlesData: _buildTitlesData(minXv, maxXv, xTick),
            
            borderData: _buildBorderData(),
            extraLinesData: _buildControlLines(),
            lineBarsData: _buildLineBarsData(minXv, maxXv),
            lineTouchData: _buildTouchData(pts),
            clipData: const FlClipData.all(),
          ),
          duration: const Duration(milliseconds: 250),
        );

        return _panel(
          width: w,
          height: h,
          child: SizedBox(height: h, width: double.infinity, child: chart),
        );
      },
    );
  }

  // ====== Panel wrapper ======
  Widget _panel({Widget? child, double? width, double? height}) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      padding: const EdgeInsets.all(8),
      child: child,
    );
  }

  // ---------------------------------------------------------------------------
  // GRID / TITLES / BORDER
  // ---------------------------------------------------------------------------
  FlGridData _buildGridData(double? minX, double? maxX, double? tickInterval) {
    return FlGridData(
      show: true,
      drawHorizontalLine: true,
      drawVerticalLine: true,
      horizontalInterval: _getInterval(),
      verticalInterval: tickInterval ?? 1,
      getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey.shade100, strokeWidth: 0.5),
      getDrawingVerticalLine: (_) => FlLine(color: Colors.grey.shade100, strokeWidth: 0.5),
    );
  }

  FlTitlesData _buildTitlesData(double? minX, double? maxX, double? tickInterval) {
    final double minXv = minX!;
    final double maxXv = maxX!;
    final PeriodType periodType = widget.controlChartStats?.periodType ?? PeriodType.ONE_MONTH;
    final df = DateFormat('dd/MM');
    final double step = _xInterval(periodType, minXv, maxXv);

    Widget bottomLabel(double value, TitleMeta meta) {
      final dt = DateTime.fromMillisecondsSinceEpoch(value.round(), isUtc: true);
      final text = df.format(dt);
      return SideTitleWidget(
        meta: meta,
        space: 8,
        child: Transform.rotate(
          angle: -30 * math.pi / 180,
          child: Text(text, style: const TextStyle(fontSize: 8, color: Colors.black54), overflow: TextOverflow.ellipsis),
        ),
      );
    }

    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 28,
          interval: _getInterval(),
          getTitlesWidget: (v, _) => Text(v.toStringAsFixed(2), style: const TextStyle(color: Colors.black54, fontSize: 8)),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 32,
          interval: step,
          getTitlesWidget: bottomLabel,
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  FlBorderData _buildBorderData() {
    return FlBorderData(
      show: true,
      border: Border.all(color: Colors.black54, width: 1),
    );
  }

  // ---------------------------------------------------------------------------
  // CONTROL LINES — ใช้ค่า selected + fallback
  // ---------------------------------------------------------------------------
  ExtraLinesData _buildControlLines() {
    final s = widget.controlChartStats;

    final specUsl = _sel(
      s?.specAttribute?.cdeUpperSpec,
      s?.specAttribute?.cdtUpperSpec,
      s?.specAttribute?.compoundLayerUpperSpec,
    );
    final specLsl = _sel(
      s?.specAttribute?.cdeLowerSpec,
      s?.specAttribute?.cdtLowerSpec,
      s?.specAttribute?.compoundLayerLowerSpec,
    );
    final target = _sel(
      s?.specAttribute?.cdeTarget,
      s?.specAttribute?.cdtTarget,
      s?.specAttribute?.compoundLayerTarget,
    );

    final iLimit = _iLimitSel(s);
    final ucl = iLimit?.ucl;
    final lcl = iLimit?.lcl;
    final avg = _avgSel(s);

    return ExtraLinesData(
      extraLinesOnTop: false,
      horizontalLines: [
        if ((specUsl ?? 0) > 0) HorizontalLine(y: specUsl!, color: Colors.red.shade400, strokeWidth: 2),
        if (ucl != null)        HorizontalLine(y: ucl,     color: Colors.amberAccent, strokeWidth: 1.5),
        if ((target ?? 0) != 0) HorizontalLine(y: target!, color: Colors.deepPurple.shade300, strokeWidth: 1.5),
        if (avg != null)        HorizontalLine(y: avg,     color: AppColors.colorSuccess1, strokeWidth: 2),
        if (lcl != null)        HorizontalLine(y: lcl,     color: Colors.amberAccent, strokeWidth: 1.5),
        if ((specLsl ?? 0) > 0) HorizontalLine(y: specLsl!, color: Colors.red.shade400, strokeWidth: 2),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // LINES + DOTS — ใช้ window จาก minXv..maxXv
  // ---------------------------------------------------------------------------
  List<LineChartBarData> _buildLineBarsData(double minXv, double maxXv) {
    final src = widget.dataPoints ?? const <ChartDataPointCdeCdt>[];
    if (src.isEmpty) {
      return [LineChartBarData(spots: const [], color: widget.dataLineColor, barWidth: 2)];
    }

    final spots = src
        .map((p) => FlSpot(p.collectDate.millisecondsSinceEpoch.toDouble(), p.value))
        .where((s) => s.x >= math.min(minXv, maxXv) && s.x <= math.max(minXv, maxXv))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));

    // map date->point
    final Map<double, ChartDataPointCdeCdt> byX = {
      for (final p in src) p.collectDate.millisecondsSinceEpoch.toDouble(): p
    };

    // เส้นอ้างอิงสำหรับสี dot
    final s = widget.controlChartStats;
    final specUsl = _sel(
          s?.specAttribute?.cdeUpperSpec,
          s?.specAttribute?.cdtUpperSpec,
          s?.specAttribute?.compoundLayerUpperSpec,
        ) ??
        0.0;
    final specLsl = _sel(
          s?.specAttribute?.cdeLowerSpec,
          s?.specAttribute?.cdtLowerSpec,
          s?.specAttribute?.compoundLayerLowerSpec,
        ) ??
        0.0;
    final iLimit = _iLimitSel(s);
    final ucl = iLimit?.ucl ?? 0.0;
    final lcl = iLimit?.lcl ?? 0.0;

    final baseColor = widget.dataLineColor ?? AppColors.colorBrand;

    // ชั้น dots (แสดงสีตามสถานะ)
    final dotsOnly = LineChartBarData(
      spots: spots,
      isCurved: false,
      color: Colors.transparent,
      barWidth: 0,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, _, __, ___) {
          final p = byX[spot.x];
          final v = spot.y;

          Color dotColor = baseColor;
          final bool overSpec = ((specUsl > 0 && v > specUsl) || (specLsl > 0 && v < specLsl));
          final bool overCL   = ((ucl > 0 && v > ucl) || (lcl > 0 && v < lcl));
          final bool trend    = (p?.isViolatedR3 == true);

          if (trend) dotColor = Colors.pinkAccent;
          else if (overSpec || p?.isViolatedR1BeyondUSL == true || p?.isViolatedR1BeyondLSL == true) {
            dotColor = Colors.red;
          } else if (overCL || p?.isViolatedR1BeyondUCL == true || p?.isViolatedR1BeyondLCL == true) {
            dotColor = Colors.orange;
          }

          return FlDotCirclePainter(
            radius: 3.5,
            color: dotColor.withValues(alpha: 0.9),
            strokeWidth: 1,
            strokeColor: Colors.white,
          );
        },
      ),
      belowBarData: BarAreaData(show: false),
    );

    // เส้นเชื่อมปกติ (single layer)
    final line = LineChartBarData(
      spots: spots,
      isCurved: false,
      color: baseColor,
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
    );

    return [line, dotsOnly];
  }

  // ---------------------------------------------------------------------------
  // TOUCH / TOOLTIP — ใช้ FLChart tooltip แบบเบา ๆ
  // ---------------------------------------------------------------------------
  LineTouchData _buildTouchData(List<ChartDataPointCdeCdt> src) {
    final map = {
      for (final p in src) p.collectDate.millisecondsSinceEpoch.toDouble(): p
    };

    return LineTouchData(
      handleBuiltInTouches: true,
      touchTooltipData: LineTouchTooltipData(
        maxContentWidth: 200,
        fitInsideHorizontally: true,
        fitInsideVertically: true,
        getTooltipColor: (_) => AppColors.colorBrand.withValues(alpha: 0.9),
        tooltipBorderRadius: BorderRadius.circular(8),
        getTooltipItems: (spots) {
          return spots.map((s) {
            final p = map[s.x];
            if (p == null) return null;
            return LineTooltipItem(
              "วันที่: ${p.fullLabel}\n"
              "ค่า: ${s.y.toStringAsFixed(3)}\n"
              "เตา: ${p.furnaceNo ?? '-'}\n"
              "เลขแมต: ${p.matNo ?? '-'}",
              AppTypography.textBody3W,
              textAlign: TextAlign.left,
            );
          }).whereType<LineTooltipItem>().toList();
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // nice steps
  // ---------------------------------------------------------------------------
  double _niceStepCeil(double x) {
    if (x <= 0 || x.isNaN || x.isInfinite) return 1.0;
    final exp = (math.log(x) / math.log(10)).floor();
    final mag = math.pow(10.0, exp).toDouble();
    final mant = x / mag;
    if (mant <= 0.025) return 0.025 * mag;
    if (mant <= 0.050) return 0.050 * mag;
    if (mant <= 0.075) return 0.075 * mag;
    if (mant <= 0.125) return 0.125 * mag;
    if (mant <= 0.25) return 0.25 * mag;
    if (mant <= 0.5) return 0.5 * mag;
    if (mant <= 1.0) return 1.0 * mag;
    if (mant <= 1.25) return 1.25 * mag;
    if (mant <= 1.5) return 1.5 * mag;
    if (mant <= 2.0) return 2.0 * mag;
    if (mant <= 2.5) return 2.5 * mag;
    if (mant <= 3.0) return 3.0 * mag;
    if (mant <= 4.0) return 4.0 * mag;
    if (mant <= 5.0) return 5.0 * mag;
    return 10.0 * mag;
  }

  double _nextNiceStep(double step) {
    final exp = (math.log(step) / math.log(10)).floor();
    final mag = math.pow(10.0, exp).toDouble();
    final mant = step / mag;
    if (mant <= 0.025) return 0.050 * mag;
    if (mant <= 0.050) return 0.075 * mag;
    if (mant <= 0.075) return 0.125 * mag;
    if (mant <= 0.125) return 0.25 * mag;
    if (mant <= 0.25) return 0.5 * mag;
    if (mant <= 0.5) return 1.0 * mag;
    if (mant < 1.0) return 2.0 * mag;
    if (mant < 2.0) return 2.5 * mag;
    if (mant < 2.5) return 3.0 * mag;
    if (mant < 5.0) return 10.0 * mag;
    return 10.0 * mag;
  }
}
