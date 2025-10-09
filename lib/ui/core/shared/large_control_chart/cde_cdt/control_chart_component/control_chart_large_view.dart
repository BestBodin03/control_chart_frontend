// lib/ui/core/shared/large_control_chart/control_chart_large_view.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';

class ControlChartLargeView extends StatelessWidget {
  final Size chartSize;
  final LineChartData data;
  final Widget? tooltipOverlay; // position-calculated overlay from connector

  const ControlChartLargeView({
    super.key,
    required this.chartSize,
    required this.data,
    this.tooltipOverlay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: chartSize.height,
      width: chartSize.width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: LineChart(data),
          ),
          if (tooltipOverlay != null) tooltipOverlay!,
        ],
      ),
    );
  }
}

/// A tiny tooltip content view (you can reuse your existing one)
class TooltipContent extends StatelessWidget {
  final String title;
  final List<MapEntry<String, String>> rows;
  final List<MapEntry<String, String>> chips; // label -> colorName
  final Color accent;

  const TooltipContent({
    super.key,
    required this.title,
    required this.rows,
    this.chips = const [],
    this.accent = Colors.blueAccent,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: AppTypography.textBody4W,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.textBody4WBold),
          const SizedBox(height: 4),
          ...rows.map((e) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(e.key, style: AppTypography.textBody4WBold),
                  Text(e.value, style: AppTypography.textBody4W),
                ],
              )),
          if (chips.isNotEmpty) ...[
            const SizedBox(height: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: chips.map((c) {
                final color = switch (c.value) {
                  'pink' => Colors.pinkAccent,
                  'red' => Colors.red,
                  'orange' => Colors.orange,
                  _ => AppColors.colorBrand,
                };
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color),
                  ),
                  child: Text(c.key, style: AppTypography.textBody4W),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 6),
          Container(height: 2, color: accent),
        ],
      ),
    );
  }
}
