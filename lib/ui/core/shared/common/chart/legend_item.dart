import 'package:flutter/material.dart';
import '../../../design_system/app_color.dart';

Widget legendItem(BuildContext context, String label, Color color, String value) {
  final media = MediaQuery.of(context);
  final textScaler = media.textScaler;

  final double baseFontSize = 10;

  // ✅ dynamically scaled font using TextScaler
  final double scaledSize = textScaler.scale(baseFontSize);

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
          fontSize: scaledSize,
          color: AppColors.colorBlack,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(width: 4),
      Text(
        value,
        style: TextStyle(
          fontSize: scaledSize,
          color: AppColors.colorBlack,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}
