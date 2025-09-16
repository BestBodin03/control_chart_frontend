import 'dart:async';
import 'dart:developer' as dev;
import 'package:control_chart/data/bloc/search_chart_details/extension/search_state_extension.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/shared/large_control_chart/surface_hardness/help.dart' as sh_large;
// import 'package:control_chart/ui/core/shared/medium_control_chart/cde_cdt/help.dart' as cde_cdt;
import 'package:control_chart/ui/core/shared/medium_control_chart/surface_hardness/help.dart' as sh_medium;
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

  /// ทิศทางเวลา (ใช้เฉพาะตอน auto-snap ไปขวาสุด)
  final bool _isAscendingChrono = true;
  bool _hasUserMovedSlider = false;

  /// หน้าต่างอิง "labels" (xAxisMediumLabel) ไม่ใช่จำนวนจุด
  int _winStart = 0;     // index เริ่มของหน้าต่างใน labels
  int _winMaxStart = 0;  // ค่าสูงสุดที่เลื่อนได้
  int _winSize = 6;      // = xTick เสมอ

  // ---------- Logging ----------
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
        '${p.startDate?.microsecondsSinceEpoch ?? 0}-${p.endDate?.microsecondsSinceEpoch ?? 0}-${p.furnaceNo ?? ''}-${p.materialNo ?? ''}-';
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
    _hasUserMovedSlider = false; // ติดขอบขวาจนกว่าผู้ใช้จะขยับเอง
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

  // ---------------- STEP 1: คิดหน้าต่างจาก labels + xTick ----------------

  /// แปลง labels จาก state เป็น List<DateTime> (local)
  List<DateTime> _labelsFromState(SearchState st) {
    final raw = st.controlChartStats?.xAxisMediumLabel ?? const[];
    if (raw is List<DateTime>) {
      return raw.map((d) => d.toLocal()).toList();
    }
    if (raw is List) {
      return raw
          .map((e) {
            if (e is DateTime) return e.toLocal();
            if (e is String) {
              try { return DateTime.parse(e.toIso8601String()).toLocal(); } catch (_) {}
            }
            return null;
          })
          .whereType<DateTime>()
          .toList();
    }
    return const <DateTime>[];
  }

  /// คำนวณหน้าต่าง “ตาม label”
  void _recalcWindowByLabels(SearchState st) {
    final labels = _labelsFromState(st);
    final labelCount = labels.length;

    final int xTick = (st.controlChartStats?.xTick ?? 6).clamp(1, 100);
    _winSize = labelCount > 0 ? xTick.clamp(1, labelCount) : xTick;

    if (labelCount <= 0) {
      _winMaxStart = 0;
      _winStart = 0;
      return;
    }

    _winMaxStart = (labelCount - _winSize).clamp(0, labelCount);
    if (!_hasUserMovedSlider) {
      // เกาะขวาสุด (แสดง label ล่าสุดตาม xTick)
      _winStart = _isAscendingChrono ? _winMaxStart : 0;
    }
    if (_winStart > _winMaxStart) _winStart = _winMaxStart;
    if (_winStart < 0) _winStart = 0;
  }

  /// คืนช่วงวันที่ (ซ้าย-ขวา) ของ “หน้าต่าง label ปัจจุบัน”
  (DateTime?, DateTime?) _currentLabelWindowRange(SearchState st) {
    final labels = _labelsFromState(st);
    if (labels.isEmpty) return (null, null);

    final int s = _winStart.clamp(0, labels.length - 1);
    final int e = (_winStart + _winSize - 1).clamp(0, labels.length - 1);
    return (labels[s], labels[e]);
  }

  // ---------------- STEP 2: สวมช่วงเวลา (xStart/xEnd) ลงในโปรไฟล์ที่จะส่งเข้ากราฟ ----------------

  HomeContentVar _applyRangeToProfile(HomeContentVar base, DateTime? start, DateTime? end) {
    // ถ้าไม่มี label ให้ fallback เป็นช่วงเดิมของโปรไฟล์
    final DateTime effStart = start ?? base.startDate ?? DateTime.now().toLocal();
    final DateTime effEnd   = end   ?? base.endDate   ?? effStart.add(const Duration(hours: 1));

    // ถ้ามี copyWith ก็ใช้ copyWith; ถ้าไม่มี สร้างใหม่แทน
    return base.copyWith(
      startDate: effStart,
      endDate: effEnd,
    );
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

    // ----- Single page -----
    if (profiles.length <= 1) {
      final q = profiles.isNotEmpty ? profiles.first : const HomeContentVar();
      final uniqueKey =
          '${q.startDate?.microsecondsSinceEpoch ?? 0}-${q.endDate?.microsecondsSinceEpoch ?? 0}-${q.furnaceNo ?? ''}-${q.materialNo ?? ''}-';

      return LayoutBuilder(
        key: ValueKey(uniqueKey),
        builder: (context, constraints) {
          final h = constraints.maxHeight;

          return BlocBuilder<SearchBloc, SearchState>(
            builder: (context, st) {
              if (st.status == SearchStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (st.status == SearchStatus.failure) {
                return Center(child: Text('Error: ${st.errorMessage}'));
              }

              // STEP 1: คำนวณหน้าต่างจาก labels + xTick
              _recalcWindowByLabels(st);

              // STEP 2: เอาช่วง (ซ้าย-ขวา) ของหน้าต่าง label มา “สวม” ลงโปรไฟล์
              final (left, right) = _currentLabelWindowRange(st);
              final qWindow = _applyRangeToProfile(q, left, right);

              return Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        // Surface Hardness only
                        Expanded(
                          child: SizedBox(
                            height: h,
                            child: _ChartFillBox(
                              child: sh_medium.buildChartsSectionSurfaceHardness(
                                [qWindow], // << ส่งโปรไฟล์ที่ถูกสวมช่วงเวลาแล้ว
                                0,
                                st,
                                // externalStart/externalWindowSize ยังส่งไว้ให้กลไกเดิม (ถ้า builder ใช้)
                                externalStart: _winStart,
                                externalWindowSize: _winSize,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildLabelWindowSliderSingle(st), // สไลเดอร์อิง labels
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
                  builder: (context, st) {
                    if (st.status == SearchStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (st.status == SearchStatus.failure) {
                      return Center(child: Text('Error: ${st.errorMessage}'));
                    }

                    // STEP 1
                    _recalcWindowByLabels(st);

                    // STEP 2
                    final (left, right) = _currentLabelWindowRange(st);
                    final q = profiles[i];
                    final qWindow = _applyRangeToProfile(q, left, right);

                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Column(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: constraints.maxHeight - (8 + 16),
                                    child: _ChartFillBox(
                                      child: sh_medium.buildChartsSectionSurfaceHardness(
                                        profiles
                                            .toList()
                                            ..[i] = qWindow, // ใส่โปรไฟล์ที่สวมช่วงเวลาแล้ว ณ index นี้
                                        i,
                                        st,
                                        externalStart: _winStart,
                                        externalWindowSize: _winSize,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                              ],
                            ),
                          ),
                          _buildLabelWindowSliderCarousel(profiles.length, st),
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

  // ---------------- Slider (อิง labels) ----------------

  static const double _rowH = 40.0;
  static const double _gap = 8.0;

  String _formatDateRange(DateTime? a, DateTime? b) {
    final df = DateFormat('d MMM');
    final left = (a != null) ? df.format(a) : '';
    final right = (b != null) ? df.format(b) : '';
    return '$left - $right';
  }

  Widget _buildLabelWindowSliderSingle(SearchState st) {
    final labels = _labelsFromState(st);
    final bool showSliderNeeded = labels.length > _winSize;

    final (l, r) = _currentLabelWindowRange(st);
    final labelText = _formatDateRange(l, r);

    return SizedBox(
      height: _rowH,
      child: Row(
        children: [
          SizedBox(
            width: showSliderNeeded ? (200 + _gap) : 0.0,
            child: showSliderNeeded
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(labelText, style: const TextStyle(fontSize: 12)),
                      Slider(
                        min: 0,
                        max: _winMaxStart.toDouble(),
                        divisions: _winMaxStart > 0 ? _winMaxStart : null,
                        value: _winStart.toDouble(),
                        onChanged: (v) => setState(() {
                          _hasUserMovedSlider = true;
                          _winStart = v.round().clamp(0, _winMaxStart);
                        }),
                      ),
                    ],
                  )
                : null,
          ),
          const Expanded(child: SizedBox()),
        ],
      ),
    );
  }

  Widget _buildLabelWindowSliderCarousel(int profilesLength, SearchState st) {
    final labels = _labelsFromState(st);
    final bool showSliderNeeded = labels.length > _winSize;

    // ความกว้างสไลเดอร์ (ดีไซน์เดิม)
    double sliderWidthForVisible(int count) {
      const double perItem = 8.0;
      const double minW = 140.0;
      const double maxW = 320.0;
      return (count * perItem).clamp(minW, maxW);
    }
    final sliderWidth = sliderWidthForVisible(_winSize);
    final reservedLeftWidth = showSliderNeeded ? (sliderWidth + _gap) : 0.0;

    // dots กลางจอ (ดีไซน์เดิม)
    Widget dots() => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            (profilesLength <= 6) ? profilesLength : 6,
            (dot) {
              final start =
                  (profilesLength <= 6) ? 0 : (_index - 3).clamp(0, profilesLength - 6);
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
                    ? SizedBox(
                        width: sliderWidth,
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
                            value: _winStart.toDouble(),
                            onChanged: (v) => setState(() {
                              _hasUserMovedSlider = true;
                              _winStart = v.round().clamp(0, _winMaxStart);
                            }),
                          ),
                        ),
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

class _ChartFillBox extends StatelessWidget {
  const _ChartFillBox({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRect(child: SizedBox.expand(child: child));
  }
}
