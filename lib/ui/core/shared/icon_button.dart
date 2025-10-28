import 'package:flutter/material.dart';

class IconButton extends StatelessWidget {
  const IconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.size = 18.0,
    this.iconColor = const Color(0xFF334155), // slate-700ish
    this.backgroundColor = Colors.transparent,
    this.padding = const EdgeInsets.all(6),
    this.borderRadius = 10,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  final double size;
  final Color iconColor;
  final Color backgroundColor;
  final EdgeInsets padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: Padding(
              padding: padding,
              child: Icon(icon, size: size, color: iconColor),
            ),
          ),
        ),
      ),
    );
  }
}