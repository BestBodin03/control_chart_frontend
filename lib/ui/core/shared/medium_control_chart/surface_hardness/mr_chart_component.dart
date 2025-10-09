import 'dart:math' as math;
import 'package:control_chart/domain/models/chart_data_point.dart';
import 'package:control_chart/domain/models/control_chart_stats.dart';
import 'package:control_chart/domain/models/setting.dart';
import 'package:control_chart/domain/types/chart_component.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../common/chart/legend_item.dart';
import '../../common/chart/size_scaler.dart';
import '../../small_control_chart/small_control_chart_var.dart';

/// MR-Chart (Moving Range) with local Tooltip (no Overlay), quadrant placement.
class MrChartComponent extends StatefulWidget implements ChartComponent {
  final List<ChartDataPoint>? dataPoints;
  final ControlChartStats? controlChartStats;
  final Color? dataLineColor;
  final Color? backgroundColor;
  final double? height;
  final double? width;

  /// ช่วงเวลาที่ต้องการแสดง
  final DateTime xStart;
  final DateTime xEnd;

  const MrChartComponent({
    super.key,
    this.dataPoints,
    this.controlChartStats,
    this.dataLineColor = AppColors.colorBrand,
    this.backgroundColor,
    this.height,
    this.width = 560,
    required this.xStart,
    required this.xEnd,
  });

  // ===== STUBs เพื่อให้ตอบ interface ChartComponent =====
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
  State<MrChartComponent> createState() => _MrChartComponentState();
  
  @override
  Widget buildLegend(context) {
    String fmt(double? v) => (v == null || v == 0.0) ? 'N/A' : v.toStringAsFixed(2);
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      direction: Axis.horizontal,
      alignment: WrapAlignment.spaceEvenly,
      children: [
        if (fmt(controlChartStats?.controlLimitMRChart?.ucl) != 'N/A')
          legendItem(context,'UCL', Colors.orange, fmt(controlChartStats?.controlLimitMRChart?.ucl)),
        if (fmt(controlChartStats?.mrAverage) != 'N/A')
          legendItem(context, 'AVG', Colors.green, fmt(controlChartStats?.mrAverage)),
      ],
    );
  }
}

class _MrChartComponentState extends State<MrChartComponent> {
  final GlobalKey _chartKey = GlobalKey();

 // ---------- คำนวณ/แคชสเกลแกน Y (ล็อก 6 ticks) ----------
  double? _cachedMinY;
  double? _cachedMaxY;
  double? _cachedInterval;

  // หมายเหตุ: ต้องมี niceSteps ที่อื่นอยู่แล้ว (เช่น [1,2,2.5,5,10,...])
  double _niceStepCeil(double x) {
    int left = 0, right = niceSteps.length - 1;
    while (left < right) {
      final mid = (left + right) >> 1;
      if (niceSteps[mid] >= x) {
        right = mid;
      } else {
        left = mid + 1;
      }
    }
    return niceSteps[left];
  }

  double _nextNiceStep(double step) {
    int left = 0, right = niceSteps.length - 1;
    while (left < right) {
      final mid = (left + right) >> 1;
      if (niceSteps[mid] > step) {
        right = mid;
      } else {
        left = mid + 1;
      }
    }
    return niceSteps[left];
  }

  void _ensureYScale() {
    if (_cachedInterval != null) return;

    const divisions = 5; // -> 6 ticks (divisions + 1)

    final minSel = 0.0;
    final maxSel = widget.controlChartStats?.yAxisRange?.maxYsurfaceHardnessMrChart ?? minSel;

    if (maxSel <= minSel) {
      _cachedMinY = minSel;
      _cachedMaxY = minSel + divisions;
      _cachedInterval = 1.0;
      return;
    }

    // 1) เลือก interval แบบ nice จาก ideal
    final ideal = (maxSel - minSel) / divisions;
    double interval = _niceStepCeil(ideal);

    // 2) จัด minY ให้ตรง multiple ของ interval แล้วกำหนด maxY = minY + divisions*interval (คง span)
    double minY = (minSel / interval).floor() * interval;
    double maxY = minY + divisions * interval;

    // 3) ถ้าคุมไม่ถึง maxSel เลื่อนช่วงแบบคง span หรืออัพ step
    while (maxY < maxSel - 1e-12) {
      // ลองเลื่อนช่วงขึ้นทั้งก้อน
      minY += interval;
      maxY = minY + divisions * interval;

      // ถ้ายังไม่ถึง แสดงว่า interval เล็กไป → ใช้ next nice step และ realign
      if (maxY < maxSel - 1e-12) {
        interval = _nextNiceStep(interval);
        minY = (minSel / interval).floor() * interval;
        maxY = minY + divisions * interval;
      }
    }

    // 4) กันเส้นสำคัญมานั่งบน min/max → เลื่อนช่วงแบบคง span
    final pins = <double?>[
      widget.controlChartStats?.controlLimitMRChart?.lcl,
      widget.controlChartStats?.controlLimitMRChart?.ucl,
    ];

    for (final v in pins) {
      if (v == null) continue;
      if ((v - minY).abs() < 1e-9) {
        minY -= interval;
        maxY = minY + divisions * interval;
      } else if ((v - maxY).abs() < 1e-9) {
        maxY += interval;
        minY = maxY - divisions * interval;
      }
    }

    // 5) snap ลด floating error และย้ำ span คงที่
    double _snap(double val, double step) => (val / step).roundToDouble() * step;
    minY = _snap(minY, interval);
    maxY = minY + (divisions+1) * interval;

    if(minY <= 0.0){
      minY = 0.0;
    }

    _cachedMinY = minY;
    _cachedMaxY = maxY;
    _cachedInterval = interval;
  }
  
  // Tooltip state (local)
  final ValueNotifier<_MrTip?> _tip = ValueNotifier<_MrTip?>(null);


  List<ChartDataPoint> get _pointsInWindow {
    final src = widget.dataPoints ?? const <ChartDataPoint>[];
    if (src.length <= 1) return const <ChartDataPoint>[];

    final lo = math.min(widget.xStart.millisecondsSinceEpoch,
                        widget.xEnd.millisecondsSinceEpoch).toDouble();
    final hi = math.max(widget.xStart.millisecondsSinceEpoch,
                        widget.xEnd.millisecondsSinceEpoch).toDouble();

    final filtered = src.where((p) {
      final t = p.collectDate.millisecondsSinceEpoch.toDouble();
      return t >= lo && t <= hi;
    }).toList()
      ..sort((a, b) => a.collectDate.compareTo(b.collectDate));

    if (filtered.length <= 1) return const <ChartDataPoint>[];
    // เอาแค่ length - 1 (ตัดตัวท้าย)
    return filtered.sublist(0, filtered.length - 1);
  }


  @override
  void dispose() {
    _tip.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double minXv = widget.xStart.millisecondsSinceEpoch.toDouble();
    final double maxXv = widget.xEnd.millisecondsSinceEpoch.toDouble();
    final double safeRange = (maxXv - minXv).abs().clamp(1.0, double.infinity);
    final int desiredTick = (widget.controlChartStats?.xTick ?? 6).clamp(2, 100);
    final double tickInterval = safeRange / (desiredTick - 1);
    final minSel = 0.0;
    final maxSel = widget.controlChartStats?.yAxisRange?.maxYsurfaceHardnessMrChart ?? minSel;

    return LayoutBuilder(
      builder: (context, constraints) {
        final Size chartSize = Size(
          widget.width  ?? constraints.maxWidth,
          widget.height ?? constraints.maxHeight,
        );

        return Container(
          height: chartSize.height,
          width: chartSize.width,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Chart
              Positioned.fill(
                child: KeyedSubtree(
                  key: _chartKey,
                  child: LineChart(
                    LineChartData(
                      minX: minXv,
                      maxX: maxXv,
                      minY: _getMinY(minSel),
                      maxY: _getMaxY(maxSel),
                      gridData: _gridData(minXv, maxXv, tickInterval),
                      titlesData: _titlesData(minXv, maxXv),
                      borderData: _borderData(),
                      extraLinesData: _controlLines(),
                      lineBarsData: _lineBarsData(),
                      lineTouchData: _touchData(),
                    ),
                  ),
                ),
              ),

              // Tooltip (local-only, non-blocking) — quadrant placement + clamp
              ValueListenableBuilder<_MrTip?>(
                valueListenable: _tip,
              builder: (context, tip, _) {
                if (tip == null) return const SizedBox.shrink();

                const double maxWidth = 90;
                const double boxH = 120;
                const double dotR = 8;
                const double gap = 8;
                const double pad = 8;

                final dx = tip.local.dx;
                final dy = tip.local.dy;

                // available room checks
                final bool canAbove = dy - (dotR + gap + boxH) >= pad;
                final bool canBelow = dy + (dotR + gap + boxH) <= chartSize.height - pad;
                final bool canRight = dx + (dotR + gap + maxWidth) <= chartSize.width  - 6*pad;
                final bool canLeft  = dx - (dotR + gap + maxWidth) >= pad; // ✅ fix

                double left, top;

                if (canAbove) {
                  // above
                  left = dx - maxWidth / 2;
                  top  = dy - dotR - gap - boxH;
                  final hiX = chartSize.width - maxWidth - pad;
                  left = (hiX <= pad) ? (chartSize.width - maxWidth) / 2 : left.clamp(pad, hiX);
                } else if (canBelow) {
                  // below
                  left = dx - maxWidth / 2;
                  top  = dy + dotR + gap;
                  final hiX = chartSize.width - maxWidth - pad;
                  left = (hiX <= pad) ? (chartSize.width - maxWidth) / 2 : left.clamp(pad, hiX);
                } else if (canRight) {
                  // right (vertically centered)
                  left = dx + dotR + 4*gap;
                  top  = dy - boxH / 2;
                  final hiY = chartSize.height - boxH - pad;
                  top = (hiY <= pad) ? (chartSize.height - boxH) / 2 : top.clamp(pad, hiY);
                } else if (canLeft) {
                  // left (vertically centered)
                  left = dx - dotR - gap - maxWidth;
                  top  = dy - boxH / 2;
                  final hiY = chartSize.height - boxH - pad;
                  top = (hiY <= pad) ? (chartSize.height - boxH) / 2 : top.clamp(pad, hiY);
                } else {
                  // very tight: center in the box
                  left = (chartSize.width  - maxWidth) / 2;
                  top  = (chartSize.height - boxH) / 2;
                }

                // final clamp (safety)
                final hiX = chartSize.width - maxWidth - pad;
                final hiY = chartSize.height - boxH - pad;
                if (hiX > pad) left = left.clamp(pad, hiX);
                if (hiY > pad) top  = top.clamp(pad, hiY);

                return Positioned(
                  left: left,
                  top: top,
                  width: maxWidth,
                  child: IgnorePointer(
                    ignoring: true,
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.colorBrand.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          textAlign: TextAlign.center,
                          tip.valueStr,
                          style: AppTypography.textBody4WBold,),
                      ),
                    ),
                  ),
                );
              },
              ),
            ],
          ),
        );
      },
    );
  }

  // --------------------- GRID / TITLES / BORDER ---------------------

  FlGridData _gridData(double? minX, double? maxX, double? tickInterval) {
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

  FlTitlesData _titlesData(double? minX, double? maxX) {
    final double minXv = minX ?? widget.xStart.millisecondsSinceEpoch.toDouble();
    final double maxXv = maxX ?? widget.xEnd.millisecondsSinceEpoch.toDouble();
    final PeriodType periodType =
        widget.controlChartStats?.periodType ?? PeriodType.ONE_MONTH;

    final df = DateFormat('dd/MM');
    final double step = _xInterval(periodType, minXv, maxXv);

    // === bottom label builder ===
    Widget bottomLabel(double value, TitleMeta meta) {
      final dt = DateTime.fromMillisecondsSinceEpoch(value.round(), isUtc: true);
      final text = df.format(dt);

      // ✅ use textScaler for font and sizeScaler for spacing
      final double fontSize = MediaQuery.of(context).textScaler.scale(12);
      final double labelSpace = sizeScaler(context, 8, 1.5);

      return SideTitleWidget(
        meta: meta,
        space: labelSpace,
        child: Transform.rotate(
          angle: -30 * math.pi / 180,
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              color: AppColors.colorBlack,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          // ✅ scale reserved space consistently with font
          reservedSize: sizeScaler(context, 32, 1.5),
          interval: _getInterval(),
          getTitlesWidget: (v, meta) {
            final double fontSize = MediaQuery.of(context).textScaler.scale(12);
            return Text(
              v.toStringAsFixed(0),
              style: TextStyle(
                color: AppColors.colorBlack,
                fontSize: fontSize,
              ),
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: sizeScaler(context, 24, 1.5),
          interval: step,
          getTitlesWidget: bottomLabel,
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }


  FlBorderData _borderData() => FlBorderData(show: true, border: Border.all(color: Colors.black54, width: 1));

  // -------------------------- CONTROL LINES --------------------------

  ExtraLinesData _controlLines() {
    return ExtraLinesData(
      extraLinesOnTop: false,
      horizontalLines: [
        HorizontalLine(
          y: widget.controlChartStats?.controlLimitMRChart?.ucl ?? 0.0,
          color: Colors.amberAccent,
          strokeWidth: 1.5,
        ),
        HorizontalLine(
          y: widget.controlChartStats?.mrAverage ?? 0.0,
          color: AppColors.colorSuccess1,
          strokeWidth: 2,
        ),
      ],
    );
  }

  // ---------------------------- DATA LAYERS ----------------------------

  List<LineChartBarData> _lineBarsData() {
    final pts = _pointsInWindow;
    if (pts.isEmpty) {
      return [LineChartBarData(spots: const [], color: widget.dataLineColor, barWidth: 2)];
    }

    final minXv = widget.xStart.millisecondsSinceEpoch.toDouble();
    final maxXv = widget.xEnd.millisecondsSinceEpoch.toDouble();

    final spots = pts
        .map((p) => FlSpot(p.collectDate.millisecondsSinceEpoch.toDouble(), p.mrValue))
        .where((s) => s.x >= math.min(minXv, maxXv) && s.x <= math.max(minXv, maxXv))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));

    final ucl = widget.controlChartStats?.controlLimitMRChart?.ucl ?? 0.0;
    final baseColor = widget.dataLineColor ?? AppColors.colorBrand;

    return [
      LineChartBarData(
        spots: spots,
        isCurved: false,
        color: baseColor,
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, _, __, ___) {
            final v = spot.y;
            final isOverUCL = (ucl > 0 && v > ucl);
            final dotColor = isOverUCL ? Colors.orange : baseColor;
            return FlDotCirclePainter(
              radius: 3.5,
              color: dotColor,
              strokeWidth: 1,
              strokeColor: Colors.white,
            );
          },
        ),
        belowBarData: BarAreaData(show: false),
      ),
    ];
  }

  // --------------------------- TOUCH / TOOLTIP ---------------------------

  static List<LineTooltipItem?> _emptyTooltip(List<LineBarSpot> touchedSpots) =>
      List<LineTooltipItem?>.filled(touchedSpots.length, null);

  LineTouchData _touchData() {
    return LineTouchData(
      handleBuiltInTouches: true,
      touchSpotThreshold: 16,
      getTouchedSpotIndicator: (barData, indexes) => indexes.map((_) {
        return TouchedSpotIndicatorData(
          FlLine(color: Colors.blueAccent.withValues(alpha: 0.5), strokeWidth: 3),
          FlDotData(
            show: true,
            getDotPainter: (spot, __, ___, ____) => FlDotCirclePainter(
              radius: 3.5,
              color: AppColors.colorBrandTp,
              strokeWidth: 3,
              strokeColor: Colors.blueAccent
            ),
          ),
        );
      }).toList(),
      // ปิด tooltip ของ fl_chart (เราวาดเอง)
      touchTooltipData: LineTouchTooltipData(getTooltipItems: _emptyTooltip),

      touchCallback: (event, resp) {
        final noHit = !event.isInterestedForInteractions ||
            resp?.lineBarSpots == null ||
            resp!.lineBarSpots!.isEmpty;

        if (noHit) {
          _tip.value = null;
          return;
        }

        final s = resp.lineBarSpots!.first;
        _tip.value = _MrTip(
          local: event.localPosition!,
          valueStr: s.y.toStringAsFixed(3),
        );
      },
    );
  }

  // ------------------------------ Y SCALE ------------------------------

  double _getMinY(double _) {
    if (_cachedInterval == null) _ensureYScale();
    return _cachedMinY ?? 0.0;
  }

  double _getMaxY(double __) {
    if (_cachedInterval == null) _ensureYScale();
    return _cachedMaxY ?? 0.0;
  }

  double _getInterval() {
    if (_cachedInterval == null) _ensureYScale();
    return _cachedInterval!;
  }

  double _xInterval(PeriodType periodType, double minX, double maxX) {
    final safeRange = (maxX - minX).abs().clamp(1.0, double.infinity);
    return safeRange / 6.0; // 6 ticks บนแกน X
  }
}

class _MrTip {
  final Offset local;
  final String valueStr;
  _MrTip({required this.local, required this.valueStr});
}
