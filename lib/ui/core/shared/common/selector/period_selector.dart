import 'package:flutter/material.dart';
import '../../../design_system/app_color.dart';
import 'selector_button.dart';

class PeriodSelector extends StatelessWidget {
  const PeriodSelector({
    super.key,
    required this.selectedPeriod,
    this.onChanged,
  });

  final String selectedPeriod;
  final ValueChanged<String>? onChanged;

  static const _periods = [
    {'label': '1 Week', 'short': '1W', 'value': '1 Week'},
    {'label': '2 Weeks', 'short': '2W', 'value': '2 weeks'},
    {'label': '1 Month', 'short': '1M', 'value': '1 month'},
    {'label': '2 Months', 'short': '2M', 'value': '2 months'},
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      children: _periods.map((p) {
        final isSelected = selectedPeriod == p['value'];
        return SelectorButton(
          label: p['short'] as String,
          isSelected: isSelected,
          onTap: () => onChanged?.call(p['value'] as String),
          color: AppColors.colorBrand,
        );
      }).toList(),
    );
  }
}
