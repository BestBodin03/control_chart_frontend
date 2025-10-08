import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:flutter/material.dart';

import 'common/chart/font_scaler.dart';

class ViolationForDashboard extends StatelessWidget {
  const ViolationForDashboard({
    super.key,
    // Split counts (required)
    required this.overCtrlUpper,
    required this.overCtrlLower,
    required this.overSpecUpper,
    required this.overSpecLower,

    // Trend row
    required this.trend,

    // Optional legacy combined totals (not used when split is present)
    this.combinedControlLimit,
    this.combinedSpecLimit,

    this.dotSize = 12,
    this.fontSize = 12,
    this.gap = 8,
    this.pillHeight = 20,
    this.pillRadius = 999,
  });

  // Split counts
  final int overCtrlUpper;
  final int overCtrlLower;
  final int overSpecUpper;
  final int overSpecLower;

  // Trend
  final int trend;

  // (Optional) legacy combined totals for backward-compat display if needed
  final int? combinedControlLimit;
  final int? combinedSpecLimit;

  final double dotSize;
  final double fontSize;
  final double gap;
  final double pillHeight;
  final double pillRadius;

  @override
  Widget build(BuildContext context) {
    final int specTotal = overSpecUpper + overSpecLower;
    final int ctrlTotal = overCtrlUpper + overCtrlLower;

    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ViolationRow(
            color: Colors.red,
            label: 'Over Spec',
            violated: specTotal > 0,
            fontSize: fontScaler(context, fontSize),
            dotSize: dotSize,
            splitPills: _SplitPillsData(
              upper: overSpecUpper,
              lower: overSpecLower,
              pillHeight: pillHeight,
              pillRadius: pillRadius,
              upperIcon: Icons.arrow_upward,
              lowerIcon: Icons.arrow_downward,
            ),
            // Fallback to combined text if desired (unused because split is present)
            countText: combinedSpecLimit?.toString(),
          ),
          SizedBox(height: gap),
          _ViolationRow(
            color: Colors.orange,
            label: 'Over Control',
            violated: ctrlTotal > 0,
            fontSize: fontScaler(context, fontSize),
            dotSize: dotSize,
            splitPills: _SplitPillsData(
              upper: overCtrlUpper,
              lower: overCtrlLower,
              pillHeight: pillHeight,
              pillRadius: pillRadius,
              upperIcon: Icons.north,
              lowerIcon: Icons.south,
            ),
            countText: combinedControlLimit?.toString(),
          ),
          SizedBox(height: gap),
          _ViolationRow(
            color: Colors.pinkAccent,
            label: 'Trend',
            violated: trend > 0,
            fontSize: fontScaler(context, fontSize),
            dotSize: dotSize,
            showCount: false,
          ),
        ],
      ),
    );
  }
}

class _SplitPillsData {
  final int upper;
  final int lower;
  final double pillHeight;
  final double pillRadius;
  final IconData upperIcon;
  final IconData lowerIcon;

  const _SplitPillsData({
    required this.upper,
    required this.lower,
    required this.pillHeight,
    required this.pillRadius,
    required this.upperIcon,
    required this.lowerIcon,
  });
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
    this.splitPills,
  });

  final Color color;
  final String label;
  final bool violated;
  final String? countText;
  final bool showCount;
  final double fontSize;
  final double dotSize;

  /// If provided, renders U/L pills on the same row.
  final _SplitPillsData? splitPills;

  static const double _dotColWidth = 24;  // keep small fixed widths only for dot/icon
  static const double _iconColWidth = 16;

  @override
  Widget build(BuildContext context) {
    final icon = violated ? Icons.cancel : Icons.check_circle;
    final iconColor = violated ? AppColors.colorAlert1 : AppColors.colorSuccess1;

    return Column(
      mainAxisSize: MainAxisSize.min, // ⬅️ shrink-wrap vertically
      children: [
        // First row (dot | label | status icon)
        Row(
          children: [
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

            // Label expands horizontally within the Row (this is OK)
            Text(
              label,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.fade,
              style: TextStyle(color: color, fontSize: fontSize, fontWeight: FontWeight.bold),
            ),

            const Spacer(),
            SizedBox(
              width: _iconColWidth,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Icon(icon, size: fontScaler(context, fontSize) + 4, color: iconColor),
              ),
            ),
          ],
        ),

        if (showCount)
        const SizedBox(height: 8),

        // Second line (pills or count) — no Flexible here
        Align(
          alignment: Alignment.centerLeft,
          child: (splitPills != null)
              ? _HorizontalPills(color: color, fontSize: fontScaler(context, fontSize), data: splitPills!)
              : (showCount
                  ? Text(
                      countText ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: fontScaler(context, fontSize),
                        color: violated ? AppColors.colorBlack : Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : const SizedBox.shrink()),
        ),
      ],
    );
  }
}


class _HorizontalPills extends StatelessWidget {
  const _HorizontalPills({
    required this.color,
    required this.fontSize,
    required this.data,
  });

  final Color color;
  final double fontSize;
  final _SplitPillsData data;

  @override
  Widget build(BuildContext context) {
    final bg = color.withValues(alpha: 0.12);
    final border = color.withValues(alpha: 0.35);
    final textColor = color;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PillBadge(
          bg: bg,
          border: border,
          icon: data.upperIcon,
          label: 'U',
          value: data.upper,
          fontSize: fontScaler(context, fontSize),
          height: data.pillHeight,
          radius: data.pillRadius,
          textColor: textColor,
        ),
        const SizedBox(width: 6),
        _PillBadge(
          bg: bg,
          border: border,
          icon: data.lowerIcon,
          label: 'L',
          value: data.lower,
          fontSize: fontScaler(context, fontSize),
          height: data.pillHeight,
          radius: data.pillRadius,
          textColor: textColor,
        ),
      ],
    );
  }
}

class _PillBadge extends StatelessWidget {
  const _PillBadge({
    required this.bg,
    required this.border,
    required this.icon,
    required this.label,
    required this.value,
    required this.fontSize,
    required this.height,
    required this.radius,
    required this.textColor,
  });

  final Color bg;
  final Color border;
  final IconData icon;
  final String label;
  final int value;
  final double fontSize;
  final double height;
  final double radius;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: fontSize * 0.95, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: fontScaler(context, fontSize),
              color: textColor,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$value',
            style: TextStyle(
              fontSize: fontScaler(context, fontSize),
              color: AppColors.colorBlack,
              fontWeight: FontWeight.w700,
            ),
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
    )..repeat(reverse: true); // blinking is back
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) {
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
