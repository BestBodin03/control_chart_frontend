import 'package:control_chart/apis/settings/setting_apis.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/data/cubit/searching/utils/search_control.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/shared/form_component.dart';
import 'package:control_chart/ui/core/shared/gradient_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../data/cubit/searching/filters_cubit.dart';
import '../../../data/cubit/searching/options/options_cubit.dart';
import '../../../data/cubit/searching/utils/mapper.dart';
import '../../../utils/date_autocomplete.dart';
import '../../../utils/date_convertor.dart';
import '../../screen/screen_content/home_screen_content/home_content_var.dart';
import '../../screen/screen_content/searching_screen_content/searching_var.dart';

class SearchingForm extends StatelessWidget {
  const SearchingForm({
    super.key,
    this.initialProfile,
    this.loadFurnaces,
    this.loadMaterials,
    this.loadCpNames, 
    required this.settingApis, // << เพิ่ม loader cpNames (matNo -> cpName)
  });

  final HomeContentVar? initialProfile;
  final Future<List<String>> Function()? loadFurnaces;
  final Future<List<String>> Function()? loadMaterials;
  final Future<Map<String, String>> Function()? loadCpNames;
  final SettingApis settingApis;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => FiltersCubit()),
BlocProvider(
  create: (_) => OptionsCubit(settingApis: settingApis)
    ..loadDropdownOptions(index: 0),
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
    if (s.isEmpty || s == 'All Material Nos.') return null;
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
        return BlocBuilder<FiltersCubit, FilterState>(
          builder: (context, filters) {
            final dateNow = DateTime.now();
            final dateOneM = oneMonthAgo(dateNow);
            final sDate = filters.startDate ?? searchState.currentQuery.startDate ?? dateOneM;
            final eDate = filters.endDate ?? searchState.currentQuery.endDate ?? dateNow;

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
                                buildSectionTitle('Period'),
                                IconButton(
                                  tooltip: 'Refresh',
                                  padding: const EdgeInsets.all(8),
                                  constraints: const BoxConstraints(),
                                  splashRadius: 16,
                                  onPressed: () {
                                    context.read<FiltersCubit>().setPeriod('1 month', start: dateOneM, end: dateNow);
                                    context.read<SearchBloc>().add(LoadFilteredChartData(
                                      startDate: dateOneM,
                                      endDate: dateNow
                                    ));
                                    searchPeriodType = '1 month';
                                    // context.read<FiltersCubit>().setPeriod('1 month', start: oneMonthAgo(dateNow), end: dateNow);
                                  },
                                  icon: const Icon(Icons.refresh_rounded, size: 24, color: AppColors.colorBrand),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // Period dropdown (FiltersCubit only)
                            buildDropdownField(
                              context: context,
                              value: filters.periodValue ,
                              items: const ['1 month', '3 months', '6 months', '1 year', 'All time', 'Custom'],
                              onChanged: (value) {
                                if (value == null) return;

                                // ใช้ utils เดิม ไม่แก้ไข
                                final dateMap = DateAutoComplete.calculateDateRange(value);

                                final sDate = dateMap['startDate']?.date;
                                final eDate = dateMap['endDate']?.date;

                                context.read<FiltersCubit>().setPeriod(
                                  value,
                                  start: sDate,
                                  end: eDate,
                                );

                                searchPeriodType = value;

                                if (value != 'Custom') {
                                  final int? furnace = furnaceIntFromUi(searchState.currentFurnaceUiValue);
                                  final String? mat = materialFromUi(searchState.currentMaterialUiValue);

                                  context.read<SearchBloc>().add(LoadFilteredChartData(
                                    startDate: sDate,
                                    endDate: eDate,
                                    furnaceNo: furnace?.toString(),
                                    materialNo: mat,
                                  ));
                                  context.read<SearchBloc>().add(const LoadDropdownOptions());
                                }
                              }

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
                                    date: sDate,
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
                                const Text('To', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87)),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: buildDateField(
                                    context: context,
                                    value: eDate,
                                    label: _dateLabel(eDate) ?? 'Select Date',
                                    date: eDate,
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

                            buildSectionTitle('Furnace No.'),
                            const SizedBox(height: 8),
                            BlocBuilder<OptionsCubit, OptionsState>(
                              builder: (context, opts) {
                                const allFurnacesLabel = 'All Furnaces';

                                // Use the latest payload (or per-index: opts.furnaceOptionsByIndex[0] ?? [])
                                final raw = opts.lastFetchedFurnaces;
                                // debugPrint('🔵 [Furnace] Raw: $raw');

                                // Sort numerically, unique, and prepend "All"
                                final furnaces = raw
                                    .map((e) => e.toString())
                                    .where((e) => e.isNotEmpty && e != allFurnacesLabel)
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
                                furnaces.insert(0, allFurnacesLabel);
                                // debugPrint('🔵 [Furnace] Final: $furnaces');

                                // Safe current value
                                String? current = searchState.currentFurnaceUiValue.isEmpty
                                    ? allFurnacesLabel
                                    : searchState.currentFurnaceUiValue;
                                if (!furnaces.contains(current)) current = allFurnacesLabel;
                                // debugPrint('🔵 [Furnace] Current: $current');

                                return AbsorbPointer(
                                  absorbing: opts.dropdownLoading,
                                  child: Opacity(
                                    opacity: opts.dropdownLoading ? 0.6 : 1,
                                    child: buildDropdownField(
                                      key: ValueKey('furnace_$current'),
                                      context: context,
                                      hint: allFurnacesLabel,
                                      value: current == allFurnacesLabel ? null : current,
                                      items: furnaces,
                                      onChanged: (selected) {
                                        final val = (selected == null || selected == allFurnacesLabel) ? null : selected;

                                        final fs = context.read<FiltersCubit>().state;
                                        final now = DateTime.now();
                                        final fallbackStart = now.subtract(const Duration(days: 30));

                                        context.read<SearchBloc>().add(LoadFilteredChartData(
                                          startDate: fs.startDate ?? fallbackStart,
                                          endDate: fs.endDate ?? now,
                                          furnaceNo: val,
                                          // 👇 เอา current material จาก state (normalize ที่นี่ถ้าจำเป็น)
                                          materialNo: searchState.currentMaterialUiValue.isEmpty ||
                                                      searchState.currentMaterialUiValue == 'All Material Nos.'
                                              ? null
                                              : searchState.currentMaterialUiValue,
                                        ));

                                        // ✅ ยิง OptionsCubit ต่อ เพื่อ refresh material list ตาม furnace ใหม่
                                        context.read<OptionsCubit>().loadDropdownOptions(
                                          index: 0,
                                          furnaceNo: val,
                                        );
                                      }

                                    ),
                                  ),
                                );
                              },
                            ),


                            const SizedBox(height: 16),

                            buildSectionTitle('Material No.'), // or 'CP No.' if that’s your domain wording
                            const SizedBox(height: 8),
                            BlocBuilder<OptionsCubit, OptionsState>(
                              builder: (context, opts) {
                                const allLabel = 'All Material Nos.'; // rename to suit your UI
                                final raw = opts.lastFetchedCps;
                                final materials = raw
                                    .map((e) => e.toString())
                                    .where((e) => e.isNotEmpty && e != allLabel)
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
                                materials.insert(0, allLabel);
                                final items = List<String>.from(materials);
                                String? current = searchState.currentMaterialUiValue.isEmpty
                                    ? allLabel
                                    : searchState.currentMaterialUiValue;
                                if (current != null && current != allLabel && current.contains(' - ')) {
                                  current = current.split(' - ').first;
                                }
                                if (!materials.contains(current)) current = allLabel;
                                return AbsorbPointer(
                                  absorbing: opts.dropdownLoading,
                                  child: Opacity(
                                    opacity: opts.dropdownLoading ? 0.6 : 1,
                                    child: buildDropdownField(
                                      key: ValueKey('material_$current'),
                                      context: context,
                                      hint: allLabel,
                                      value: current == allLabel ? null : current,
                                      items: items,
                                      onChanged: (selected) {
                                        final val = (selected == null || selected == allLabel) ? null : selected.split(' - ').first;

                                        final fs = context.read<FiltersCubit>().state;
                                        final now = DateTime.now();
                                        final fallbackStart = now.subtract(const Duration(days: 30));

                                        context.read<SearchBloc>().add(
                                          LoadFilteredChartData(
                                            startDate: fs.startDate ?? fallbackStart,
                                            endDate: fs.endDate ?? now,
                                            furnaceNo: searchState.currentFurnaceUiValue.isEmpty 
                                                ? null 
                                                : searchState.currentFurnaceUiValue,
                                            materialNo: (val == null || val == allLabel) ? null : val,
                                          ),
                                        );
                                      }
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
