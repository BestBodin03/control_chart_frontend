import 'package:control_chart/data/cubit/searching/filters_cubit.dart';
import 'package:control_chart/ui/core/layout/app_drawer/app_drawer.dart';
import 'package:control_chart/ui/core/layout/app_drawer/collapsed_app_drawer.dart';
import 'package:control_chart/ui/core/shared/date_time_component.dart';
import 'package:control_chart/ui/screen/screen_content/home_screen_content/home_content.dart';
import 'package:control_chart/ui/screen/screen_content/home_screen_content/home_content_var.dart';
import 'package:control_chart/ui/screen/searching_screen.dart';
import 'package:control_chart/ui/screen/setting_screen.dart';
import 'package:control_chart/utils/app_route.dart';
import 'package:control_chart/utils/app_store.dart';
import 'package:control_chart/utils/page_refresh_persistence.dart';
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
  late final TvMonitoringBloc _tvBloc;
  late final SearchBloc _homeSearchBloc;
  late final FiltersCubit _filterCubit;
  late PageController _pageController;
  late final List<WidgetBuilder> _pageBuilders;
  
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAsync();
  }

  Future<void> _initializeAsync() async {
    // Load the last saved navigation index
    final lastIndex = await PageRefreshPersistence.getLastNavIndex(defaultIndex: 0);
    
    // Update AppRoute before creating PageController
    AppRoute.instance.navIndex.value = lastIndex;

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
    _homeSearchBloc = SearchBloc();
    _filterCubit = FiltersCubit();

    // ---- Page controller with restored index ----
    _pageController = PageController(initialPage: lastIndex);

    // ---- กำหนดหน้าต่าง ๆ ----
    _pageBuilders = [
      // Index 0: Settings
      (context) => _ActiveAware(
            isActiveListenable: AppRoute.instance.navIndex,
            index: 0,
            child: const SettingScreen(),
          ),
      // Index 1: Search
      (context) => _ActiveAware(
            isActiveListenable: AppRoute.instance.navIndex,
            index: 1,
            child: const SearchingScreen(),
          ),
      // Index 2: Home (with Bloc providers)
      (context) => _ActiveAware(
            isActiveListenable: AppRoute.instance.navIndex,
            index: 2,
            child: MultiBlocProvider(
              providers: [
                BlocProvider.value(value: _tvBloc),
                BlocProvider.value(value: _homeSearchBloc),
                BlocProvider.value(value: _filterCubit),
              ],
              child: HomeContent(
                profiles: _profilesSnapshot,
                onSendSnapshotToSearch: (snap) {
                  AppRoute.instance.searchSnapshot.value = snap;
                  _jumpTo(1);
                },
              ),
            ),
          ),
    ];

    // Sync listener - save every time navIndex changes
    AppRoute.instance.navIndex.addListener(_onNavIndexChanged);

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  void _onNavIndexChanged() {
    final target = AppRoute.instance.navIndex.value;
    
    // Save to persistence
    PageRefreshPersistence.saveNavIndex(target);
    
    // Update PageController if needed
    if (_pageController.hasClients && target != _pageController.page?.round()) {
      _pageController.jumpToPage(target);
    }
  }

  @override
  void dispose() {
    AppRoute.instance.navIndex.removeListener(_onNavIndexChanged);
    _homeSearchBloc.close();
    _tvBloc.close();
    _filterCubit.close();
    _pageController.dispose();
    super.dispose();
  }

  void _jumpTo(int i) {
    if (i != AppRoute.instance.navIndex.value) {
      AppRoute.instance.navIndex.value = i;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(i);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (i) {
              if (i != AppRoute.instance.navIndex.value) {
                AppRoute.instance.navIndex.value = i;
              }
            },
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
            child: RepaintBoundary(child: child),
          ),
        );
      },
    );
  }
}