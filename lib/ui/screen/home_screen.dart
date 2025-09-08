import 'package:control_chart/ui/core/layout/app_drawer/app_drawer.dart';
import 'package:control_chart/ui/core/layout/app_drawer/collapsed_app_drawer.dart';
import 'package:control_chart/ui/core/shared/date_time_component.dart';
import 'package:control_chart/ui/screen/chart_detail_screen.dart';
import 'package:control_chart/ui/screen/screen_content/home_screen_content/home_content.dart';
import 'package:control_chart/ui/screen/screen_content/home_screen_content/home_content_var.dart';
import 'package:control_chart/ui/screen/searching_screen.dart';
import 'package:control_chart/ui/screen/setting_screen.dart';
import 'package:flutter/material.dart';

class MyHomeScreen extends StatefulWidget {
  final HomeContentVar initialParams;
  const MyHomeScreen({
    super.key,
    required this.initialParams});

  @override
  State<MyHomeScreen> createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen> {
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  static const List<Widget> _widgetOptions = <Widget>[
    HomeContent(),
    SearchingScreen(),
    SettingScreen(),
    ChartDetailScreen(),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return CollapsedAppDrawer();
          },
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 32.0),
            child: DateTimeComponent(),
          ),
        ],
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
