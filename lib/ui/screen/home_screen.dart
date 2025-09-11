import 'package:control_chart/ui/core/layout/app_drawer/app_drawer.dart';
import 'package:control_chart/ui/core/layout/app_drawer/collapsed_app_drawer.dart';
import 'package:control_chart/ui/core/shared/date_time_component.dart';
import 'package:control_chart/ui/screen/chart_detail_screen.dart';
import 'package:control_chart/ui/screen/screen_content/home_screen_content/home_content.dart';
import 'package:control_chart/ui/screen/screen_content/home_screen_content/home_content_var.dart';
import 'package:control_chart/ui/screen/searching_screen.dart';
import 'package:control_chart/ui/screen/setting_screen.dart';
import 'package:control_chart/utils/app_store.dart';
import 'package:flutter/material.dart';

class MyHomeScreen extends StatefulWidget {
  final dynamic initialParams;
  const MyHomeScreen({
    super.key,
    required this.initialParams,
  });

  @override
  State<MyHomeScreen> createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen> {
  int _selectedIndex = 0;

  // ❗ ไม่เป็น final เพื่ออัปเดตได้เมื่อ seed / fallback
  List<HomeContentVar> _profiles = const <HomeContentVar>[];

  @override
  void initState() {
    super.initState();

    // 1) seed จาก initialParams (ครั้งแรกตอนเปิดจอ)
    final p = widget.initialParams;
    if (p is List) {
      _profiles = p.whereType<HomeContentVar>().toList();
    } else {
      _profiles = const <HomeContentVar>[];
    }

    // 2) ถ้า AppStore ยังว่างอยู่ ให้ seed ค่าเริ่มจาก _profiles
    final store = AppStore.instance.homeProfiles;
    if (store.value.isEmpty && _profiles.isNotEmpty) {
      store.value = List<HomeContentVar>.from(_profiles);
    }
  }

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  // รับ profiles ที่ใช้จริงในเฟรมนั้นเข้ามา
  Widget _pageForIndex(int index, List<HomeContentVar> profiles) {
    switch (index) {
      case 0:
        if (profiles.isNotEmpty) return HomeContent(profiles: profiles);
        return const Center(child: Text('โปรดเลือกโปรไฟล์ตั้งค่าเพื่อแสดงแผนภูมิควบคุม'));
      case 1:
        return const SearchingScreen();
      case 2:
        return const SettingScreen();
      case 3:
        return const ChartDetailScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(builder: (context) => const CollapsedAppDrawer()),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 32.0),
            child: DateTimeComponent(),
          ),
        ],
      ),
      // 👇 ฟัง AppStore: ถ้า store มีค่า ใช้ค่านั้น; ถ้ายังว่าง ใช้ seed (_profiles)
      body: ValueListenableBuilder<List<HomeContentVar>>(
        valueListenable: AppStore.instance.homeProfiles,
        builder: (_, liveProfiles, __) {
          final effective = (liveProfiles.isNotEmpty) ? liveProfiles : _profiles;
          return Center(child: _pageForIndex(_selectedIndex, effective));
        },
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

