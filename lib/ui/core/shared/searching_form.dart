import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/data/cubit/searching/utils/search_control.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/shared/form_component.dart';
import 'package:control_chart/ui/core/shared/gradient_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../data/cubit/searching/filters_cubit.dart';
import '../../../data/cubit/searching/options_cubit.dart';
import '../../../data/cubit/searching/utils/mapper.dart';
import '../../../utils/date_convertor.dart';
import '../../screen/screen_content/home_screen_content/home_content_var.dart';

class SearchingForm extends StatelessWidget {
  const SearchingForm({
    super.key,
    this.initialProfile,
    this.loadFurnaces,
    this.loadMaterials,
    this.loadCpNames, // << เพิ่ม loader cpNames (matNo -> cpName)
  });

  final HomeContentVar? initialProfile;
  final Future<List<String>> Function()? loadFurnaces;
  final Future<List<String>> Function()? loadMaterials;
  final Future<Map<String, String>> Function()? loadCpNames;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => FiltersCubit()),
BlocProvider(
  create: (_) => OptionsCubit(
    loadFurnaces: loadFurnaces ?? () async => ['0', '1', '2'],
    loadMaterials: loadMaterials ?? () async => [],
    loadCpNames: loadCpNames, // อาจเป็น null ได้
  )..load(),
),
      ],
      child: _SearchingFormBody(initialProfile: initialProfile),
    );
  }
}

class _SearchingFormBody extends StatefulWidget {
  const _SearchingFormBody({required this.initialProfile});
  final HomeContentVar? initialProfile;

  @override
  State<_SearchingFormBody> createState() => _SearchingFormBodyState();
}

class _SearchingFormBodyState extends State<_SearchingFormBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final s = context.read<SearchBloc>().state;
      context.read<FiltersCubit>().hydrate(s.currentQuery.startDate, s.currentQuery.endDate);
      _applyProfileIfNeeded(widget.initialProfile);

      // สำคัญ: handler LoadDropdownOptions ต้อง "pure" ไม่รีเซ็ต selection ปัจจุบัน
      context.read<SearchBloc>().add(const LoadDropdownOptions());
    });
  }

  @override
  void didUpdateWidget(covariant _SearchingFormBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialProfile != widget.initialProfile) {
      _applyProfileIfNeeded(widget.initialProfile);
    }
  }

  void _applyProfileIfNeeded(HomeContentVar? p) {
    if (p == null) return;

    final last = context.read<FiltersCubit>().state.lastAppliedProfile;
    if (_isSameProfile(p, last)) return;

    context.read<FiltersCubit>().applyProfile(p);

    final searchState = context.read<SearchBloc>().state;
    final uiFurnace = searchState.currentFurnaceUiValue;   // "0","1","2"
    final uiMaterial = searchState.currentMaterialUiValue; // "All Material No.","24009254"

    final int? profileFurnace = _coerceInt(p.furnaceNo);
    final String? profileMat  = _coerceMat(p.materialNo);

    final int? furnace = profileFurnace ?? furnaceIntFromUi(uiFurnace);
    final String? mat  = profileMat ?? materialFromUi(uiMaterial);

    final fs = context.read<FiltersCubit>().state;
    SearchControl.run(
      ctx: context,
      start: fs.startDate,
      end: fs.endDate,
      furnaceInt: furnace,
      materialStr: mat,
    );

    context.read<SearchBloc>().add(const LoadDropdownOptions());
  }

  bool _isSameProfile(HomeContentVar? a, HomeContentVar? b) {
    if (a == null || b == null) return false;
    return _isSameDate(a.startDate, b.startDate) &&
        _isSameDate(a.endDate, b.endDate) &&
        (_coerceInt(a.furnaceNo) == _coerceInt(b.furnaceNo)) &&
        ((_coerceMat(a.materialNo) ?? '') == (_coerceMat(b.materialNo) ?? ''));
  }

  bool _isSameDate(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.toUtc().millisecondsSinceEpoch == b.toUtc().millisecondsSinceEpoch;
  }

  int? _coerceInt(Object? v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is String) return int.tryParse(v.trim());
    return int.tryParse(v.toString());
  }

  String? _coerceMat(Object? v) {
    if (v == null) return null;
    final s = v.toString().trim();
    if (s.isEmpty || s == 'All Material No.') return null;
    return s;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      buildWhen: (a, b) =>
          a.currentQuery != b.currentQuery ||
          a.furnaceOptions != b.furnaceOptions ||
          a.materialOptions != b.materialOptions ||
          a.optionsLoading != b.optionsLoading ||
          a.optionsError != b.optionsError ||
          a.currentFurnaceUiValue != b.currentFurnaceUiValue ||
          a.currentMaterialUiValue != b.currentMaterialUiValue,
      builder: (context, searchState) {
        return BlocBuilder<FiltersCubit, FiltersState>(
          builder: (context, filters) {
            final sDate = filters.startDate ?? searchState.currentQuery.startDate;
            final eDate = filters.endDate ?? searchState.currentQuery.endDate;
            final dateNow = DateTime.now();
            final dateOneM = oneMonthAgo(dateNow);


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
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header + refresh
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
                                    context.read<FiltersCubit>().setPeriod('1 เดือน', start: oneMonthAgo(dateNow), end: dateNow);
                                    context.read<SearchBloc>().add(LoadFilteredChartData());
                                    // context.read<FiltersCubit>().setPeriod('1 เดือน', start: oneMonthAgo(dateNow), end: dateNow);
                                  },
                                  icon: const Icon(Icons.refresh_rounded, size: 24, color: AppColors.colorBrand),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // Period dropdown (FiltersCubit only)
                            buildDropdownField(
                              context: context,
                              value: filters.periodValue,
                              items: const ['1 เดือน', '3 เดือน', '6 เดือน', '1 ปี', 'ตลอดเวลา', 'กำหนดเอง'],
                              onChanged: (value) {
                                if (value == null) return;
                                final now = DateTime.now();
                                DateTime? newStart, newEnd = now;

                                switch (value) {
                                  case '1 เดือน':
                                    newStart = DateTime(now.year, now.month - 1, now.day);
                                    break;
                                  case '3 เดือน':
                                    newStart = DateTime(now.year, now.month - 3, now.day);
                                    break;
                                  case '6 เดือน':
                                    newStart = DateTime(now.year, now.month - 6, now.day);
                                    break;
                                  case '1 ปี':
                                    newStart = DateTime(now.year - 1, now.month, now.day);
                                    break;
                                  case 'ตลอดเวลา':
                                    newStart = DateTime(2024, 1, 1);
                                    break;
                                  default:
                                    newStart = filters.startDate;
                                    newEnd = filters.endDate ?? now;
                                }

                                context.read<FiltersCubit>().setPeriod(value, start: newStart, end: newEnd);

                                if (value != 'กำหนดเอง') {
                                  final int? furnace = furnaceIntFromUi(searchState.currentFurnaceUiValue);
                                  final String? mat = materialFromUi(searchState.currentMaterialUiValue);

                                  context.read<SearchBloc>().add(LoadFilteredChartData(
                                    startDate: newStart,
                                    endDate: newEnd,
                                    furnaceNo: furnace.toString(),
                                    materialNo: mat,
                                  ));
                                  context.read<SearchBloc>().add(const LoadDropdownOptions());
                                }
                              },
                            ),

                            const SizedBox(height: 16),

                            // Date range
                            Row(
                              children: [
                                Expanded(
                                  child: buildDateField(
                                    context: context,
                                    value: sDate,
                                    label: _dateLabel(sDate) ?? 'Select Date',
                                    date: sDate ?? DateTime.now(),
                                    onTap: () => _pickDate(context, isStart: true),
                                    onChanged: (d) {
                                      if (d == null) return;
                                      context.read<FiltersCubit>().setStartDate(d);

                                      final int? furnace = furnaceIntFromUi(searchState.currentFurnaceUiValue);
                                      final String? mat = materialFromUi(searchState.currentMaterialUiValue);

                                      final fs = context.read<FiltersCubit>().state;
                                      context.read<SearchBloc>().add(LoadFilteredChartData(
                                        startDate: fs.startDate,
                                        endDate: fs.endDate,
                                        furnaceNo: furnace.toString(),
                                        materialNo: mat,
                                      ));
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
                                    onTap: () => _pickDate(context, isStart: false),
                                    onChanged: (d) {
                                      if (d == null) return;
                                      context.read<FiltersCubit>().setEndDate(d);

                                      final int? furnace = furnaceIntFromUi(searchState.currentFurnaceUiValue);
                                      final String? mat = materialFromUi(searchState.currentMaterialUiValue);

                                      final fs = context.read<FiltersCubit>().state;
                                      context.read<SearchBloc>().add(LoadFilteredChartData(
                                        startDate: fs.startDate,
                                        endDate: fs.endDate,
                                        furnaceNo: furnace.toString(),
                                        materialNo: mat,
                                      ));
                                      context.read<SearchBloc>().add(const LoadDropdownOptions());
                                    },
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

buildSectionTitle('หมายเลขเตา'),
const SizedBox(height: 8),
BlocBuilder<OptionsCubit, OptionsState>(
  builder: (context, opts) {
    const allFurnacesLabel = 'All Furnaces';

    // 1) Get furnace options and sort numerically
    debugPrint('🔵 [Furnace] Raw opts.furnaceOptions: ${opts.furnaceOptions}');
    final furnaces = opts.furnaceOptions
        .map((e) => e.toString())
        .where((e) => e.isNotEmpty && e != allFurnacesLabel) // Remove duplicates
        .toSet()
        .toList()
      ..sort((a, b) {
        final ai = int.tryParse(a);
        final bi = int.tryParse(b);
        if (ai == null && bi == null) return a.compareTo(b);
        if (ai == null) return 1;
        if (bi == null) return -1;
        return ai.compareTo(bi);
      });
    
    // Add "All" label at the beginning
    furnaces.insert(0, allFurnacesLabel);
    debugPrint('🔵 [Furnace] Final furnaces list: $furnaces');

    // 2) Safe current value
    String? current = searchState.currentFurnaceUiValue.isEmpty
        ? allFurnacesLabel
        : searchState.currentFurnaceUiValue;
    if (!furnaces.contains(current)) current = allFurnacesLabel;
    debugPrint('🔵 [Furnace] Current value: $current');

    return AbsorbPointer(
      absorbing: opts.loading,
      child: Opacity(
        opacity: opts.loading ? 0.6 : 1,
        child: buildDropdownField(
          key: ValueKey('furnace_$current'),
          context: context,
          hint: allFurnacesLabel,
          value: current == allFurnacesLabel ? null : current,
          items: furnaces,
          onChanged: (selected) {
            final val = (selected == null || selected == allFurnacesLabel)
                ? null
                : selected;
            
            context.read<SearchBloc>().add(SelectFurnace(val));
            
            // Reload material options based on selected furnace
            context.read<OptionsCubit>().loadMaterialsForFurnace(val);

            // Update chart data
            final now = DateTime.now();
            final fallbackStart = now.subtract(const Duration(days: 30));
            final fs = context.read<FiltersCubit>().state;

            context.read<SearchBloc>().add(LoadFilteredChartData(
              startDate: fs.startDate ?? fallbackStart,
              endDate: fs.endDate ?? now,
              furnaceNo: val,
              materialNo: null,
            ));
          },
        ),
      ),
    );
  },
),

const SizedBox(height: 16),

// ============== Material Dropdown ==============
buildSectionTitle('Material No.'),
const SizedBox(height: 8),
BlocBuilder<OptionsCubit, OptionsState>(
  builder: (context, opts) {
    const allLabel = 'All Material Nos.';

    // 1) Get material options and sort numerically
    debugPrint('🟢 [Material] Raw opts.materialOptions: ${opts.materialOptions}');
    debugPrint('🟢 [Material] Raw opts.cpNames: ${opts.cpNames}');
    final materials = opts.materialOptions
        .map((e) => e.toString())
        .where((e) => e.isNotEmpty && e != allLabel) // Remove duplicates
        .toSet()
        .toList()
      ..sort((a, b) {
        final ai = int.tryParse(a);
        final bi = int.tryParse(b);
        if (ai == null && bi == null) return a.compareTo(b);
        if (ai == null) return 1;
        if (bi == null) return -1;
        return ai.compareTo(bi);
      });
    
    // Add "All" label at the beginning
    materials.insert(0, allLabel);
    debugPrint('🟢 [Material] Final materials list: $materials');

    // 2) Build display items with cpName (matNo - cpName)
    final items = materials.map((matNo) {
      if (matNo == allLabel) return allLabel;
      final cpNames = opts.cpNames;
      final idx = opts.materialOptions.indexOf(matNo);
      debugPrint('🟢 [Material] matNo: $matNo, idx: $idx, cpName: ${idx >= 0 && idx < cpNames.length ? cpNames[idx] : "NOT FOUND"}');
      return (idx >= 0 && idx < cpNames.length && cpNames[idx].isNotEmpty)
          ? "$matNo - ${cpNames[idx]}"
          : matNo;
    }).toList();
    debugPrint('🟢 [Material] Final items with cpNames: $items');

    // 3) Safe current value (strip cpName if present)
    String? current = searchState.currentMaterialUiValue.isEmpty
        ? allLabel
        : searchState.currentMaterialUiValue;
    if (current != null && current != allLabel && current.contains(' - ')) {
      current = current.split(' - ').first;
    }
    if (!materials.contains(current)) current = allLabel;
    debugPrint('🟢 [Material] Current value: $current');

    return AbsorbPointer(
      absorbing: opts.loading,
      child: Opacity(
        opacity: opts.loading ? 0.6 : 1,
        child: buildDropdownField(
          key: ValueKey('material_$current'),
          context: context,
          hint: allLabel,
          value: current == allLabel ? null : current,
          items: items,
          onChanged: (selected) {
            final val = (selected == null || selected == allLabel)
                ? null
                : selected?.split(' - ').first; // Strip cpName
            
            context.read<SearchBloc>().add(SelectMaterial(val));

            // Update chart data
            final now = DateTime.now();
            final fallbackStart = now.subtract(const Duration(days: 30));
            final fs = context.read<FiltersCubit>().state;
            final furnace = searchState.currentFurnaceUiValue.isEmpty
                ? null
                : searchState.currentFurnaceUiValue;

            context.read<SearchBloc>().add(LoadFilteredChartData(
              startDate: fs.startDate ?? fallbackStart,
              endDate: fs.endDate ?? now,
              furnaceNo: furnace,
              materialNo: val,
            ));
          },
        ),
      ),
    );
  },
),





                            if (searchState.optionsError != null) ...[
                              const SizedBox(height: 8),
                              Text(searchState.optionsError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
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
      },
    );
  }

  static String? _dateLabel(DateTime? d) => d == null ? null : DateFormat('MM/dd/yy').format(d);

  Future<void> _pickDate(BuildContext context, {required bool isStart}) async {
    final s = context.read<SearchBloc>().state;
    final f = context.read<FiltersCubit>().state;

    final initial = isStart
        ? (f.startDate ?? s.currentQuery.startDate ?? DateTime.now())
        : (f.endDate ?? s.currentQuery.endDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2024),
      lastDate: DateTime(2050),
    );
    if (picked == null) return;

    if (isStart) {
      context.read<FiltersCubit>().setStartDate(picked);
    } else {
      context.read<FiltersCubit>().setEndDate(picked);
    }

    final int? furnace = furnaceIntFromUi(s.currentFurnaceUiValue);
    final String? mat = materialFromUi(s.currentMaterialUiValue);

    final fs = context.read<FiltersCubit>().state;
    context.read<SearchBloc>().add(LoadFilteredChartData(
      startDate: fs.startDate,
      endDate: fs.endDate,
      furnaceNo: furnace.toString(),
      materialNo: mat,
    ));

    context.read<SearchBloc>().add(const LoadDropdownOptions());
  }
}
