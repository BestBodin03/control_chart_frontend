import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/shared/form_component.dart';
import 'package:control_chart/ui/core/shared/gradient_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../screen/screen_content/home_screen_content/home_content_var.dart';

class SearchingForm extends StatefulWidget {
  const SearchingForm({super.key, this.initialProfile});
  final HomeContentVar? initialProfile;

  @override
  State<SearchingForm> createState() => _SearchingFormState();
}

class _SearchingFormState extends State<SearchingForm> {
  // Local UI state (same UX as before)
  String _periodValue = 'กำหนดเอง';
  DateTime? _startDate;
  DateTime? _endDate;
  HomeContentVar? _lastAppliedProfile;

  @override
  void initState() {
    super.initState();
    // Sync initial UI with current query and load dropdown options
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final q = context.read<SearchBloc>().state.currentQuery;
      setState(() {
        _startDate = q.startDate ?? _startDate;
        _endDate   = q.endDate   ?? _endDate;
      });
      _applyInitialProfileIfNeeded(widget.initialProfile);
      context.read<SearchBloc>().add(const LoadDropdownOptions());
    });
  }

  @override
  void didUpdateWidget(covariant SearchingForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialProfile != widget.initialProfile) {
      _applyInitialProfileIfNeeded(widget.initialProfile);
    }
  }

  void _applyInitialProfileIfNeeded(HomeContentVar? p) {
    if (p == null) return;
    if (_isSameProfile(p, _lastAppliedProfile)) return;

    setState(() {
      _periodValue = 'กำหนดเอง';
      _startDate   = p.startDate;
      _endDate     = p.endDate;
      _lastAppliedProfile = p;
    });

    final s = context.read<SearchBloc>().state;
    _dispatchSearch(
      start: _startDate,
      end: _endDate,
      furnaceInt: _furnaceIntFromState(s),      // int?
      materialStr: _materialStrFromState(s),    // String?
    );

    context.read<SearchBloc>().add(const LoadDropdownOptions());
  }

  bool _isSameProfile(HomeContentVar? a, HomeContentVar? b) {
    if (a == null || b == null) return false;
    return _isSameDate(a.startDate, b.startDate) &&
           _isSameDate(a.endDate,   b.endDate)   &&
           (a.furnaceNo?.toString() == b.furnaceNo?.toString()) &&
           (a.materialNo?.toString() ?? '') == (b.materialNo?.toString() ?? '');
  }

  bool _isSameDate(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.toUtc().millisecondsSinceEpoch == b.toUtc().millisecondsSinceEpoch;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        final sDate = _startDate ?? state.currentQuery.startDate;
        final eDate = _endDate   ?? state.currentQuery.endDate;

        return GradientBackground(
          opacity: 0.2,
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 332,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.colorBg,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.white.withValues(alpha: 0.6), blurRadius: 10, offset: const Offset(-5, -5)),
                    BoxShadow(color: AppColors.colorBrandTp.withValues(alpha: 0.4), blurRadius: 15, offset: const Offset(5, 5)),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with refresh
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            buildSectionTitle('ระยะเวลา'),
IconButton(
  tooltip: 'Refresh',
  padding: const EdgeInsets.all(8),
  constraints: const BoxConstraints(),
  splashRadius: 16,
  onPressed: () {
    final now = DateTime.now();
    final newStart = DateTime(now.year, now.month - 1, now.day);

    // 1) ตั้ง period = '1 เดือน' + อัปเดตช่วงวัน
    setState(() {
      _periodValue = '1 เดือน';
      _startDate = newStart;
      _endDate   = now;
    });

    // 2) ยิงค้นหาโดยรีเซ็ตเตา/วัสดุเป็น All (ส่ง null)
    _dispatchSearch(
      start: _startDate,
      end: _endDate,
      furnaceInt: null,        // ← All
      materialStr: null,       // ← All
    );

    // 3) รีโหลดรายการดรอปดาวน์ (ภายใต้เงื่อนไข All)
    context.read<SearchBloc>().add(const LoadDropdownOptions());
  },
  icon: const Icon(Icons.refresh_rounded, size: 24, color: AppColors.colorBrand),
),

                          ],
                        ),

                        const SizedBox(height: 8),

                        // Period dropdown
                        buildDropdownField(
                          context: context,
                          value: _periodValue,
                          items: const ['1 เดือน', '3 เดือน', '6 เดือน', '1 ปี', 'ตลอดเวลา', 'กำหนดเอง'],
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => _periodValue = value);
                            final now = DateTime.now();
                            DateTime? newStart;
                            DateTime? newEnd = now;

                            switch (value) {
                              case '1 เดือน': newStart = DateTime(now.year, now.month - 1, now.day); break;
                              case '3 เดือน': newStart = DateTime(now.year, now.month - 3, now.day); break;
                              case '6 เดือน': newStart = DateTime(now.year, now.month - 6, now.day); break;
                              case '1 ปี':    newStart = DateTime(now.year - 1, now.month, now.day); break;
                              case 'ตลอดเวลา': newStart = DateTime(2020, 1, 1); break;
                              default: // 'กำหนดเอง'
                                newStart = _startDate;
                                newEnd   = _endDate ?? now;
                                break;
                            }

                            if (value != 'กำหนดเอง') {
                              setState(() {
                                _startDate = newStart;
                                _endDate   = newEnd;
                              });
                              _dispatchSearch(
                                start: _startDate,
                                end: _endDate,
                                furnaceInt: _furnaceIntFromState(state),
                                materialStr: _materialStrFromState(state),
                              );
                              context.read<SearchBloc>().add(const LoadDropdownOptions());
                            }
                          },
                        ),

                        const SizedBox(height: 16),

                        // Date range row
                        Row(
                          children: [
                            Expanded(
                              child: buildDateField(
                                context: context,
                                value: sDate,
                                label: _dateLabel(sDate) ?? 'Select Date',
                                date: sDate ?? DateTime.now(),
                                onTap: () => _selectDate(context, true, state),
                                onChanged: (d) {
                                  if (d == null) return;
                                  setState(() {
                                    _periodValue = 'กำหนดเอง';
                                    _startDate = d;
                                  });
                                  _dispatchSearch(
                                    start: _startDate,
                                    end: _endDate ?? state.currentQuery.endDate ?? DateTime.now(),
                                    furnaceInt: _furnaceIntFromState(state),
                                    materialStr: _materialStrFromState(state),
                                  );
                                  context.read<SearchBloc>().add(const LoadDropdownOptions());
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Text('ถึง', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: buildDateField(
                                context: context,
                                value: eDate,
                                label: _dateLabel(eDate) ?? 'Select Date',
                                date: eDate ?? DateTime.now(),
                                onTap: () => _selectDate(context, false, state),
                                onChanged: (d) {
                                  if (d == null) return;
                                  setState(() {
                                    _periodValue = 'กำหนดเอง';
                                    _endDate = d;
                                  });
                                  _dispatchSearch(
                                    start: _startDate ?? state.currentQuery.startDate ?? d,
                                    end: _endDate,
                                    furnaceInt: _furnaceIntFromState(state),
                                    materialStr: _materialStrFromState(state),
                                  );
                                  context.read<SearchBloc>().add(const LoadDropdownOptions());
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Furnace
                        buildSectionTitle('หมายเลขเตา'),
                        const SizedBox(height: 8),
                        AbsorbPointer(
                          absorbing: state.optionsLoading,
                          child: Opacity(
                            opacity: state.optionsLoading ? 0.6 : 1,
                            child: buildDropdownField(
                              context: context,
                              hint: "All Furnaces",
                              value: state.currentFurnaceUiValue,    // UI uses "0" for All
                              items: state.furnaceOptions,
                              onChanged: (v) => context.read<SearchBloc>().add(SelectFurnace(v)),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Material
                        buildSectionTitle('Material No.'),
                        const SizedBox(height: 8),
                        AbsorbPointer(
                          absorbing: state.optionsLoading,
                          child: Opacity(
                            opacity: state.optionsLoading ? 0.6 : 1,
                            child: buildDropdownField(
                              context: context,
                              hint: "All Material No.",
                              value: state.currentMaterialUiValue,   // UI uses "All Material No." for All
                              items: state.materialOptions,
                              onChanged: (v) => context.read<SearchBloc>().add(SelectMaterial(v)),
                            ),
                          ),
                        ),

                        if (state.optionsError != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            state.optionsError!,
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ==== Helpers ====

  static DateTime? _toDateTime(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  static String? _dateLabel(DateTime? d) => d == null ? null : DateFormat('MM/dd/yy').format(d);

  /// แปลงค่าจาก state (ที่เป็นค่า UI) → ชนิดจริงที่ต้องส่งให้ Bloc/Search API
  /// Furnace: "0" (All) -> null, อย่างอื่น -> int.tryParse(...)
  int? _furnaceIntFromState(SearchState s) {
    final ui = s.currentFurnaceUiValue;
    if (ui == '0' || ui.isEmpty) return null;
    return int.tryParse(ui);
  }

  /// Material: "All Material No." (All) -> null, อย่างอื่น -> String เดิม
  String? _materialStrFromState(SearchState s) {
    final ui = s.currentMaterialUiValue;
    if (ui == 'All Material No.' || ui.isEmpty) return null;
    return ui;
  }

  void _dispatchSearch({
    required dynamic start,
    required dynamic end,
    int? furnaceInt,
    String? materialStr,
  }) {
    final startDT = start is DateTime ? start : _toDateTime(start);
    final endDT   = end   is DateTime ? end   : _toDateTime(end);
    if (startDT == null || endDT == null) return;

    // ⚠️ หมายเหตุ:
    // - ถ้า Event ของคุณกำหนด furnaceNo เป็น int? แล้ว → ส่ง furnaceInt ตรง ๆ
    // - ถ้ายังเป็น String? อยู่ → เปลี่ยนเป็น furnaceInt?.toString()
    context.read<SearchBloc>().add(LoadFilteredChartData(
      startDate: startDT,
      endDate:   endDT,
      furnaceNo: furnaceInt?.toString(), // << ถ้าคุณแก้ event เป็น int? ให้เปลี่ยนบรรทัดนี้เป็น furnaceNo: furnaceInt,
      materialNo: materialStr,           // String? อยู่แล้ว OK
    ));
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate, SearchState searchState) async {
    final initial = isStartDate
        ? (_startDate ?? searchState.currentQuery.startDate ?? DateTime.now())
        : (_endDate   ?? searchState.currentQuery.endDate   ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2050),
    );
    if (picked == null) return;

    setState(() {
      _periodValue = 'กำหนดเอง';
      if (isStartDate) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
    });

    _dispatchSearch(
      start: _startDate ?? picked,
      end: _endDate ?? picked,
      furnaceInt: _furnaceIntFromState(searchState),
      materialStr: _materialStrFromState(searchState),
    );

    context.read<SearchBloc>().add(const LoadDropdownOptions());
  }
}
