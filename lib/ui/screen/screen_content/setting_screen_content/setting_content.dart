import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:flutter/material.dart';

class SettingContent extends StatefulWidget {
  const SettingContent({super.key}); // ใส่ constructor ที่มี key ด้วย

  @override
  SettingContentState createState() => SettingContentState();
}

class SettingContentState extends State<SettingContent> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 100,
        width: 100,
        color: AppColors.colorAlert1,
        child: const Center(
          child: Text("Setting Screen",
          style: TextStyle(color: AppColors.colorBg),),

        ),
      ),
    );
  }
}
