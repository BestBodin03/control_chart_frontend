import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/component/setting_form.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/component/setting_show_chart.dart';
import 'package:flutter/material.dart';

class SettingContent extends StatelessWidget {
  const SettingContent({super.key}); // ใส่ constructor ที่มี key ด้วย
  
  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(left: 32.0, right: 32.0, bottom: 32.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingForm(),
            SizedBox(width: 32.0),
            SettingShowChart(),
          ],
        ),
      ),
    );
  }
}
