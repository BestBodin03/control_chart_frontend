import 'package:flutter/material.dart';

class ChartDetailContent extends StatefulWidget {
  const ChartDetailContent({super.key}); // ใส่ constructor ที่มี key ด้วย

  @override
  ChartDetailContentState createState() => ChartDetailContentState();
}

class ChartDetailContentState extends State<ChartDetailContent> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 100,
        width: 100,
        color: Colors.deepOrange,
        child: const Center(
          child: Text("Chart Details Screen"),
        ),
      ),
    );
  }
}
