// HomeContent (no-swipe; nav buttons beside dots; Bloc-driven page change)

import 'dart:developer' as dev;

import 'package:control_chart/data/bloc/tv_monitoring/tv_monitoring_bloc.dart';
import 'package:control_chart/ui/core/shared/medium_control_chart/cde_cdt/control_chart_component.dart';
import 'package:control_chart/ui/core/shared/medium_control_chart/cde_cdt/help.dart' as shCdeCdt;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/bloc/search_chart_details/search_bloc.dart';
import '../../../../domain/models/control_chart_stats.dart';
import '../../../core/design_system/app_color.dart';
import '../../../core/shared/medium_control_chart/cde_cdt/control_chart_component.dart' as shCdeCdt;
import '../../../core/shared/medium_control_chart/surface_hardness/help.dart' as shSurface;

import 'home_content_var.dart';

class HomeContent extends StatefulWidget {
  final List<HomeContentVar> profiles;

  const HomeContent({super.key, required this.profiles});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  // ---------- Page controller ต้องอยู่ใน State ----------
  late final PageController _pageController;

  // เก็บลายเซ็นโปรไฟล์ล่าสุด เพื่อตรวจว่ามีการเปลี่ยนแปลงจริง ๆ หรือไม่
  String _lastSig = '';

  // ---------- helpers ----------

  String _sigProfile(HomeContentVar p) =>
      '${p.startDate?.millisecondsSinceEpoch ?? 0}-'
      '${p.endDate?.millisecondsSinceEpoch ?? 0}-'
      '${p.furnaceNo ?? ''}-'
      '${p.materialNo ?? ''}-'
      '${p.displayType}-${p.interval}';

  String _sigList(List<HomeContentVar> ps) => ps.map(_sigProfile).join('|');

  HomeContentVar _applyRangeToProfile(HomeContentVar base, DateTime? start, DateTime? end) {
    final DateTime effStart = start ?? base.startDate ?? DateTime.now().toLocal();
    final DateTime effEnd   = end   ?? base.endDate   ?? effStart.add(const Duration(hours: 1));
    return base.copyWith(startDate: effStart, endDate: effEnd);
  }

  // ---------- lifecycle ----------

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _lastSig = _sigList(widget.profiles);

    // ส่ง profiles เข้า Bloc แค่ครั้งแรก
    if (widget.profiles.isNotEmpty) {
      dev.log('[HomeContent.initState] seed profiles -> TvMonitoringBloc (${widget.profiles.length})');
      context.read<TvMonitoringBloc>().add(TvProfilesUpdated(widget.profiles));
    } else {
      dev.log('[HomeContent.initState] profiles empty');
    }
  }

  @override
  void didUpdateWidget(covariant HomeContent oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newSig = _sigList(widget.profiles);
    if (newSig != _lastSig) {
      dev.log('[HomeContent.didUpdateWidget] profiles changed: ${widget.profiles.length}');
      _lastSig = newSig;
      context.read<TvMonitoringBloc>().add(TvProfilesUpdated(widget.profiles));
      // ❌ ไม่ jumpToPage ที่นี่ — ให้ BlocListener ซิงก์แทน
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ---------- build ----------

  @override
  Widget build(BuildContext context) {
    return BlocListener<TvMonitoringBloc, TvMonitoringState>(
      // ฟังเมื่อ index หรือ profiles เปลี่ยน
      listenWhen: (prev, curr) =>
          prev.index != curr.index || prev.profiles != curr.profiles,
      listener: (context, tvState) {
        if (tvState.profiles.isEmpty) return;

        // 1) ขยับ PageView ให้ตรง index ปัจจุบันจาก Bloc
        final want = tvState.index.clamp(0, tvState.profiles.length - 1);
        final at = _pageController.hasClients ? _pageController.page?.round() : null;
        if (_pageController.hasClients && at != want) {
          dev.log('[HomeContent.listener] animateToPage -> $want (from $at)');
          _pageController.animateToPage(
            want,
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeOut,
          );
        }

        // 2) ยิง SearchBloc สำหรับหน้า want
        final p = tvState.profiles[want];
        dev.log('[HomeContent.listener] LoadFilteredChartData index=$want '
            'f=${p.furnaceNo} m=${p.materialNo} range=(${p.startDate}..${p.endDate})');

        context.read<SearchBloc>().add(LoadFilteredChartData(
          startDate: p.startDate,
          endDate:   p.endDate,
          furnaceNo: p.furnaceNo,
          materialNo:p.materialNo,
        ));
      },

      child: BlocBuilder<TvMonitoringBloc, TvMonitoringState>(
        builder: (context, tvState) {
          final profiles = tvState.profiles;

          // ----- Single page -----
          if (profiles.length <= 1) {
            final q = profiles.isNotEmpty ? profiles.first : const HomeContentVar();
            final uniqueKey =
                '${q.startDate?.millisecondsSinceEpoch ?? 0}-${q.endDate?.millisecondsSinceEpoch ?? 0}-${q.furnaceNo ?? ''}-${q.materialNo ?? ''}-';

            return LayoutBuilder(
              key: ValueKey('single-$uniqueKey'),
              builder: (context, constraints) {
                final h = constraints.maxHeight;

                return BlocBuilder<SearchBloc, SearchState>(
                  builder: (context, searchState) {
                    dev.log('[HomeContent.single] SearchState=${searchState.status} '
                            'query=${searchState.currentQuery}');

                    if (searchState.isInitial || searchState.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (searchState.hasError) {
                      return Center(child: Text('Error: ${searchState.errorMessage}'));
                    }

                    final (left, right) =
                        (searchState.currentQuery.startDate, searchState.currentQuery.endDate);
                    final qWindow = _applyRangeToProfile(q, left, right);

                    dev.log('[HomeContent.single] qWindow '
                            '(${qWindow.startDate}..${qWindow.endDate}) '
                            'f=${qWindow.furnaceNo} m=${qWindow.materialNo}');

                    return Column(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: h,
                                  child: _ChartFillBox(
                                    child: shSurface.buildChartsSectionSurfaceHardness(
                                      [qWindow],
                                      0,
                                      searchState,
                                      externalStart: 0,
                                      externalWindowSize: 6,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    );
                  },
                );
              },
            );
          }

          // ----- Carousel mode (no swipe; buttons only) -----
          return Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(), // 🚫 ปิดการสไลด์/ทัชแพด
                  onPageChanged: (i) {
                    // ป้องกัน echo: ส่งอีเวนต์เฉพาะเมื่อ index เปลี่ยนจริง
                    final curr = context.read<TvMonitoringBloc>().state.index;
                    if (i != curr) {
                      dev.log('[HomeContent.onPageChanged] i=$i');
                      context.read<TvMonitoringBloc>().add(TvPageChanged(i));
                    }
                  },
                  itemCount: profiles.length,
                  itemBuilder: (ctx, i) => LayoutBuilder(
                    builder: (context, constraints) {
                      return BlocBuilder<SearchBloc, SearchState>(
                        builder: (context, searchState) {
                          dev.log('[HomeContent.page=$i] SearchStatus=${searchState.status}');

                          if (searchState.isInitial || searchState.isLoading) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (searchState.hasError) {
                            return Center(child: Text('Error: ${searchState.errorMessage}'));
                          }

                          final q = profiles[i];
                          final (left, right) =
                              (searchState.currentQuery.startDate, searchState.currentQuery.endDate);
                          final qWindow = _applyRangeToProfile(q, left, right);

                          final adjustedProfiles = List<HomeContentVar>.of(
                            profiles,
                            growable: false,
                          )..[i] = qWindow;

                          final stats = searchState.controlChartStats;
                          final minY = stats?.yAxisRange?.minYsurfaceHardnessControlChart;
                          final maxY = stats?.yAxisRange?.maxYsurfaceHardnessControlChart;

                          final visibleSecond =
                              (searchState.controlChartStats?.secondChartSelected ??
                                      SecondChartSelected.na) !=
                                  SecondChartSelected.na;

                          final surfKey = ValueKey(
                            'surf-$i-'
                            '${qWindow.furnaceNo}-${qWindow.materialNo}-'
                            '${qWindow.startDate?.millisecondsSinceEpoch}-'
                            '${qWindow.endDate?.millisecondsSinceEpoch}-'
                            '$minY-$maxY-${searchState.status}-${searchState.currentQuery.hashCode}'
                          );

                          final cdeKey = ValueKey(
                            'cde-$i-'
                            '${qWindow.furnaceNo}-${qWindow.materialNo}-'
                            '${qWindow.startDate?.millisecondsSinceEpoch}-'
                            '${qWindow.endDate?.millisecondsSinceEpoch}-'
                            '$minY-$maxY-${searchState.status}-${searchState.currentQuery.hashCode}'
                          );

                          return Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      // -------- กราฟหลัก (Surface Hardness) --------
Expanded(
  child: SizedBox(
    height: constraints.maxHeight - (8 + 16),
    child: _ChartFillBox(
      child: KeyedSubtree(
        key: surfKey,                   // ✅ เปลี่ยน key → Flutter ทิ้ง State เก่าทั้งก้อน
        child: shSurface.buildChartsSectionSurfaceHardness(
          adjustedProfiles, i, searchState,
          externalStart: 0, externalWindowSize: 6,
          baseStart: qWindow.startDate, baseEnd: qWindow.endDate,
        ),
      ),
    ),
  ),
),

                                      const SizedBox(width: 16),

                                      // -------- กราฟที่สอง (CDE/CDT) --------
if (visibleSecond)
  Expanded(
    child: SizedBox(
      height: constraints.maxHeight - (8 + 16),
      child: _ChartFillBox(
        child: KeyedSubtree(
          key: cdeKey,                  // ✅ key แยกของ CDE/CDT
          child: shCdeCdt.buildChartsSectionCdeCdt(
            adjustedProfiles, i, searchState,
            externalStart: 0, externalWindowSize: 6,
            baseStart: qWindow.startDate, baseEnd: qWindow.endDate,
          ),
        ),
      ),
    ),
  ),
                                    ],
                                  ),
                                ),

                                // ---------- ปุ่มนำทาง + จุด ----------
                                _buildPagerControls(
                                  total: profiles.length,
                                  currentIndex: tvState.index,
                                  onPrev: () {
                                    final prev = (tvState.index - 1).clamp(0, profiles.length - 1);
                                    if (prev != tvState.index) {
                                      context.read<TvMonitoringBloc>().add(TvPageChanged(prev));
                                    }
                                  },
                                  onNext: () {
                                    final next = (tvState.index + 1).clamp(0, profiles.length - 1);
                                    if (next != tvState.index) {
                                      context.read<TvMonitoringBloc>().add(TvPageChanged(next));
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ---------------- Controls (buttons + dots) ----------------

  static const double _rowH = 40.0;

  Widget _buildPagerControls({
    required int total,
    required int currentIndex,
    required VoidCallback onPrev,
    required VoidCallback onNext,
  }) {
    final canPrev = currentIndex > 0;
    final canNext = currentIndex < total - 1;

    Widget dots() => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            (total <= 6) ? total : 6,
            (dot) {
              final start = (total <= 6)
                  ? 0
                  : (currentIndex - 3).clamp(0, total - 6);
              final realIndex = start + dot;
              final isActive = realIndex == currentIndex;

              return AnimatedContainer(
                key: ValueKey('dot-$realIndex'),
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 16 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.colorBrand : AppColors.colorBrandTp,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            },
          ),
        );

    return SizedBox(
      height: _rowH,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // left
            canPrev
                ? ConstrainedBox(
                    constraints: const BoxConstraints.tightFor(width: 32, height: 32),
                    child: IconButton(
                      tooltip: 'Previous',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(width: 32, height: 32),
                      visualDensity: VisualDensity.compact,
                      iconSize: 20,
                      splashRadius: 18,
                      icon: const Icon(Icons.chevron_left),
                      onPressed: onPrev,
                    ),
                  )
                : const SizedBox(width: 32),

            const SizedBox(width: 6),

            // dots
            IgnorePointer(child: dots()),

            const SizedBox(width: 6),

            // right
            canNext
                ? ConstrainedBox(
                    constraints: const BoxConstraints.tightFor(width: 32, height: 32),
                    child: IconButton(
                      tooltip: 'Next',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(width: 32, height: 32),
                      visualDensity: VisualDensity.compact,
                      iconSize: 20,
                      splashRadius: 18,
                      icon: const Icon(Icons.chevron_right),
                      onPressed: onNext,
                    ),
                  )
                : const SizedBox(width: 32),
          ],
        ),
      ),
    );
  }
}

class _ChartFillBox extends StatelessWidget {
  const _ChartFillBox({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRect(child: SizedBox.expand(child: child));
  }
}
