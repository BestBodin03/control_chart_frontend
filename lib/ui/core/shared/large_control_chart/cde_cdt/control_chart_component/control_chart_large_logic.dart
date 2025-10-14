
import 'dart:math' as math;

import '../../../small_control_chart/small_control_chart_var.dart';

/// ====== INPUT MODELS ======
class XWindow {
  final double minX;
  final double maxX;
  final int desiredTicks; // e.g., 6
  const XWindow({required this.minX, required this.maxX, this.desiredTicks = 6});
}

class YAxisSpec {
  final double minSel;   // selected-series min (from stats)
  final double maxSel;   // selected-series max (from stats)
  final double? lsl;     // spec lower
  final double? usl;     // spec upper
  final double? lcl;     // control lower
  final double? ucl;     // control upper

  const YAxisSpec({
    required this.minSel,
    required this.maxSel,
    this.lsl,
    this.usl,
    this.lcl,
    this.ucl,
  });
}

class SeriesPoint {
  final double x;                 // msSinceEpoch.toDouble()
  final double y;
  final bool isR3;                // trend
  final bool beyondUSL, beyondLSL;
  final bool beyondUCL, beyondLCL;
  final String? title;            // fullLabel
  final String? fgNo;

  const SeriesPoint({
    required this.x,
    required this.y,
    this.isR3 = false,
    this.beyondUSL = false,
    this.beyondLSL = false,
    this.beyondUCL = false,
    this.beyondLCL = false,
    this.title,
    this.fgNo,
  });
}

/// ====== OUTPUT MODELS ======
class YScaleResult {
  final double minY;
  final double maxY;
  final double interval; // tick interval (divisions between minY..maxY)
  const YScaleResult({
    required this.minY, 
    required this.maxY, 
    required this.interval});
}

class SegmentsResult {
  final List<List<SeriesPoint>> r3Segments;
  final List<List<SeriesPoint>> nonR3Segments;
  final List<List<SeriesPoint>> bridgeSegments;
  final List<SeriesPoint> orderedPoints; // all points sorted by x
  const SegmentsResult({
    required this.r3Segments,
    required this.nonR3Segments,
    required this.bridgeSegments,
    required this.orderedPoints,
  });
}

class TooltipModel {
  final String title;
  final List<MapEntry<String, String>> rows;
  final List<MapEntry<String, String>> chips; // label -> colorName (UI maps later)
  const TooltipModel({
    required this.title, 
    required this.rows, 
    required this.chips});
}

double _niceStepCeil(double x) {
  int l = 0, r = niceSteps.length - 1;
  while (l < r) {
    final m = (l + r) >> 1;
    if (niceSteps[m] >= x) {
      r = m;
    } else {
      l = m + 1;
    }
  }
  return niceSteps[l];
}

double _nextNiceStep(double step) {
  int l = 0, r = niceSteps.length - 1;
  while (l < r) {
    final m = (l + r) >> 1;
    if (niceSteps[m] > step) {
      r = m;
    } else {
      l = m + 1;
    }
  }
  return niceSteps[l];
}

/// ====== CORE LOGIC ======
class ControlChartLargeLogic {
  /// Window filter
  List<SeriesPoint> filterPointsInWindow(List<SeriesPoint> src, XWindow w) {
    if (src.isEmpty) return const <SeriesPoint>[];
    final lo = math.min(w.minX, w.maxX);
    final hi = math.max(w.minX, w.maxX);
    return src.where((p) => p.x >= lo && p.x <= hi).toList()
      ..sort((a, b) => a.x.compareTo(b.x));
  }

  /// X-axis interval from desired ticks
  double xInterval(XWindow w) {
    final safeRange = (w.maxX - w.minX).abs().clamp(1.0, double.infinity);
    final ticks = w.desiredTicks.clamp(2, 100);
    return safeRange / (ticks - 1);
  }

/// Compute nice Y-scale with 5 divisions and avoid collisions with spec/control lines.
/// Behaves *exactly* like `_ensureYScale` logic, even for small ranges (e.g. 0.4–0.9).
YScaleResult computeYScale(YAxisSpec spec, {int divisions = 5}) {
  // --- 1) Extract min/max selection ---
  final double minSel = spec.minSel ?? 0.0;
  final double maxSel = (spec.maxSel == null || spec.maxSel! <= minSel)
      ? minSel
      : spec.maxSel!;

  // --- 2) Flat fallback ---
  if (maxSel <= minSel) {
    final minY = minSel;
    final maxY = minSel + divisions;
    return YScaleResult(minY: minY, maxY: maxY, interval: 1.0);
  }

  // --- 3) Pick "nice" initial interval ---
  final ideal = (maxSel - minSel) / divisions;
  double interval = _niceStepCeil(ideal);

  // Track tried intervals to prevent infinite loops
  final Set<double> triedIntervals = {interval};

  // --- 4) Align min to interval ---
  double minY = (minSel / interval).floor() * interval;
  double maxY = minY + divisions * interval;

  // --- 5) Ensure we fully cover maxSel ---
  const epsilon = 1e-9;
  
  while (maxY < maxSel - epsilon) {
    final oldInterval = interval;
    interval = _nextNiceStep(interval);
    
    // Check if we reached the end of niceSteps
    if (interval == oldInterval || interval >= niceSteps.last) {
      // Can't increase interval anymore, extend maxY instead
      maxY = maxSel + interval;
      break;
    }
    
    minY = (minSel / interval).floor() * interval;
    maxY = minY + divisions * interval;
  }

  // --- 6) Get spec/control limits ---
  final lsl = spec.lsl;
  final usl = spec.usl;
  final lcl = spec.lcl;
  final ucl = spec.ucl;

  final checkValues = <double?>[lsl, usl, lcl, ucl];

  // --- 7) Adjust to avoid collisions with boundaries ---
  bool hasCollision = true;
  
  while (hasCollision) {
    hasCollision = false;
    
    for (final val in checkValues) {
      if (val == null) continue;

      // Check if value collides with minY or maxY
      if ((val - minY).abs() < epsilon || (val - maxY).abs() < epsilon) {
        // Try next interval
        final oldInterval = interval;
        interval = _nextNiceStep(interval);
        
        // Check if we've exhausted interval options
        if (triedIntervals.contains(interval) || 
            interval == oldInterval || 
            interval >= niceSteps.last) {
          // Can't find better interval, keep current one
          // debugPrint('⚠️ Cannot avoid collision for value $val, keeping interval $interval');
          hasCollision = false;
          break;
        }
        
        triedIntervals.add(interval);
        // debugPrint('Collision detected with $val, trying interval: $interval');
        
        // Recalculate with new interval
        minY = (minSel / interval).floor() * interval;
        maxY = minY + divisions * interval;
        
        // Ensure coverage again
        while (maxY < maxSel - epsilon) {
          final coverageInterval = _nextNiceStep(interval);
          if (coverageInterval == interval || coverageInterval >= niceSteps.last) {
            maxY = maxSel + interval;
            break;
          }
          interval = coverageInterval;
          triedIntervals.add(interval);
          minY = (minSel / interval).floor() * interval;
          maxY = minY + divisions * interval;
        }
        
        hasCollision = true;
        break;
      }
    }
  }

  // --- 8) Snap to multiples to remove drift ---
  double _snap(double val, double step) => (val / step).roundToDouble() * step;
  minY = _snap(minY, interval);
  maxY = minY + divisions * interval;

  return YScaleResult(minY: minY, maxY: maxY, interval: interval);
}




  /// Split points into contiguous R3 / non-R3 segments, plus bridge segments
  SegmentsResult splitSegments(List<SeriesPoint> ordered) {
    if (ordered.isEmpty) {
      return const SegmentsResult(
        r3Segments: [],
        nonR3Segments: [],
        bridgeSegments: [],
        orderedPoints: [],
      );
    }

    final r3Segments = <List<SeriesPoint>>[];
    final nonR3Segments = <List<SeriesPoint>>[];
    final bridgeSegments = <List<SeriesPoint>>[];

    var cur = <SeriesPoint>[];
    bool? curIsR3;

    for (final p in ordered) {
      if (cur.isEmpty) {
        cur.add(p);
        curIsR3 = p.isR3;
      } else if (curIsR3 == p.isR3) {
        cur.add(p);
      } else {
        (curIsR3 == true ? r3Segments : nonR3Segments).add(cur);
        cur = <SeriesPoint>[p];
        curIsR3 = p.isR3;
      }
    }
    if (cur.isNotEmpty) {
      (curIsR3 == true ? r3Segments : nonR3Segments).add(cur);
    }

    // Bridges: connect neighbor boundaries around each R3 segment if exist
    final indexByX = <double, int>{for (var i = 0; i < ordered.length; i++) ordered[i].x: i};
    for (final seg in r3Segments) {
      if (seg.isEmpty) continue;
      final firstIdx = indexByX[seg.first.x]!;
      final lastIdx  = indexByX[seg.last.x]!;
      if (firstIdx - 1 >= 0) bridgeSegments.add([ordered[firstIdx - 1], seg.first]);
      if (lastIdx + 1 < ordered.length) bridgeSegments.add([seg.last, ordered[lastIdx + 1]]);
    }

    return SegmentsResult(
      r3Segments: r3Segments,
      nonR3Segments: nonR3Segments,
      bridgeSegments: bridgeSegments,
      orderedPoints: ordered,
    );
  }

  /// Build tooltip model for a nearest point
  TooltipModel buildTooltip(SeriesPoint nearest, double hoveredY) {
    final chips = <MapEntry<String, String>>[
      if (nearest.isR3) const MapEntry('Trend', 'pink'),
      if (nearest.beyondLSL) const MapEntry('Over Spec (L)', 'red'),
      if (nearest.beyondUSL) const MapEntry('Over Spec (U)', 'red'),
      if (nearest.beyondLCL) const MapEntry('Over Control (L)', 'orange'),
      if (nearest.beyondUCL) const MapEntry('Over Control (U)', 'orange'),
    ];
    return TooltipModel(
      title: nearest.title ?? '',
      rows: [
        MapEntry('Value', hoveredY.toStringAsFixed(3)),
        MapEntry('FG No.', nearest.fgNo ?? '-'),
      ],
      chips: chips,
    );
  }

  /// Find nearest point by X from a set (assumes ordered by x)
  SeriesPoint nearestByX(List<SeriesPoint> ordered, double x) {
    if (ordered.isEmpty) throw StateError('No points');
    // binary search for closest index
    int lo = 0, hi = ordered.length - 1;
    while (lo < hi) {
      final mid = (lo + hi) >> 1;
      if (ordered[mid].x < x) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    // lo is first >= x; consider lo and lo-1
    if (lo == 0) return ordered[0];
    final prev = ordered[lo - 1];
    final cur  = ordered[lo];
    return (x - prev.x).abs() <= (cur.x - x).abs() ? prev : cur;
  }
}
