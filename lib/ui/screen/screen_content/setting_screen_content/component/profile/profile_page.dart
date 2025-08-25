import 'package:control_chart/ui/core/shared/pill_button.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/component/profile/profile.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/component/profile/profile_card.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/component/temp.dart';
import 'package:flutter/material.dart';

class ProfilesPage extends StatelessWidget {
  const ProfilesPage({super.key, 
    required this.items,
    required this.onToggleActive,
    required this.onAddProfile,
  });

  final List<Profile> items;
  final void Function(String id, bool v) onToggleActive;

  // Left button
  final VoidCallback onAddProfile;

@override
Widget build(BuildContext context) {
  return LayoutBuilder(builder: (ctx, c) {
    // ปรับได้ตามดีไซน์
    const double minCardWidth = 280.0;
    const double maxCardWidth = 360.0;
    const double gap = 16.0;
    const int maxCols = 6;
    const int minCols = 1;

    int cols = ((c.maxWidth + gap) / (minCardWidth + gap)).floor().clamp(minCols, maxCols);

    // ฟังก์ชันคำนวณความกว้างต่อใบตาม cols ปัจจุบัน
    double widthFor(int candidateCols) {
      final totalGap = gap * (candidateCols - 1);
      return (c.maxWidth - (totalGap + 16)) / candidateCols;
    }

    // ปรับ cols ให้ได้ cardWidth อยู่ในช่วง [minCardWidth, maxCardWidth]
    double cardWidth = widthFor(cols);
    // ถ้ากว้างเกิน max -> เพิ่มคอลัมน์เพื่อให้แคบลง (แต่ไม่เกิน maxCols)
    while (cardWidth > maxCardWidth && cols < maxCols) {
      cols++;
      cardWidth = widthFor(cols);
    }
    // ถ้าแคบเกิน min -> ลดคอลัมน์เพื่อให้กว้างขึ้น (แต่ไม่ต่ำกว่า minCols)
    while (cardWidth < minCardWidth && cols > minCols) {
      cols--;
      cardWidth = widthFor(cols);
    }

    return Column(
      children: [
        Row(
          children: [
            PillButton(
              label: 'เพิ่มโปรไฟล์',
              labelSize: 14,
              leading: Icons.add,
              selected: true,
              onTap: onAddProfile,
              solid: true,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            // กันไม่ให้ Scrollbar ทับขอบขวา
            padding: const EdgeInsets.fromLTRB(0, 0, 16, 16),
            child: Wrap(
              spacing: gap,
              runSpacing: gap,
              children: items.map((p) {
                return SizedBox(
                  width: cardWidth,
                  child: ProfileCard(
                    profile: p,
                    onToggle: (v) => onToggleActive(p.id, v),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  });
}

}