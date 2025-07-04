import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/layout/app_drawer/app_drawer.dart';
import 'package:control_chart/ui/screen/chart_detail_screen.dart';
import 'package:control_chart/ui/screen/screen_content/home_screen_content/home_content.dart';
import 'package:control_chart/ui/screen/searching_screen.dart';
import 'package:control_chart/ui/screen/setting_screen.dart';
import 'package:flutter/material.dart';

class MyHomeScreen extends StatefulWidget {
  const MyHomeScreen({super.key});

  @override
  State<MyHomeScreen> createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen> {
  int _selectedIndex = 0;


  static const List<Widget> _widgetOptions = <Widget>[
    HomeContent(),
    SearchingScreen(),
    SettingScreen(),
    ChartDetailScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text(widget.title),
        leading: Builder(
          builder: (context) {
          return 
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16.0),
            child: SizedBox(
              child: 
                IconButton(
                  iconSize: 56, // Set to match the size of your ClipOval if needed
                  padding: EdgeInsets.zero, // Prevent extra default padding from IconButton
                  constraints: const BoxConstraints(), // Remove default constraints to avoid extra space
                  icon: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.colorBlack,
                          blurRadius: 2,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/thaiparkLogo.png',
                        width: 40,
                        height: 40,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
            ),
          );

          },
        ),
      ),
      body: Center(
        child: _widgetOptions[_selectedIndex],
      ),
      drawer: SizedBox(
        width: 240.0,
          child: AppDrawer(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }
}
