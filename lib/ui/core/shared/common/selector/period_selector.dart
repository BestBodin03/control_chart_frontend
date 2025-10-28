import 'package:control_chart/ui/core/shared/common/selector/selector_button.dart';
import 'package:flutter/material.dart';

import '../../../design_system/app_color.dart';

class PeriodSelector extends StatelessWidget {
  const PeriodSelector({
    super.key,
    required this.selectedPeriod,    // can be '1D','1W','1M','2M'
    this.onChanged,
  });

  final String selectedPeriod;       // short code
  final ValueChanged<String>? onChanged;

  static const _periods = [
    {'label': '1 Day',    'short': '1D'},
    {'label': '1 Week',   'short': '1W'},
    {'label': '1 Month',  'short': '1M'},
    {'label': '2 Months', 'short': '2M'},
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      children: _periods.map((p) {
        final short = p['short'] as String;
        final isSelected = selectedPeriod == short; // compare by short
        return SelectorButton(
          label: short,                     // button shows short code
          isSelected: isSelected,
          onTap: () => onChanged?.call(short), // <-- send short code upwards
          color: AppColors.colorBrand,
        );
      }).toList(),
    );
  }
}
