import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:flutter/material.dart';

class ViolationsColumn extends StatelessWidget {
  const ViolationsColumn({
    super.key,
    required this.beyondControlLimit, // UCL+LCL
    required this.beyondSpecLimit,    // USL+LSL
    required this.trend,              // R3 (ไม่แสดงตัวเลข)
    this.dotSize = 12,
    this.fontSize = 12,
    this.gap = 8,
  });

  final int beyondControlLimit;
  final int beyondSpecLimit;
  final int trend;

  final double dotSize;
  final double fontSize;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ViolationRow(
            color: Colors.pinkAccent,
            label: 'Trend',
            violated: trend > 0,
            // Trend ไม่แสดงตัวเลข แต่จะยังเว้นคอลัมน์ไว้ให้ alignment ตรง
            showCount: false,
            fontSize: fontSize,
            dotSize: dotSize,
          ),
          SizedBox(height: gap),
          _ViolationRow(
            color: Colors.red,
            label: 'Beyond Spec Limit',
            violated: beyondSpecLimit > 0,
            countText: '$beyondSpecLimit',
            showCount: beyondSpecLimit > 0,
            fontSize: fontSize,
            dotSize: dotSize,
          ),
          SizedBox(height: gap),
          _ViolationRow(
            color: Colors.orange,
            label: 'Beyond Control Limit',
            violated: beyondControlLimit > 0,
            countText: '$beyondControlLimit',
            showCount: beyondControlLimit > 0,
            fontSize: fontSize,
            dotSize: dotSize,
          ),
      
        ],
      ),
    );
  }
}

class _ViolationRow extends StatelessWidget {
  const _ViolationRow({
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

  static const double _dotColWidth = 24;
  static const double _iconColWidth = 20;
  static const double _countColWidth = 32;

  @override
  Widget build(BuildContext context) {
    final icon = violated ? Icons.cancel : Icons.check_circle;
    final iconColor = violated ? AppColors.colorAlert1 : AppColors.colorSuccess1;

    return SizedBox(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dot (with aura + blinking if violated)
          SizedBox(
            width: _dotColWidth,
            child: Center(
              child: _BlinkingDot(
                color: color,
                size: dotSize,
                active: violated,
              ),
            ),
          ),
      
          // Label (flexible instead of fixed width)
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: color, fontSize: fontSize),
            ),
          ),
      
          // Icon
          SizedBox(
            width: _iconColWidth,
            child: Align(
              alignment: Alignment.centerRight,
              child: Icon(icon, size: fontSize + 4, color: iconColor),
            ),
          ),
      
          // Count
          SizedBox(
            width: _countColWidth,
            child: showCount
                ? Align(
                    alignment: Alignment.center,
                    child: Text(
                      countText ?? '',
                      style: TextStyle(
                        fontSize: fontSize,
                        color: violated ? AppColors.colorBlack : Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _BlinkingDot extends StatefulWidget {
  final Color color;
  final double size;
  final bool active;

  const _BlinkingDot({
    required this.color,
    required this.size,
    required this.active,
  });

  @override
  State<_BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<_BlinkingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) {
      // Static dot if not violated
      return Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      );
    }

    return ScaleTransition(
      scale: Tween(begin: 0.4, end: 2.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: 0.6),
              blurRadius: 8,
              spreadRadius: 4,
            ),
          ],
        ),
      ),
    );
  }
}

