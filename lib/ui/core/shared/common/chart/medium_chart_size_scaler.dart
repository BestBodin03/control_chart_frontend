import 'package:flutter/material.dart';

double mediumChartSizeScaler(BuildContext context) {
  // Map screen width [1280..1920] -> reserve [120..144], clamped outside.
  const double minW = 1280, maxW = 1920;
  const double minR = 124.0, maxR = 172.0;

  final double w = MediaQuery.sizeOf(context).width;
  final double t = ((w - minW) / (maxW - minW)).clamp(0.0, 1.0);
  return minR + t * (maxR - minR);
}
