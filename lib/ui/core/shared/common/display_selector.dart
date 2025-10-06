import 'package:flutter/material.dart';
import '../../design_system/app_color.dart';
import 'selector/layout_selector.dart';
import 'selector/period_selector.dart';

class DisplaySelector extends StatefulWidget {
  const DisplaySelector({
    super.key,
    this.onPeriodChanged,
    this.onLayoutChanged,
    this.initialPeriod = '1 Week',
    this.initialLayout = 1,
  });

  final ValueChanged<String>? onPeriodChanged;
  final ValueChanged<int>? onLayoutChanged;
  final String initialPeriod;
  final int initialLayout;

  @override
  State<DisplaySelector> createState() => _DisplaySelectorState();
}

class _DisplaySelectorState extends State<DisplaySelector> {
  late String selectedPeriod;
  late int selectedLayout;

  @override
  void initState() {
    super.initState();
    selectedPeriod = widget.initialPeriod;
    selectedLayout = widget.initialLayout;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.colorBrandTp.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PeriodSelector(
            selectedPeriod: selectedPeriod,
            onChanged: (value) {
              setState(() => selectedPeriod = value);
              widget.onPeriodChanged?.call(value);
            },
          ),
          const SizedBox(height: 8),
          LayoutSelector(
            selectedLayout: selectedLayout,
            onChanged: (value) {
              setState(() => selectedLayout = value);
              widget.onLayoutChanged?.call(value);
            },
          ),
        ],
      ),
    );
  }
}
