import 'package:flutter/material.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';

class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    this.labelSize,
    this.leading,
    this.selected = false,
    this.solid = false,
    this.bg,
    this.onTap, // ✅ nullable ตามวิธี A
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    this.radius = 999,
  });

  final String label;
  final double? labelSize;
  final IconData? leading;
  final bool selected;
  final bool solid;
  final Color? bg;
  final VoidCallback? onTap; // ✅ เปลี่ยนเป็น VoidCallback?
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final bool disabled = onTap == null;

    // สีพื้นฐาน
    final Color baseBg = bg ??
        (selected
            ? AppColors.colorBrand
            : AppColors.colorBrandTp);

    // โทนพื้น/ขอบตามโหมด
    final Color background =
        solid ? baseBg : Colors.transparent;
    final Color borderColor =
        solid ? baseBg : (bg ?? AppColors.colorBrand);
    final Color fgColor =
        solid ? Colors.white : (bg != null ? bg!.computeLuminance() < 0.5 ? Colors.white : AppColors.colorBrand : AppColors.colorBrand);

    return Opacity(
      opacity: disabled ? 0.6 : 1,
      child: Material(
        color: background,
        shape: StadiumBorder(side: BorderSide(color: borderColor, width: 1)),
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onTap, // ✅ ส่ง null ได้
          child: Padding(
            padding: padding,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leading != null) ...[
                  Icon(leading, size: 18, color: fgColor),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: labelSize ?? 13,
                    fontWeight: FontWeight.w600,
                    color: fgColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
