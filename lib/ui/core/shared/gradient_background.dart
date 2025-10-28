import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color> colors;
  final AlignmentGeometry center;
  final double radius;
  final double opacity; 

  const GradientBackground({
    super.key,
    required this.child,
    this.colors = const [
      Color.fromARGB(255, 189, 219, 255),
      AppColors.colorBg,
    ],
    this.center = Alignment.center,
    this.radius = 0.5,
    this.opacity = 0.5
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: center,
          radius: radius,
          colors: colors.map((color) => color.withValues(alpha: opacity)).toList(),
          tileMode: TileMode.clamp,
          stops: const [0.0, 1.0],
        ),
      ),
      child: child,
    );
  }
}