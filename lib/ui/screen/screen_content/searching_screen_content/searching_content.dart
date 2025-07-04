import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:flutter/material.dart';

class SearchingContent extends StatefulWidget {
  const SearchingContent({super.key}); // ใส่ constructor ที่มี key ด้วย

  @override
  SearchingContentState createState() => SearchingContentState();
}

class SearchingContentState extends State<SearchingContent> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 100,
        width: 100,
        color: AppColors.colorBrandTp,
        child: const Center(
          child: Text("Searching Screen",
          style: TextStyle(color: AppColors.colorBg),),

        ),
      ),
    );
  }
}
