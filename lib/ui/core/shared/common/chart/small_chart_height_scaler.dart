import 'package:flutter/material.dart';

double responsiveChartHeight(BuildContext context) {
  // Map screen width [1280..1920] -> height [144..248], clamp outside.
  const double minW = 1280, maxW = 1920;
  const double minH = 144,  maxH = 248;

  final double w = MediaQuery.sizeOf(context).width;
  final double t = ((w - minW) / (maxW - minW)).clamp(0.0, 1.0);
  return minH + t * (maxH - minH);
}