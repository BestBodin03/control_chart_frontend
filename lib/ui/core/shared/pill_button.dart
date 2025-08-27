
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:flutter/material.dart';

class PillButton extends StatelessWidget {
  const PillButton({super.key, 
    required this.label,
    required this.onTap,
    required this.labelSize,
    this.selected = false,
    this.solid = false,
    this.bg = AppColors.colorBrand,
    this.leading,
  });

  final String label;
  final VoidCallback onTap;
  final double labelSize;
  final bool selected;
  final bool solid;
  final Color? bg;
  final IconData? leading;

  @override
  Widget build(BuildContext context) {
    // final bg = solid
    //     ? (selected ? AppColors.colorBrand : const Color(0xFFEFF6FF))
    //     : const Color(0xFFEFF6FF);
    final fg = solid
        ? Colors.white
        : (selected ? const Color(0xFF1D4ED8) : const Color(0xFF1D4ED8));
    final ring = solid ? Colors.transparent : const Color(0xFFBFDBFE);

    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: ring),
          boxShadow: solid
              ? const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              if (leading != null) ...[
                Icon(leading, size: 16, color: fg),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(fontWeight: FontWeight.bold, color: fg, fontSize: labelSize),
                    
              ),
            ],
          ),
        ),
      ),
    );
  }
}