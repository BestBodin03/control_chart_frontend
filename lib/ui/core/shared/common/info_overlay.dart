import 'package:flutter/material.dart';

class InfoOverlay extends StatelessWidget {
  const InfoOverlay({
    super.key,
    required this.child,
    this.onClose,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor = const Color(0x66000000), // black 40% opacity
    this.borderRadius = 16.0,
  });

  final Widget child;
  final VoidCallback? onClose;
  final EdgeInsets padding;
  final Color backgroundColor;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // translucent backdrop
        Positioned.fill(
          child: GestureDetector(
            onTap: onClose,
            child: Container(color: backgroundColor),
          ),
        ),

        // centered content
        Center(
          child: Padding(
            padding: padding,
            child: Material(
              color: Colors.white,
              elevation: 8,
              borderRadius: BorderRadius.circular(borderRadius),
              clipBehavior: Clip.antiAlias,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                padding: const EdgeInsets.all(16),
                child: child,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
