import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:flutter/material.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  HomeContentState createState() => HomeContentState();
}

class HomeContentState extends State<HomeContent> {
  @override
  Widget build(BuildContext context) {
    return 
    Column(
      children: [
        Center (
          child: Container(
            height: 100,
            width: 100,
            color: AppColors.colorBrandTp,
            child: const Center(
              child: Text("Home Screen",
              style: TextStyle(color: AppColors.colorBg),),
        
            ),
          ),
        ),
      ],
    );
  }
}