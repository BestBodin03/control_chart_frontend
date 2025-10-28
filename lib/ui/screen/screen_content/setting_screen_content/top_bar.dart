import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/setting_content.dart';
import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  const TopBar({
    super.key,
    required this.tab,
    required this.onSelect,
  });

  final TabKey tab;
  final ValueChanged<TabKey> onSelect;

  @override
  Widget build(BuildContext context) {
    final selectedColor = AppColors.colorBrand;
    final unselectedColor = AppColors.colorBrandTp;

    return DefaultTabController(
      length: 2,
      initialIndex: tab == TabKey.profiles ? 0 : 1,
        child: TabBar(
          tabAlignment: TabAlignment.start,
          isScrollable: true,                       // width = content only
          labelColor: selectedColor,
          unselectedLabelColor: unselectedColor,
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          indicatorSize: TabBarIndicatorSize.tab, // underline fits label width
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(width: 3, color: selectedColor),
          ),
          tabs: const [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.dashboard_customize, size: 18),
                  SizedBox(width: 6),
                  Text('Display Profile'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.data_saver_on_rounded, size: 18),
                  SizedBox(width: 6),
                  Text('Data'),
                ],
              ),
            ),
          ],
          onTap: (index) =>
              onSelect(index == 0 ? TabKey.profiles : TabKey.importData),
        ),
    );
  }
}
