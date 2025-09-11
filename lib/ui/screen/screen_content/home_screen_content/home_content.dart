import 'dart:async';
import 'dart:developer' as dev;
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/shared/large_control_chart/surface_hardness/help.dart';
import 'package:control_chart/ui/core/shared/medium_control_chart/cde_cdt/help.dart'; // <-- ของเดิมคุณ
import 'package:control_chart/ui/core/shared/medium_control_chart/surface_hardness/help.dart';
import 'package:control_chart/ui/screen/screen_content/home_screen_content/home_content_var.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeContent extends StatefulWidget {
  final List<HomeContentVar> profiles;

  const HomeContent({super.key, required this.profiles});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  late final PageController _controller;
  int _index = 0;
  Timer? _timer;

  // ---------- Logging helpers ----------
  void _logIncomingProfiles(String tag) {
    if (!kDebugMode) return;
    dev.log('[$tag] profiles.length = ${widget.profiles.length}');
    for (var i = 0; i < widget.profiles.length; i++) {
      dev.log('[$tag] profiles[$i] = ${widget.profiles[i]}');
    }
  }

  void _logSlide(String tag, int i) {
    if (!kDebugMode) return;
    if (i < 0 || i >= widget.profiles.length) return;
    final p = widget.profiles[i];
    final uniqueKey =
        '${p.startDate?.millisecondsSinceEpoch ?? 0}-'
        '${p.endDate?.millisecondsSinceEpoch ?? 0}-'
        '${p.furnaceNo ?? ''}-'
        '${p.materialNo ?? ''}-';
    dev.log('[$tag] slide=$i  uniqueKey=$uniqueKey  payload=$p');
  }

  @override
  void initState() {
    super.initState();
    _controller = PageController();

    _logIncomingProfiles('initState');

    if (widget.profiles.isNotEmpty) {
      _logSlide('initState', 0);
      _dispatchQuery(widget.profiles[0]);
      _startTimerForIndex(0);
    }
  }

  @override
  void didUpdateWidget(covariant HomeContent oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!listEquals(oldWidget.profiles, widget.profiles) &&
        widget.profiles.isNotEmpty) {
      _timer?.cancel();
      _index = 0;
      _controller.jumpToPage(0);

      _logIncomingProfiles('didUpdateWidget');
      _logSlide('didUpdateWidget', 0);

      _dispatchQuery(widget.profiles[0]);
      _startTimerForIndex(0);
    }
  }

  void _dispatchQuery(HomeContentVar p) {
    dev.log('[dispatch] $p');
    context.read<SearchBloc>().add(
      LoadFilteredChartData(
        startDate: p.startDate,
        endDate: p.endDate,
        furnaceNo: p.furnaceNo,
        materialNo: p.materialNo,
      ),
    );
  }

  void _startTimerForIndex(int i) {
    _timer?.cancel();
    if (widget.profiles.isEmpty) return;

    final sec = widget.profiles[i].interval.clamp(1, 600);
    dev.log('[timer] start for slide=$i interval=${sec}s');
    _timer = Timer.periodic(Duration(seconds: sec), (_) {
      if (!mounted || widget.profiles.isEmpty) return;
      final next = (_index + 1) % widget.profiles.length;
      setState(() => _index = next);
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.linear,
      );
      _logSlide('onAutoFlip', next);
      _dispatchQuery(widget.profiles[next]);
      _startTimerForIndex(next); // reset ตาม interval ของสไลด์ใหม่
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profiles = widget.profiles;

    // ----- Single page mode -----
    if (profiles.length <= 1) {
      final q = profiles.isNotEmpty ? profiles.first : const HomeContentVar();
      final uniqueKey =
          '${q.startDate?.millisecondsSinceEpoch ?? 0}-'
          '${q.endDate?.millisecondsSinceEpoch ?? 0}-'
          '${q.furnaceNo ?? ''}-'
          '${q.materialNo ?? ''}-';

      return LayoutBuilder(
        key: ValueKey(uniqueKey),
        builder: (context, constraints) {
          const gap = 16.0;
          final halfW = (constraints.maxWidth - gap) / 2;
          final h = constraints.maxHeight;

          return BlocBuilder<SearchBloc, SearchState>(
            builder: (context, searchState) {
              if (searchState.status == SearchStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (searchState.status == SearchStatus.failure) {
                return Center(child: Text('Error: ${searchState.errorMessage}'));
              }

              return Row(
                children: [
                  // left: Surface Hardness (แบบ medium)
                  SizedBox(
                    width: halfW,
                    height: h,
                    child: _ChartFillBox(
                      child: buildChartsSectionSurfaceHardness(
                        [q],              // ห่อเป็นลิสต์
                        0,                // index เดียว
                        searchState,
                        zoomBuilder: (ctx, profileAtIndex, st) =>
                            buildChartsSectionSurfaceHardnessLarge(
                              profileAtIndex,
                              st,
                              onClose: () => Navigator.of(ctx).maybePop(),
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(width: gap),
                  // right: CDE/CDT (ของเดิมคุณ)
                  Expanded(
                    child: _ChartFillBox(
                      child: buildChartsSectionCdeCdt(q, searchState),
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    }

    // ----- Carousel mode -----
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (i) {
              setState(() => _index = i);
              _logSlide('onPageChanged', i);
              _dispatchQuery(profiles[i]);
              _startTimerForIndex(i);
            },
            itemCount: profiles.length,
            itemBuilder: (ctx, i) => LayoutBuilder(
              builder: (context, constraints) {
                return BlocBuilder<SearchBloc, SearchState>(
                  builder: (context, searchState) {
                    if (searchState.status == SearchStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (searchState.status == SearchStatus.failure) {
                      return Center(child: Text('Error: ${searchState.errorMessage}'));
                    }

                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Row(
                        children: [
                          // left: Surface Hardness (medium + zoom snapshot)
                          Expanded(
                            child: SizedBox(
                              height: constraints.maxHeight - (8 + 16),
                              child: _ChartFillBox(
                                child: buildChartsSectionSurfaceHardness(
                                  profiles, // ทั้งลิสต์
                                  i,        // index ของสไลด์นี้
                                  searchState,
                                  zoomBuilder: (ctx, profileAtIndex, st) =>
                                      buildChartsSectionSurfaceHardnessLarge(
                                        profileAtIndex,
                                        st,
                                        onClose: () => Navigator.of(ctx).maybePop(),
                                      ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // right: CDE/CDT (ของเดิมคุณ)
                          Expanded(
                            child: SizedBox(
                              height: constraints.maxHeight - (8 + 16),
                              child: _ChartFillBox(
                                child: buildChartsSectionCdeCdt(
                                  profiles[i],
                                  searchState,
                                ),
                              ),
                            ),
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

        const SizedBox(height: 8),

        // Dots (เลื่อนหน้าต่าง 6 จุด)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            (profiles.length <= 6) ? profiles.length : 6,
            (dot) {
              final start = (profiles.length <= 6)
                  ? 0
                  : (_index - 3).clamp(0, profiles.length - 6);
              final realIndex = start + dot;
              final isActive = realIndex == _index;

              return AnimatedContainer(
                key: ValueKey(realIndex),
                duration: const Duration(milliseconds: 500),
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
        ),

        const SizedBox(height: 8),
      ],
    );
  }
}

/// บังคับให้ลูกกินพื้นที่เต็มและตัดส่วนเกิน
class _ChartFillBox extends StatelessWidget {
  const _ChartFillBox({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRect(child: SizedBox.expand(child: child));
  }
}
