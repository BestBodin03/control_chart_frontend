import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/shared/form_component.dart';
import 'package:control_chart/ui/core/shared/pill_button.dart';
import 'package:flutter/material.dart';

class ImportPage extends StatelessWidget {
  const ImportPage({
    super.key,
    required this.fileName,
    required this.onPickFile,
    required this.dropdown1,
    required this.onDropdown1,
    required this.dropdown2,
    required this.onDropdown2,
    this.nameValue = '',
    required this.onNameChanged,
    required this.onConfirm,
    this.isSubmitting = false,
  });

  final String? fileName;
  final VoidCallback onPickFile;
  final String dropdown1;
  final ValueChanged<String> onDropdown1;
  final String dropdown2;
  final ValueChanged<String> onDropdown2;

  final String nameValue;
  final ValueChanged<String> onNameChanged;
  final VoidCallback onConfirm;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    final bool isDownloaded = false;
    return LayoutBuilder(
      builder: (context, c) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── หัวข้อบน ───────────────────────────────
            SizedBox(
              width: 360,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.6),
                      blurRadius: 2,
                      offset: const Offset(-5, -5),
                    ),
                    BoxShadow(
                      color: AppColors.colorBrandTp.withValues(alpha: 0.4),
                      blurRadius: 4,
                      offset: const Offset(5, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 16,
                    children: [
                      buildSectionTitle('การดึงข้อมูล'),
                      isDownloaded
                        ? Container(
                            width: double.infinity,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: const Center(
                              child: Text(
                                'Progress Bar Area',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 8,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(), // ไม่แสดงอะไรเลย

                      // ปุ่มด้านบน
                        Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.colorBrand,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.6),
                                blurRadius: 2,
                                offset: const Offset(-2, -2),
                              ),
                              BoxShadow(
                                color: AppColors.colorBrandTp.withValues(alpha: 0.4),
                                blurRadius: 4,
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: isSubmitting ? null : onConfirm,
                              borderRadius: BorderRadius.circular(24),
                                child: ElevatedButton.icon(
                                    onPressed: isSubmitting ? null : onConfirm,
                                    icon: isSubmitting
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : const Icon(Icons.replay_rounded, size: 18),
                                    label: Text(
                                      isSubmitting ? 'กำลังดำเนินการ...' : 'ดึงข้อมูลปัจจุบัน',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.colorBrand,
                                      foregroundColor: Colors.white,
                                      elevation: 8,
                                      shadowColor: const Color.fromARGB(255, 54, 48, 141).withValues(alpha: 0.4),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                    ),
                              ),
                            ),
                          ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ── บล็อกฟอร์ม ──────────────────────────
            SizedBox(
              width: 360,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.6),
                      blurRadius: 2,
                      offset: const Offset(-5, -5),
                    ),
                    BoxShadow(
                      color: AppColors.colorBrandTp.withValues(alpha: 0.4),
                      blurRadius: 4,
                      offset: const Offset(5, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildSectionTitle('เพิ่มข้อมูลใหม่'),
                      const SizedBox(height: 16.0),
                      buildTextField(
                        value: nameValue,
                        hintText: 'Material No. | Example: 24001234',
                        onChanged: onNameChanged,
                      ),
                      const SizedBox(height: 16),

                      // ปุ่มยืนยันชิดซ้าย
                      Align(
                        alignment: Alignment.centerLeft, // ← CHANGED (center → centerLeft)
                        child: SizedBox(
                          width: 360,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: isSubmitting ? null : onConfirm,
                            icon: isSubmitting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.check_rounded, size: 18),
                            label: Text(
                              isSubmitting ? 'กำลังดำเนินการ...' : 'ยืนยัน',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF059669),
                              foregroundColor: Colors.white,
                              elevation: 8,
                              shadowColor: const Color(0xFF059669).withValues(alpha: 0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
