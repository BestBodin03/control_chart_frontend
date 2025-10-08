import 'package:control_chart/data/cubit/searching/filters_cubit.dart';
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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/bloc/search_chart_details/search_bloc.dart';
import '../../data/bloc/tv_monitoring/tv_monitoring_bloc.dart';

class MyHomeScreen extends StatefulWidget {
  final dynamic initialParams;
  const MyHomeScreen({super.key, required this.initialParams});

  @override
  State<MyHomeScreen> createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen> {
  late final List<HomeContentVar> _profilesSnapshot;

  // Bloc ที่ใช้เฉพาะแท็บ Home
  late final TvMonitoringBloc _tvBloc;
  late final SearchBloc _homeSearchBloc;
  late final FiltersCubit _filterCubit;

  // ใช้ PageView แทน IndexedStack
  late final PageController _pageController;

  // เก็บเป็น WidgetBuilder เพื่อ lazy build
  late final List<WidgetBuilder> _pageBuilders;

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

    // ---- Bloc เฉพาะหน้า Home ----
    _tvBloc = TvMonitoringBloc();
    _homeSearchBloc = SearchBloc(/* deps */);
    _filterCubit = FiltersCubit();

    // ---- Page controller ----
    _pageController = PageController(initialPage: AppRoute.instance.navIndex.value);

    // ---- กำหนดหน้าต่าง ๆ แบบ builder (สร้างเมื่อถูกเรียกใช้) ----
  // ===== _pageBuilders setup =====
  _pageBuilders = [
    // ===== 0. HOME TAB =====
    (context) => _ActiveAware(
          isActiveListenable: AppRoute.instance.navIndex,
          index: 0,
          child: MultiBlocProvider(
            providers: [
              BlocProvider.value(value: _tvBloc),
              BlocProvider.value(value: _homeSearchBloc),
              BlocProvider.value(value: _filterCubit),
            ],
            child: Builder(
              builder: (context) {
                // Get current screen info
                final media = MediaQuery.of(context);
                final double screenWidth = media.size.width;

                // ✅ Scale font based on screen width
                //    - Normal (<=1280) : 1.0
                //    - Large (>=1920)  : 1.25
                //    - Mid range (1280–1920): interpolate smoothly
                double scale;
                if (screenWidth <= 1280) {
                  scale = 1.0;
                } else if (screenWidth >= 1920) {
                  scale = 1.25;
                } else {
                  final ratio = (screenWidth - 1280) / (1920 - 1280);
                  scale = 1.0 + (0.25 * ratio); // linear scaling
                }

                // ✅ Apply scaling using MediaQuery
                return MediaQuery(
                  data: media.copyWith(
                    // Use .textScaler if on Flutter 3.13+, otherwise .textScaleFactor
                    textScaler: TextScaler.linear(scale),
                    // For Flutter ≥3.13: textScaler: TextScaler.linear(scale),
                  ),
                  child: HomeContent(
                    profiles: _profilesSnapshot,
                    onSendSnapshotToSearch: (snap) {
                      AppRoute.instance.searchSnapshot.value = snap;
                      _jumpTo(1);
                    },
                  ),
                );
              },
            ),
          ),
        ),

    // ===== 1. SEARCH TAB =====
    (context) => _ActiveAware(
          isActiveListenable: AppRoute.instance.navIndex,
          index: 1,
          child: const SearchingScreen(),
        ),

    // ===== 2. SETTINGS TAB =====
    (context) => _ActiveAware(
          isActiveListenable: AppRoute.instance.navIndex,
          index: 2,
          child: const SettingScreen(),
        ),

    // ===== 3. CHART DETAIL TAB =====
    (context) => _ActiveAware(
          isActiveListenable: AppRoute.instance.navIndex,
          index: 3,
          child: const ChartDetailScreen(),
        ),
  ];


    // sync เมื่อ navIndex ถูกเปลี่ยนจากที่อื่น (เช่นกดใน Drawer)
    AppRoute.instance.navIndex.addListener(() {
      final target = AppRoute.instance.navIndex.value;
      if (target != _pageController.page?.round()) {
        _pageController.jumpToPage(target);
      }
    });
  }

  @override
  void dispose() {
    _homeSearchBloc.close();
    _tvBloc.close();
    _pageController.dispose();
    super.dispose();
  }

  void _jumpTo(int i) {
    if (i != AppRoute.instance.navIndex.value) {
      AppRoute.instance.navIndex.value = i;
      _pageController.jumpToPage(i);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: AppRoute.instance.navIndex,
      builder: (_, nav, __) {
        return Scaffold(
          appBar: AppBar(
            leading: const CollapsedAppDrawer(),
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: 32),
                child: DateTimeComponent(),
              ),
            ],
          ),
          body: PageView.builder(
            controller: _pageController,
            itemCount: _pageBuilders.length,
            physics: const NeverScrollableScrollPhysics(), // คุมด้วย Drawer/ปุ่มเอง
            onPageChanged: (i) {
              if (i != AppRoute.instance.navIndex.value) {
                AppRoute.instance.navIndex.value = i;
              }
            },
            // ปรับ cacheExtent ตามความเหมาะสม (0.5~1.0 หน้าพอ) เพื่อลด RAM
            // note: เป็นหน่วยหน้ากว้าง (pixels) ไม่ใช่จำนวนหน้า
            // ถ้าอยากเข้มสุดให้ปล่อยค่า default ก็ได้
            itemBuilder: (context, index) => _pageBuilders[index](context),
          ),
          drawer: SizedBox(
            width: 240,
            child: AppDrawer(
              selectedIndex: nav,
              onItemTapped: (i) {
                Navigator.pop(context);
                _jumpTo(i);
              },
            ),
          ),
        );
      },
    );
  }
}

/// ---------------------------------------------------------------------------
/// ห่อหน้าแต่ละหน้าให้ "หยุดงาน" เมื่อไม่ active:
/// - TickerMode(false): หยุด animation/Controller ที่ผูกกับ Ticker
/// - IgnorePointer(true): กัน gesture/touch ตอนไม่ active
/// - RepaintBoundary: ลดผลกระทบการวาดข้ามขอบเขต
/// ---------------------------------------------------------------------------
class _ActiveAware extends StatelessWidget {
  final ValueListenable<int> isActiveListenable;
  final int index;
  final Widget child;

  const _ActiveAware({
    required this.isActiveListenable,
    required this.index,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: isActiveListenable,
      builder: (_, current, __) {
        final active = current == index;
        return TickerMode(
          enabled: active,
          child: IgnorePointer(
            ignoring: !active,
            child: const RepaintBoundary().runtimeType == RepaintBoundary // keeps analyzer calm
                ? RepaintBoundary(child: child)
                : child,
          ),
        );
      },
    );
  }
}
