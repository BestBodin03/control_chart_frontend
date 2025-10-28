import 'package:flutter/material.dart';

import '../../design_system/app_color.dart';

Color getViolationBgColor(int overControlLower, int overControlUpper, 
int overSpecLower, int overSpecUpper, int trend) {
  if (overSpecUpper > 0 || overSpecLower > 0) {
    return Colors.red;
    // return Colors.pink.shade200.withValues(alpha: 0.15);
  } else if (overControlUpper > 0 || overControlLower > 0) {
    return Colors.orange;
    // return Colors.red.shade200.withValues(alpha: 0.15);
  } else if (trend > 0) {
    return Colors.pink;
  }
  return AppColors.colorBrandTp;
}

// Decide border color in same hierarchy
Color getViolationBorderColor(int overControlLower, int overControlUpper, 
int overSpecLower, int overSpecUpper, int trend) {
  if (overSpecUpper > 0 || overSpecLower > 0) {
    return Colors.red;
    // return Colors.pink.shade200.withValues(alpha: 0.15);
  } else if (overControlUpper > 0 || overControlLower > 0) {
    return Colors.orange;
    // return Colors.red.shade200.withValues(alpha: 0.15);
  } else if (trend > 0) {
    return Colors.pinkAccent;
  }
  return AppColors.colorBrandTp;
}