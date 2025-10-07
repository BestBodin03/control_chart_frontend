import 'package:flutter/material.dart';
import '../../design_system/app_color.dart';
import 'selector/layout_selector.dart';
import 'selector/period_selector.dart';

class DisplaySelector extends StatefulWidget {
  const DisplaySelector({
    super.key,
    this.onPeriodChanged,
    this.onLayoutChanged,
    this.initialPeriod = '1W',   // <-- default short code
    this.initialLayout = 1,      // 1=Single, 2=Double
  });

  final ValueChanged<String>? onPeriodChanged; // receives '1D'|'1W'|'1M'|'2M'
  final ValueChanged<int>? onLayoutChanged;    // receives 1 or 2
  final String initialPeriod;
  final int initialLayout;

  @override
  State<DisplaySelector> createState() => _DisplaySelectorState();
}

class _DisplaySelectorState extends State<DisplaySelector> {
  late String selectedPeriodShort;
  late int selectedLayout;

  @override
  void initState() {
    super.initState();
    selectedPeriodShort = widget.initialPeriod; // already short
    selectedLayout = widget.initialLayout;
    debugPrint('[DisplaySelector] init period=$selectedPeriodShort layout=$selectedLayout');
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
        children: [
          PeriodSelector(
            selectedPeriod: selectedPeriodShort,
            onChanged: (short) {
              setState(() => selectedPeriodShort = short);
              debugPrint('[DisplaySelector] period changed → $short');
              widget.onPeriodChanged?.call(short);
            },
          ),
          const SizedBox(height: 8),
          LayoutSelector(
            selectedLayout: selectedLayout,
            onChanged: (value) {
              setState(() => selectedLayout = value); // 1 or 2
              debugPrint('[DisplaySelector] layout changed → $value');
              widget.onLayoutChanged?.call(value);
            },
          ),
        ],
      ),
    );
  }
}
