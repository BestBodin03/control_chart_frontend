import 'dart:async';
import 'dart:developer' as dev;
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
  final bool _showSlider = true;

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
    _hasUserMovedSlider = false; // follow right edge until user moves
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

    // ⭐ Keep snapping to the latest as long as the user hasn't moved the slider
    if (!_hasUserMovedSlider) {
      _winStart = _isAscendingChrono ? _winMaxStart : 0;
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
    final longest = lenA > lenB ? lenA : lenB;

    // ✅ แสดงสไลเดอร์เมื่อมีอะไรให้เลื่อนจริงๆ
    final bool showSliderNeeded = longest > _winSize;

    final int visibleCount = (longest <= 0) ? 0 : _winSize.clamp(1, longest).toInt();

    double sliderWidthForVisible(int count) {
      const double perItem = 8.0;
      const double minW = 140.0;
      const double maxW = 320.0;
      return (count * perItem).clamp(minW, maxW);
    }

    final sliderWidth = sliderWidthForVisible(visibleCount);

    // ถ้าไม่ใช้ปุ่มไอคอนแล้ว ไม่ต้องเผื่อ _iconW
    final all = searchState.chartDataPoints;
    final reservedLeftWidth = showSliderNeeded ? (sliderWidth + _gap) : 0.0;
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

    final double sliderValue = _isAscendingChrono
        ? _winStart.toDouble()
        : (_winMaxStart - _winStart).toDouble();

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

    return SizedBox(
      height: _rowH,
      child: Stack(
        alignment: Alignment.center,
        children: [
          IgnorePointer(child: dots()),
          Row(
            children: [
              SizedBox(
                width: reservedLeftWidth,
                child: showSliderNeeded
                    ? Row(
                        children: [
                          // ✅ แก้ Visibility เงื่อนไขให้โชว์เมื่อยาวกว่า window
                          Visibility(
                            visible: showSliderNeeded,
                            child: SizedBox(
                              width: sliderWidth,
                              child: IgnorePointer(
                                ignoring: !_showSlider,
                                child: AnimatedOpacity(
                                  opacity: _showSlider ? 1.0 : 0.0,
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                  child: SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      thumbColor: AppColors.colorBrand,
                                      activeTrackColor: AppColors.colorBrandTp,
                                      trackHeight: 2,
                                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                    ),                         
                                    child: Slider(
  min: 0,
  max: _winMaxStart.toDouble(),
  divisions: _winMaxStart > 0 ? _winMaxStart : null,
  value: _isAscendingChrono ? _winStart.toDouble()
                            : (_winMaxStart - _winStart).toDouble(),
  onChanged: (v) => setState(() {
    _hasUserMovedSlider = true; // stop auto-following
    final raw = v.round().clamp(0, _winMaxStart);
    _winStart = _isAscendingChrono ? raw : (_winMaxStart - raw);
  }),
)

                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: _gap),
                        ],
                      )
                    : null,
              ),
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
