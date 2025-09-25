import 'package:control_chart/ui/core/layout/app_drawer/app_drawer.dart';
import 'package:control_chart/ui/core/layout/app_drawer/collapsed_app_drawer.dart';
import 'package:control_chart/ui/core/shared/date_time_component.dart';
import 'package:control_chart/ui/screen/chart_detail_screen.dart';
import 'package:control_chart/ui/screen/screen_content/home_screen_content/home_content.dart';
import 'package:control_chart/ui/screen/screen_content/home_screen_content/home_content_var.dart';
import 'package:control_chart/ui/screen/searching_screen.dart';
import 'package:control_chart/ui/screen/setting_screen.dart';
import 'package:control_chart/utils/app_route.dart';
import 'package:control_chart/utils/app_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/bloc/search_chart_details/search_bloc.dart';
import '../../data/bloc/tv_monitoring/tv_monitoring_bloc.dart';

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
  late final List<HomeContentVar> _profilesSnapshot;

  // แยก Bloc ของ Home กับของ Search (ไม่ชนกัน)
  late final TvMonitoringBloc _tvBloc;
  late final SearchBloc _homeSearchBloc;     // ใช้ใน Home เท่านั้น
  // SearchScreen จะมี SearchBloc ของตัวเอง

  late final List<Widget> _tabs; // เก็บหน้าที่สร้างครั้งเดียว

  @override
  void initState() {
    super.initState();

    // ---- snapshot profiles ครั้งเดียว ----
    final p = widget.initialParams;
    final seeded = (p is List) ? p.whereType<HomeContentVar>().toList() : <HomeContentVar>[];
    final store = AppStore.instance.homeProfiles;
    if (store.value.isEmpty && seeded.isNotEmpty) {
      store.value = List<HomeContentVar>.from(seeded);
    }
    final effective = store.value.isNotEmpty ? store.value : seeded;
    _profilesSnapshot = List<HomeContentVar>.unmodifiable(effective);

    // ---- สร้าง Bloc ที่ Home จะใช้ ----
    _tvBloc = TvMonitoringBloc();
    _homeSearchBloc = SearchBloc(/* deps */);

    // ---- สร้างแท็บครั้งเดียว ----
    _tabs = [
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _tvBloc),
          BlocProvider.value(value: _homeSearchBloc),
        ],
        child: HomeContent(
          profiles: _profilesSnapshot, // snapshot จริง
          // เพิ่ม callback ให้ Home ยิง snapshot ไป Search
          onSendSnapshotToSearch: (snap) {
            AppRoute.instance.searchSnapshot.value = snap;
            AppRoute.instance.navIndex.value = 1; // ไปแท็บ Search
          },
        ),
      ),
      const SearchingScreen(),  // ภายในมี SearchBloc ของตัวเอง
      const SettingScreen(),
      const ChartDetailScreen(),
    ];
  }

  @override
  void dispose() {
    _homeSearchBloc.close();
    _tvBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: AppRoute.instance.navIndex,
      builder: (_, nav, __) {
        return Scaffold(
          appBar: AppBar(
            leading: const CollapsedAppDrawer(),
            actions: const [Padding(
              padding: EdgeInsets.only(right: 32),
              child: DateTimeComponent(),
            )],
          ),
          body: IndexedStack(            // ✅ ไม่ทำลาย ไม่ rebuild ลูก
            index: nav,
            children: _tabs,
          ),
          drawer: SizedBox(
            width: 240,
            child: AppDrawer(
              selectedIndex: nav,
              onItemTapped: (i) {
                if (i != nav) AppRoute.instance.navIndex.value = i;
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    );
  }
}
