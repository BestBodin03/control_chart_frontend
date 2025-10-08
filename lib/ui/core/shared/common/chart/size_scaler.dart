// Map screen width [1280..1920] -> scale [1.0..1.5], clamped outside.
import 'package:flutter/material.dart';

double axisSpaceScale(BuildContext context) {
  const double minW = 1280, maxW = 1920;
  const double minS = 1.0,  maxS = 1.5;

  final double w = MediaQuery.sizeOf(context).width;
  final double t = ((w - minW) / (maxW - minW)).clamp(0.0, 1.0);
  return minS + t * (maxS - minS);
}

// Use axisSpaceScale (*1.5 at 1920) + ALSO respect accessibility text scale.
double sizeScaler(BuildContext context, double base, double scale) {
  // Respect user/system text scaling first
  final double textScaled = MediaQuery.textScalerOf(context).scale(base);

  // Use the explicit scale you pass in (no axis/width dependency)
  final double s = (scale.isFinite && scale > 0) ? scale : 1.0;

  return textScaled * s;
}

