import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:flutter/material.dart';

class ViolationsRow extends StatelessWidget {
  const ViolationsRow({
    super.key,
    required this.beyondControlLimit, // UCL+LCL
    required this.beyondSpecLimit,    // USL+LSL
    required this.trend,              // R3 (ไม่มีตัวเลขแสดง)
    this.dotSize = 8,
    this.fontSize = 12,
    this.gap = 12,
  });

  final int beyondControlLimit;
  final int beyondSpecLimit;
  final int trend;

  final double dotSize;
  final double fontSize;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: gap,
      runSpacing: gap / 2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _ViolationTile(
          color: Colors.red,
          label: 'Beyond Spec Limit',
          violated: beyondSpecLimit > 0,
          countText: '$beyondSpecLimit',
          showCount: beyondSpecLimit > 0,
          fontSize: fontSize,
          dotSize: dotSize,
        ),
        _ViolationTile(
          color: Colors.orange,
          label: 'Beyond Control Limit',
          violated: beyondControlLimit > 0,
          countText: '$beyondControlLimit',
          showCount: beyondControlLimit > 0,
          fontSize: fontSize,
          dotSize: dotSize,
        ),
        _ViolationTile(
          color: Colors.pinkAccent,
          label: 'Trend',
          violated: trend > 0,
          // ❗ Trend ไม่แสดงตัวเลข
          showCount: false,
          fontSize: fontSize,
          dotSize: dotSize,
        ),
      ],
    );
  }
}

class _ViolationTile extends StatelessWidget {
  const _ViolationTile({
    required this.color,
    required this.label,
    required this.violated,
    required this.fontSize,
    required this.dotSize,
    this.countText,
    this.showCount = true,
  });

  final Color color;
  final String label;
  final bool violated;
  final String? countText;
  final bool showCount;
  final double fontSize;
  final double dotSize;

  @override
  Widget build(BuildContext context) {
    final icon = violated ? Icons.cancel : Icons.check_circle;
    final iconColor = violated ? AppColors.colorAlert1 : AppColors.colorSuccess1;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // • จุดสี
        Container(
          width: dotSize,
          height: dotSize,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        // ข้อความ
        Text(
          label,
          style: TextStyle(color: color, fontSize: fontSize),
          textAlign: TextAlign.center,
        ),
        const SizedBox(width: 6),
        // ไอคอนถูก/ผิด
        Icon(icon, size: fontSize + 4, color: iconColor),
        // จำนวน (ยกเว้น Trend)
        if (showCount) ...[
          const SizedBox(width: 4),
          Text(
            countText ?? '',
            style: TextStyle(
              fontSize: fontSize,
              color: violated ? color : Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
