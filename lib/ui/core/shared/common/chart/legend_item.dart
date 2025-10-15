import 'package:control_chart/ui/core/shared/common/chart/font_scaler.dart';
import 'package:flutter/material.dart';
import '../../../design_system/app_color.dart';

Widget legendItem(BuildContext context, String label, Color color, String value) {

  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(
        width: 8,
        height: 4,
        child: DecoratedBox(decoration: BoxDecoration(color: color)),
      ),
      const SizedBox(width: 4),
      Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.colorBlack,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(width: 4),
      Text(
        value,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.colorBlack,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}
