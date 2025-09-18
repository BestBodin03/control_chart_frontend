import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/shared/form_component.dart';
import 'package:control_chart/ui/core/shared/pill_button.dart';
import 'package:flutter/material.dart';

class ImportPage extends StatelessWidget {
  const ImportPage({
    super.key,
    // เดิม
    required this.fileName,
    required this.onPickFile,
    required this.dropdown1,
    required this.onDropdown1,
    required this.dropdown2,
    required this.onDropdown2,
    // เพิ่มสำหรับฟอร์มด้านล่าง
    this.nameValue = '',
    required this.onNameChanged,
    required this.onConfirm,
    this.isSubmitting = false,
  });

  // เดิม ๆ (เผื่ออนาคตใช้งาน)
  final String? fileName;
  final VoidCallback onPickFile;
  final String dropdown1;
  final ValueChanged<String> onDropdown1;
  final String dropdown2;
  final ValueChanged<String> onDropdown2;

  // สำหรับฟอร์มด้านล่าง
  final String nameValue;
  final ValueChanged<String> onNameChanged;
  final VoidCallback onConfirm;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── หัวข้อบน พิลสีน้ำเงิน (brand) ───────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.colorBrand,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'ดึงข้อมูลปัจจุบัน',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),

            const SizedBox(height: 16),

            // ── บล็อกฟอร์ม: TextField + ปุ่มยืนยัน ──────────────────────────
            Container(
              width: 360,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                    BoxShadow(color: Colors.white.withValues(alpha: 0.6), blurRadius: 2, offset: const Offset(-5, -5)),
                    BoxShadow(color: AppColors.colorBrandTp.withValues(alpha: 0.4), blurRadius: 4, offset: const Offset(5, 5)),
                  ]
                ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildSectionTitle('เพิ่มข้อมูลใหม่'),

                  const SizedBox(height: 16.0),

                  buildTextField(
                    value: nameValue,                 // ค่าใน state
                    hintText: 'Material No. | Example: 24001234',                 // label/placeholder
                    onChanged: onNameChanged,         // อัปเดต state
                  ),

                  const SizedBox(height: 16),

                  // ปุ่ม "ยืนยัน" (PillButton)
                  Align(
                    alignment: Alignment.center,
                    child: PillButton(
                      label: 'ยืนยัน',
                      labelSize: 14,
                      pillWidth: 360,
                      selected: true,
                      solid: true,
                      // ถ้าอยากมีไอคอนนำหน้า ใส่: leading: Icons.check_rounded,
                      onTap: isSubmitting ? null : onConfirm,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
