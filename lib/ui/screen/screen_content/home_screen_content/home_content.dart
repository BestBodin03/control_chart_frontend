import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:flutter/material.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key}); // ใส่ constructor ที่มี key ด้วย

  @override
  HomeContentState createState() => HomeContentState();
}

class HomeContentState extends State<HomeContent> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 100,
        width: 100,
        color: AppColors.colorBrand,
        child: const Center(
          child: Text("Home Screen",
          style: TextStyle(color: AppColors.colorBg),),

        ),
      ),
    );
  }
}
