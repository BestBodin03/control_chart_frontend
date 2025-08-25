import 'package:control_chart/ui/core/shared/pill_button.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/component/temp.dart';
import 'package:flutter/material.dart';

class ImportPage extends StatelessWidget {
  const ImportPage({super.key, 
    required this.fileName,
    required this.onPickFile,
    required this.dropdown1,
    required this.onDropdown1,
    required this.dropdown2,
    required this.onDropdown2,
  });

  final String? fileName;
  final VoidCallback onPickFile;
  final String dropdown1;
  final ValueChanged<String> onDropdown1;
  final String dropdown2;
  final ValueChanged<String> onDropdown2;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final isNarrow = c.maxWidth < 960;
      final leftW = isNarrow ? c.maxWidth : c.maxWidth * 0.28;
      final rightW = isNarrow ? c.maxWidth : c.maxWidth * 0.68;

      return SingleChildScrollView(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left sidebar
            SizedBox(
              width: leftW,
              child: CardBox(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RowIconTitle(
                      icon: Icons.file_upload_outlined,
                      title: 'ขั้นตอนนำเข้าข้อมูล',
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'เลือกไฟล์สำหรับนำเข้า',
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
                    ),
                    const SizedBox(height: 8),
                    OutlineButton(
                      label: fileName ?? 'เลือกไฟล์…',
                      onTap: onPickFile,
                      icon: Icons.attach_file,
                    ),
                    const SizedBox(height: 14),
                    LabeledDropdown(
                      label: 'Dropdown 1',
                      value: dropdown1.isEmpty ? null : dropdown1,
                      items: const ['ประเภท A', 'ประเภท B', 'ประเภท C'],
                      onChanged: (v) => onDropdown1(v ?? ''),
                    ),
                    const SizedBox(height: 14),
                    LabeledDropdown(
                      label: 'Dropdown 2',
                      value: dropdown2.isEmpty ? null : dropdown2,
                      items: const ['แมปคอลัมน์ 1', 'แมปคอลัมน์ 2', 'แมปคอลัมน์ 3'],
                      onChanged: (v) => onDropdown2(v ?? ''),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: PillButton(
                        label: 'โหลดข้อมูล',
                        labelSize: 16,
                        solid: true,
                        selected: true,
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'เคล็ดลับ: เมื่อเลือกไฟล์แล้ว พรีวิวจะแสดงทางด้านขวา',
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: const Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),

            // // Right preview area
            // SizedBox(
            //   width: rightW,
            //   child: CardBox(
            //     padding: const EdgeInsets.all(16),
            //     child: fileName == null
            //         ? const EmptyState(
            //             title: 'ยังไม่มีไฟล์สำหรับพรีวิว',
            //             description:
            //                 'อัปโหลดไฟล์ด้านซ้าย จากนั้นระบบจะแสดงตัวอย่างข้อมูลเพื่อยืนยันการแมป',
            //             extra: 'รองรับ CSV, XLSX',
            //           )
            //         : Column(
            //             crossAxisAlignment: CrossAxisAlignment.stretch,
            //             children: [
            //               Row(
            //                 children: [
            //                   Text(
            //                     'พรีวิวข้อมูล: $fileName',
            //                     style: Theme.of(context).textTheme.labelLarge?.copyWith(
            //                           fontWeight: FontWeight.w600,
            //                           color: const Color(0xFF0F172A),
            //                         ),
            //                   ),
            //                   const Spacer(),
            //                   Badge(
            //                     text: 'พร้อมนำเข้า',
            //                     color: const Color(0xFFDBEAFE),
            //                     textColor: const Color(0xFF1D4ED8),
            //                     ringColor: const Color(0xFFBFDBFE),
            //                   ),
            //                 ],
            //               ),
            //               const SizedBox(height: 12),
            //               ClipRRect(
            //                 borderRadius: BorderRadius.circular(12),
            //                 child: DecoratedBox(
            //                   decoration: BoxDecoration(
            //                     border: Border.all(color: const Color(0xFFE2E8F0)),
            //                     color: Colors.white,
            //                   ),
            //                   child: PreviewTable(rows: 6, cols: 5),
            //                 ),
            //               ),
            //               const SizedBox(height: 12),
            //               Row(
            //                 mainAxisAlignment: MainAxisAlignment.end,
            //                 children: [
            //                   Pill(
            //                     label: 'ตรวจสอบ',
            //                     onTap: () {},
            //                     selected: true,
            //                   ),
            //                   const SizedBox(width: 8),
            //                   Pill(
            //                     label: 'ยืนยันนำเข้า',
            //                     onTap: () {},
            //                     solid: true,
            //                     selected: true,
            //                   ),
            //                 ],
            //               ),
            //             ],
            //           ),
            //   ),
            // ),
          ],
        ),
      );
    });
  }
}