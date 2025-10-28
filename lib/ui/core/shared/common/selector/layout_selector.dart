import 'package:flutter/material.dart';
import '../../../design_system/app_color.dart';
import 'selector_button.dart';

class LayoutSelector extends StatelessWidget {
  const LayoutSelector({
    super.key,
    required this.selectedLayout,
    this.onChanged,
  });

  final int selectedLayout;
  final ValueChanged<int>? onChanged;

  static const _layouts = [
    {'label': 'Double', 'icon': Icons.dns_rounded, 'value': 2},
    {'label': 'Single', 'icon': Icons.fullscreen, 'value': 1},
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      children: _layouts.map((l) {
        final isSelected = selectedLayout == l['value'];
        return SelectorButton(
          label: l['label'] as String,
          icon: l['icon'] as IconData,
          isSelected: isSelected,
          onTap: () => onChanged?.call(l['value'] as int),
          color: AppColors.colorBrand,
        );
      }).toList(),
    );
  }
}
