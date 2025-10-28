import 'package:flutter_test/flutter_test.dart';
import 'dart:math' as math;

// ======= Copied from your code =======
double? _cachedMinY;
double? _cachedMaxY;
double? _cachedInterval;

double _niceStepCeil(double x) {
  if (x <= 0 || x.isNaN || x.isInfinite) return 1.0;
  final exp = (math.log(x) / math.log(10)).floor();
  final mag = math.pow(10.0, exp).toDouble();
  final mant = x / mag;

  if (mant <= 0.005) return 0.005 * mag;
  if (mant <= 0.01) return 0.01 * mag;
  if (mant <= 0.015) return 0.015 * mag;
  if (mant <= 0.02) return 0.02 * mag;
  if (mant <= 0.025) return 0.025 * mag;
  if (mant <= 0.05) return 0.05 * mag;
  if (mant <= 0.075) return 0.075 * mag;
  if (mant <= 0.1) return 0.1 * mag;
  if (mant <= 0.15) return 0.15 * mag;
  if (mant <= 0.2) return 0.2 * mag;
  if (mant <= 0.25) return 0.25 * mag;
  if (mant <= 0.3) return 0.3 * mag;
  if (mant <= 0.4) return 0.4 * mag;
  if (mant <= 0.5) return 0.5 * mag;
  if (mant <= 0.6) return 0.6 * mag;
  if (mant <= 0.75) return 0.75 * mag;
  if (mant <= 0.8) return 0.8 * mag;
  if (mant <= 0.9) return 0.9 * mag;
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

  if (mant <= 0.005) return 0.01 * mag;
  if (mant <= 0.01) return 0.015 * mag;
  if (mant <= 0.015) return 0.02 * mag;
  if (mant <= 0.02) return 0.025 * mag;
  if (mant <= 0.025) return 0.05 * mag;
  if (mant <= 0.05) return 0.075 * mag;
  if (mant <= 0.075) return 0.1 * mag;
  if (mant <= 0.1) return 0.15 * mag;
  if (mant <= 0.15) return 0.2 * mag;
  if (mant <= 0.2) return 0.25 * mag;
  if (mant <= 0.25) return 0.3 * mag;
  if (mant <= 0.3) return 0.4 * mag;
  if (mant <= 0.4) return 0.5 * mag;
  if (mant <= 0.5) return 0.6 * mag;
  if (mant <= 0.6) return 0.75 * mag;
  if (mant <= 0.75) return 0.8 * mag;
  if (mant <= 0.8) return 0.9 * mag;
  if (mant <= 0.9) return 1.0 * mag;
  if (mant < 1.0) return 1.25 * mag;
  if (mant < 1.25) return 1.5 * mag;
  if (mant < 1.5) return 2.0 * mag;
  if (mant < 2.0) return 2.5 * mag;
  if (mant < 2.5) return 3.0 * mag;
  if (mant < 3.0) return 4.0 * mag;
  if (mant < 5.0) return 5.0 * mag;
  return 10.0 * mag;
}

void _ensureYScale(double minSel, double maxSel) {
  const divisions = 5;

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

// ======= Tests =======
void main() {
  test('Y-scale for min=0.6, max=0.8', () {
    _cachedMinY = null;
    _cachedMaxY = null;
    _cachedInterval = null;

    _ensureYScale(0.6, 0.8);

    expect(_cachedInterval, closeTo(0.05, 1e-9));
    expect(_cachedMinY, closeTo(0.6, 1e-9));
    expect(_cachedMaxY, closeTo(0.85, 1e-9));
  });
}
