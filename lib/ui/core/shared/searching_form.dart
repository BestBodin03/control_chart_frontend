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
            loadMaterials: loadMaterials ?? () async => ['All Material No.'],
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
                                    context.read<SearchBloc>().add(LoadFilteredChartData());
                                    final now = DateTime.now();
                                    final start = DateTime(now.year, now.month - 1, now.day);
                                    context.read<FiltersCubit>().setPeriod('1 เดือน', start: start, end: now);
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
                                    newStart = DateTime(2020, 1, 1);
                                    break;
                                  default:
                                    newStart = filters.startDate;
                                    newEnd = filters.endDate ?? now;
                                }

                                context.read<FiltersCubit>().setPeriod(value, start: newStart, end: newEnd);

                                if (value != 'กำหนดเอง') {
                                  final int? furnace = furnaceIntFromUi(searchState.currentFurnaceUiValue);
                                  final String? mat = materialFromUi(searchState.currentMaterialUiValue);

                                  SearchControl.run(
                                    ctx: context,
                                    start: newStart,
                                    end: newEnd,
                                    furnaceInt: furnace,
                                    materialStr: mat,
                                  );
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
                                      SearchControl.run(
                                        ctx: context,
                                        start: fs.startDate,
                                        end: fs.endDate ?? DateTime.now(),
                                        furnaceInt: furnace,
                                        materialStr: mat,
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
                                    onTap: () => _pickDate(context, isStart: false),
                                    onChanged: (d) {
                                      if (d == null) return;
                                      context.read<FiltersCubit>().setEndDate(d);

                                      final int? furnace = furnaceIntFromUi(searchState.currentFurnaceUiValue);
                                      final String? mat = materialFromUi(searchState.currentMaterialUiValue);

                                      final fs = context.read<FiltersCubit>().state;
                                      SearchControl.run(
                                        ctx: context,
                                        start: fs.startDate ?? d,
                                        end: fs.endDate,
                                        furnaceInt: furnace,
                                        materialStr: mat,
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
                            BlocBuilder<OptionsCubit, OptionsState>(
                              builder: (context, opts) {
                                // Assuming furnaceOptions is List<String> or List<dynamic>
                                final sortedFurnaceOptions = searchState.furnaceOptions
                                    .map((e) => int.tryParse(e.toString()) ?? 0) // convert to int
                                    .toList()
                                  ..sort(); // sort ascending

                                final sortedStringList = sortedFurnaceOptions.map((e) => e.toString()).toList();

                                return AbsorbPointer(
                                  absorbing: searchState.optionsLoading || opts.loading,
                                  child: Opacity(
                                    opacity: (searchState.optionsLoading || opts.loading) ? 0.6 : 1,
                                    child: buildDropdownField(
                                      key: ValueKey(searchState.currentFurnaceUiValue),
                                      context: context,
                                      hint: "All Furnaces",
                                      value: searchState.currentFurnaceUiValue.isEmpty
                                          ? null
                                          : searchState.currentFurnaceUiValue,
                                      items: sortedStringList,
                                      onChanged: (v) {
                                        context.read<SearchBloc>().add(SelectFurnace(v));
                                        final int? furnace = furnaceIntFromUi(v ?? '0');
                                        final String? mat = materialFromUi(searchState.currentMaterialUiValue);
                                        final fs = context.read<FiltersCubit>().state;
                                        SearchControl.run(
                                          ctx: context,
                                          start: fs.startDate ?? searchState.currentQuery.startDate ?? DateTime.now(),
                                          end: fs.endDate ?? searchState.currentQuery.endDate ?? DateTime.now(),
                                          furnaceInt: furnace,
                                          materialStr: mat,
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 16),

                            // Material (custom dropdown to show "matNo | cpName", value = matNo)
                            buildSectionTitle('Material No.'),
                            const SizedBox(height: 8),
                            BlocBuilder<OptionsCubit, OptionsState>(
                              builder: (context, opts) {
                                const allLabel = 'All Material No.';
                                final cpNames = opts.cpNames; // Map<String,String> : matNo -> cpName

                                // 1) Collect, dedupe, numeric-sort + keep All on top
                                final List<String> options = [
                                  ...searchState.materialOptions.map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty),
                                ];
                                final unique = options.toSet().toList()
                                  ..sort((a, b) {
                                    final ai = int.tryParse(a);
                                    final bi = int.tryParse(b);
                                    if (ai == null && bi == null) return a.compareTo(b);
                                    if (ai == null) return 1;
                                    if (bi == null) return -1;
                                    return ai.compareTo(bi);
                                  });
                                if (!unique.contains(allLabel)) unique.insert(0, allLabel);

                                // 2) Items: value = matNo/All, label = "matNo | cpName"
                                final List<DropdownMenuItem<String>> items = unique.map((matNo) {
                                  if (matNo == allLabel) {
                                    return const DropdownMenuItem<String>(
                                      value: allLabel,
                                      child: Text(allLabel),
                                    );
                                  }
                                  final name = cpNames[matNo];
                                  return DropdownMenuItem<String>(
                                    value: matNo,
                                    child: Text(
                                      (name != null && name.isNotEmpty) ? '$matNo | $name' : matNo,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  );
                                }).toList();

                                // 3) Safe value: normalize "123 | Name" → "123", ensure it exists
                                String? raw = searchState.currentMaterialUiValue.isEmpty
                                    ? null
                                    : searchState.currentMaterialUiValue;
                                if (raw != null && raw != allLabel && raw.contains(' | ')) {
                                  raw = raw.split(' | ').first; // normalize to matNo
                                }
                                final safeValue = (raw == null || !unique.contains(raw)) ? allLabel : raw;

                                return AbsorbPointer(
                                  absorbing: searchState.optionsLoading || opts.loading,
                                  child: Opacity(
                                    opacity: (searchState.optionsLoading || opts.loading) ? 0.6 : 1,
                                    child: DropdownButtonFormField<String>(
                                      key: ValueKey(searchState.currentMaterialUiValue),
                                      value: safeValue,
                                      isExpanded: true,
                                      style: const TextStyle(fontSize: 16.0),
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                      ),
                                      hint: const Text(allLabel),
                                      items: items,
                                      onChanged: (v) {
                                        context.read<SearchBloc>().add(SelectMaterial(v));
                                        final int? furnace = furnaceIntFromUi(searchState.currentFurnaceUiValue);
                                        final String? mat = materialFromUi(v ?? allLabel); // your existing helper
                                        final fs = context.read<FiltersCubit>().state;
                                        SearchControl.run(
                                          ctx: context,
                                          start: fs.startDate ?? searchState.currentQuery.startDate ?? DateTime.now(),
                                          end: fs.endDate ?? searchState.currentQuery.endDate ?? DateTime.now(),
                                          furnaceInt: furnace,
                                          materialStr: mat,
                                        );
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
      firstDate: DateTime(2020),
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
    SearchControl.run(
      ctx: context,
      start: fs.startDate ?? picked,
      end: fs.endDate ?? picked,
      furnaceInt: furnace,
      materialStr: mat,
    );

    context.read<SearchBloc>().add(const LoadDropdownOptions());
  }
}
