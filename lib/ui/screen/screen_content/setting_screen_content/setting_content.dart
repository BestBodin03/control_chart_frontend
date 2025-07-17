import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/component/setting_form.dart';
import 'package:flutter/material.dart';

class SettingContent extends StatefulWidget {
  const SettingContent({super.key}); // ใส่ constructor ที่มี key ด้วย

  @override
  SettingContentState createState() => SettingContentState();
}

class SettingContentState extends State<SettingContent> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: const DataFormPage(),
    );
  }
}
