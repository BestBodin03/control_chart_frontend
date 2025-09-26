import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';
import 'package:control_chart/ui/core/shared/form_component.dart';
import 'package:control_chart/ui/core/shared/pill_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../data/bloc/data_importing/import_bloc.dart';

class ImportPage extends StatelessWidget {
  const ImportPage({
    super.key,
    this.nameValue = '',
    required this.onNameChanged,
    required this.onConfirm,
    this.isSubmitting = false,
  });

  final String nameValue;
  final ValueChanged<String> onNameChanged;
  final VoidCallback onConfirm;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    // ⬇️ ดึงสถานะจาก ImportBloc เพื่อตัดสินใจแสดง progress
final st = context.watch<ImportBloc>().state;

// แสดงแถบเมื่อเริ่ม/กำลังโพลล์/ยังมี data ค้าง (ช่วง hold 2 วิ)
final bool showProgress = st.isSubmitting || st.isPolling || st.data != null;

final int percent = (st.data?.percent ?? 0).clamp(0, 100);
final bool hasPercent = st.data != null; // มีผลจาก /progress แล้ว

    return LayoutBuilder(
      builder: (context, c) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── บล็อกบน: การดึงข้อมูล ───────────────────────────────
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
                    children: [
                      buildSectionTitle('การดึงข้อมูล'),
                      const SizedBox(height: 16),

                    if (showProgress) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          minHeight: 16,
                          value: hasPercent ? (percent / 100.0) : null, // null = indeterminate ก่อนผลแรกมาถึง
                          backgroundColor: Colors.grey.shade100,
                          color: AppColors.colorBrand,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        hasPercent ? 'กำลังดึงข้อมูล... $percent%' : 'กำลังดึงข้อมูล...',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                    ],


                      // ปุ่ม “ดึงข้อมูลปัจจุบัน”
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
                        child: ElevatedButton.icon(
                          onPressed: isSubmitting
                              ? null
                              : () {
                                  // ยิง Bloc (เริ่ม process + เริ่มโพลล์)
                                  context.read<ImportBloc>().add(const ImportStartPressed());
                                },
                          icon: isSubmitting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(Icons.replay_rounded, size: 20),
                          label: Text(
                            isSubmitting ? 'กำลังดำเนินการ...' : 'ดึงข้อมูลปัจจุบัน',
                            style: AppTypography.textBody2WBold,
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
                      const SizedBox(height: 16),
                      buildTextField(
                        value: nameValue,
                        hintText: 'Material No. | Example: 24001234',
                        onChanged: onNameChanged,
                      ),
                      const SizedBox(height: 16),

                      Align(
                        alignment: Alignment.centerLeft,
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
                                : const Icon(Icons.check_rounded, size: 20),
                            label: Text(
                              isSubmitting ? 'กำลังดำเนินการ...' : 'ยืนยัน',
                              style: AppTypography.textBody2WBold,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.colorSuccess1,
                              foregroundColor: Colors.white,
                              elevation: 8,
                              shadowColor: AppColors.colorSuccess1.withValues(alpha: 0.4),
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
