import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math' as math;

import 'package:control_chart/data/bloc/search_chart_details/extension/search_state_extension.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/domain/models/control_chart_stats.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/shared/large_control_chart/surface_hardness/help.dart';
import 'package:control_chart/ui/core/shared/medium_control_chart/cde_cdt/help.dart';
import 'package:control_chart/ui/core/shared/medium_control_chart/surface_hardness/help.dart';
import 'package:control_chart/ui/screen/screen_content/home_screen_content/home_content_var.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

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

  /// DATA ORDER
  ///
  /// If your incoming data lists are **oldest -> latest** (ascending chronology),
  /// keep [_isAscendingChrono] = true. If you switch to **latest -> oldest**,
  /// set it to false and the slider logic will auto-reverse.
  final bool _isAscendingChrono = true; // <-- set to false if list is latest->oldest
  bool _hasUserMovedSlider = false; // ผู้ใช้ขยับสไลเดอร์แล้วหรือยัง
  bool _didRightSnap = false;       // snap ไปขวาสุดไปแล้วหรือยัง (กัน snap ซ้ำ)



  /// Window selection over data lists. We always want to *show latest 30*.
  int _winStart = 0;    // index start of window
  int _winMaxStart = 0; // max start we can slide to (len - winSize)
  int _winSize = 30;    // window size (30 latest points)
  bool _showSlider = false;

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
    final uniqueKey = '${p.startDate?.millisecondsSinceEpoch ?? 0}-${p.endDate?.millisecondsSinceEpoch ?? 0}-${p.furnaceNo ?? ''}-${p.materialNo ?? ''}-';
    dev.log('[$tag] slide=$i  uniqueKey=$uniqueKey  payload=$p');
  }

  /// Compute base values when data length changes.
  /// If ascending (oldest->latest), start = len - winSize (latest window).
  /// If descending (latest->oldest), start = 0 (latest at index 0).
  void _recomputeWindow(List<dynamic> data) {
    final total = data.length;
    _winSize = total < 30 ? total : 30;
    _winMaxStart = (total - _winSize).clamp(0, total);
    _winStart = _isAscendingChrono ? _winMaxStart : 0;
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

    if (!listEquals(oldWidget.profiles, widget.profiles) && widget.profiles.isNotEmpty) {
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
    // ให้สไลเดอร์เริ่มขวาสุดเมื่อได้ข้อมูลชุดใหม่
    _hasUserMovedSlider = false;
    _didRightSnap = false;

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

    final sec = widget.profiles[i].interval.clamp(1, 600).toInt();
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
      _startTimerForIndex(next);
    });
  }

  /// Recompute window bounds based on the longer of the two charts so the slider
  /// controls both consistently. Keep winStart valid and winSize clamped to <=30.
  void _recalcWindowBounds(SearchState st) {
    final lenA = st.chartDataPoints.length;
    final lenB = st.chartDataPointsCdeCdt.length;
    final longest = lenA > lenB ? lenA : lenB;

    _winSize = longest < 30 ? longest : 30;

    if (longest <= 0) {
      _winMaxStart = 0;
      _winStart = 0;
      return;
    }

    _winMaxStart = longest > _winSize ? (longest - _winSize) : 0;

    // ★ Snap ไปขวาสุดหนึ่งครั้ง เมื่อข้อมูลชุดนี้พร้อม และผู้ใช้ยังไม่ขยับเอง
    if (!_hasUserMovedSlider && !_didRightSnap) {
      _winStart = _isAscendingChrono ? _winMaxStart : 0;
      _didRightSnap = true; // กัน snap ซ้ำระหว่าง build/rebuild
    }

    if (_winStart > _winMaxStart) _winStart = _winMaxStart;
    if (_winStart < 0) _winStart = 0;
  }


  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profiles = widget.profiles; // your query presets

    // ----- Single page mode -----
    if (profiles.length <= 1) {
      final q = profiles.isNotEmpty ? profiles.first : const HomeContentVar();
      final uniqueKey = '${q.startDate?.millisecondsSinceEpoch ?? 0}-${q.endDate?.millisecondsSinceEpoch ?? 0}-${q.furnaceNo ?? ''}-${q.materialNo ?? ''}-';

      return LayoutBuilder(
        key: ValueKey(uniqueKey),
        builder: (context, constraints) {
          final h = constraints.maxHeight;

          return BlocBuilder<SearchBloc, SearchState>(
            builder: (context, searchState) {
              if (searchState.status == SearchStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (searchState.status == SearchStatus.failure) {
                return Center(child: Text('Error: ${searchState.errorMessage}'));
              }

              // keep slider bounds fresh
              _recalcWindowBounds(searchState);

              return Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        // left: Surface Hardness
                        Expanded(
                          child: SizedBox(
                            height: h,
                            child: _ChartFillBox(
                              child: buildChartsSectionSurfaceHardness(
                                [q],
                                0,
                                searchState,
                                externalStart: _winStart,
                                externalWindowSize: _winSize,
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

                        // right: CDE/CDT
                        Expanded(
                          child: _ChartFillBox(
                            child: buildChartsSectionCdeCdt(
                              q,
                              searchState,
                              _winStart,
                              _winSize,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  _buildDotsAndRightSlider(profiles.length, searchState),

                  const SizedBox(height: 8),
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

                    // keep slider bounds fresh
                    _recalcWindowBounds(searchState);

                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Column(
                        children: [
                          // charts row
                          Expanded(
                            child: Row(
                              children: [
                                // Surface Hardness
                                Expanded(
                                  child: SizedBox(
                                    height: constraints.maxHeight - (8 + 16),
                                    child: _ChartFillBox(
                                      child: buildChartsSectionSurfaceHardness(
                                        profiles,
                                        i,
                                        searchState,
                                        externalStart: _winStart,
                                        externalWindowSize: _winSize,
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

                                // CDE/CDT (hide if NA)
                                Visibility(
                                  visible: searchState.controlChartStats?.secondChartSelected !=
                                      SecondChartSelected.na,
                                  child: Expanded(
                                    child: SizedBox(
                                      height: constraints.maxHeight - (8 + 16),
                                      child: _ChartFillBox(
                                        child: buildChartsSectionCdeCdt(
                                          profiles[i],
                                          searchState,
                                          _winStart,
                                          _winSize,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          _buildDotsAndRightSlider(profiles.length, searchState),
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
  }

  /// Dots centered + right-aligned slider toggle.
  /// Slider width scales with visible data (window), and the row height is fixed by the caller.
  // constants for consistent layout
  static const double _rowH = 40.0;
  static const double _iconW = 40.0;   // exact width we reserve for the IconButton
  static const double _gap   = 8.0;

  Widget _buildDotsAndRightSlider(int profilesLength, SearchState searchState) {
    final lenA = searchState.chartDataPoints.length;
    final lenB = searchState.chartDataPointsCdeCdt.length;
    final hasAnyData = (lenA > 0) || (lenB > 0);

    // for label boundary safety use chartDataPoints length
    final allLen = lenA;

    final longest = lenA > lenB ? lenA : lenB;
    final int visibleCount = (longest <= 0) ? 0 : _winSize.clamp(1, longest).toInt();

    final all = searchState.chartDataPoints;

    // หา start และ end date ของ window
    final DateTime? startDate = 
        (all.isNotEmpty && _winStart < all.length) 
            ? all[_winStart].collectDate 
            : null;

    final DateTime? endDate = 
        (all.isNotEmpty && (_winStart + _winSize - 1) < all.length) 
            ? all[_winStart + _winSize - 1].collectDate 
            : null;

    // ฟอร์แมตวันที่
    final df = DateFormat('d MMM'); // เช่น 1 Jan
    final String labelText = 
        '${startDate != null ? df.format(startDate) : ''}'
        ' - '
        '${endDate != null ? df.format(endDate) : ''}';

    double sliderWidthForVisible(int count) {
      const double perItem = 8.0;
      const double minW = 140.0;
      const double maxW = 320.0;
      return (count * perItem).clamp(minW, maxW);
    }

    final sliderWidth = sliderWidthForVisible(visibleCount);
    final reservedLeftWidth = hasAnyData ? (_iconW + sliderWidth + _gap) : 0.0;

    // Dots widget
    Widget dots() => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            (profilesLength <= 6) ? profilesLength : 6,
            (dot) {
              final start = (profilesLength <= 6)
                  ? 0
                  : (_index - 3).clamp(0, profilesLength - 6);
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
        );

    // Clamp label end safely against allLen
    final int labelEnd = math.min(allLen, _winStart + _winSize);

    // Map slider value depending on data order
    final double sliderValue = _isAscendingChrono
        ? _winStart.toDouble() // rightmost == latest window
        : (_winStart - _winMaxStart).toDouble(); // reversed mapping

    return SizedBox(
      height: _rowH, // fixed height, charts won't jiggle
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Centered dots, always perfectly centered relative to full width
          // IgnorePointer so slider remains fully interactive
          IgnorePointer(child: dots()),

          // Foreground row for left controls (icon + slider)
          Row(
            children: [
              // Left: fixed-width area for icon + slider (space always reserved if any data)
              SizedBox(
                width: reservedLeftWidth,
                child: hasAnyData
                    ? Row(
                        children: [
                          // Exact-size IconButton so our reserved width matches reality
                          Visibility(
                            visible: searchState.chartDataPoints.length > _winMaxStart ||
                                searchState.chartDataPointsCdeCdt.length > _winMaxStart,
                            child: IconButton(
                              tooltip: 'Window slider',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints.tightFor(
                                width: _iconW,
                                height: _rowH,
                              ),
                              splashRadius: 18,
                              icon: Icon(
                                _showSlider ? Icons.tune : Icons.tune_outlined,
                                size: 20,
                                color: AppColors.colorBrand,
                              ),
                              onPressed: () => setState(() => _showSlider = !_showSlider),
                            ),
                          ),

                          // Slider area (always reserved; just faded)
                          SizedBox(
                            width: sliderWidth,
                            child: IgnorePointer(
                              ignoring: !_showSlider,
                              child: AnimatedOpacity(
                                opacity: _showSlider ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    trackHeight: 2,
                                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                  ),
                                  child: Slider(
                                    thumbColor: AppColors.colorBrandTp,
                                    activeColor: const Color.fromARGB(255, 142, 181, 206),
                                    min: 0,
                                    max: _winMaxStart.toDouble(),
                                    divisions: _winMaxStart > 0 ? _winMaxStart : null,
                                    value: sliderValue,
                                    label: labelText, // ✅ ใช้วันที่แทน index
                                    onChanged: (v) => setState(() {
                                      _hasUserMovedSlider = true;
                                      _winStart = _isAscendingChrono
                                          ? v.round().clamp(0, _winMaxStart)
                                          : (_winMaxStart - v.round()).clamp(0, _winMaxStart);
                                    }),
                                  )
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: _gap),
                        ],
                      )
                    : null,
              ),

              // Fill the rest; dots remain centered because they are on the Stack center
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }
}

/// Forces child to fill and clips overflow
class _ChartFillBox extends StatelessWidget {
  const _ChartFillBox({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRect(child: SizedBox.expand(child: child));
  }
}
