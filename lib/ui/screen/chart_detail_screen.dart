import 'package:control_chart/ui/screen/screen_content/chart_detail_screen_content/chart_detail_content.dart';
import 'package:flutter/material.dart';

class ChartDetailScreen extends StatelessWidget {
  const ChartDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChartDetailScreenBody();
  }
}

class ChartDetailScreenBody extends StatelessWidget {
  const ChartDetailScreenBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ChartDetailContent();
  }
}
