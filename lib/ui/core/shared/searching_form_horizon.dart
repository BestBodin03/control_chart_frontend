import 'package:control_chart/apis/settings/setting_apis.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/data/cubit/searching/utils/search_control.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/shared/form_component.dart';
import 'package:control_chart/ui/core/shared/gradient_background.dart';
import 'package:control_chart/ui/screen/screen_content/searching_screen_content/searching_var.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../data/cubit/searching/filters_cubit.dart';
import '../../../data/cubit/searching/options/options_cubit.dart';
import '../../../data/cubit/searching/utils/mapper.dart';
import '../../../utils/date_autocomplete.dart';
import '../../../utils/date_convertor.dart';
import '../../screen/screen_content/home_screen_content/home_content_var.dart';

class SearchingFormHorizon extends StatelessWidget {
  const SearchingFormHorizon({
    super.key,
    this.initialProfile,
    this.loadFurnaces,
    this.loadMaterials,
    this.loadCpNames,
    required this.settingApis,
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
    final uiFurnace = searchState.currentFurnaceUiValue;
    final uiMaterial = searchState.currentMaterialUiValue;

    final int? profileFurnace = _coerceInt(p.furnaceNo);
    final String? profileMat = _coerceMat(p.materialNo);

    final int? furnace = profileFurnace ?? furnaceIntFromUi(uiFurnace);
    final String? mat = profileMat ?? materialFromUi(uiMaterial);

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
            final now = DateTime.now();
            final oneM = oneMonthAgo(now);
            final sDate = filters.startDate ?? searchState.currentQuery.startDate ?? oneM;
            final eDate = filters.endDate ?? searchState.currentQuery.endDate ?? now;

            debugPrint('in horizon the value of priod type: ${filters.periodValue}');
            return GradientBackground(
              opacity: 0.15,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.colorBg,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.colorBrandTp.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 🔄 Refresh button
                      Flexible(
                        flex: 1,
                        child: IconButton(
                          tooltip: 'Refresh',
                          padding: const EdgeInsets.all(8),
                          splashRadius: 18,
                          onPressed: () {
                            context.read<FiltersCubit>().setPeriod('1 month', start: oneM, end: now);
                            context.read<SearchBloc>().add(
                                  LoadFilteredChartData(startDate: oneM, endDate: now),
                                );
                          },
                          icon: const Icon(Icons.refresh_rounded, size: 20, color: AppColors.colorBrand),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // 🗓 Period dropdown
                      Flexible(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Period', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            buildDropdownField(
                              context: context,
                              value: searchPeriodType,
                              items: const ['1 month', '3 months', '6 months', '1 year', 'All time', 'Custom'],
                              onChanged: (value) {
                                if (value == null) return;
                                final map = DateAutoComplete.calculateDateRange(value);
                                final s = map['startDate']?.date;
                                final e = map['endDate']?.date;
                                context.read<FiltersCubit>().setPeriod(value, start: s, end: e);
                                if (value != 'Custom') {
                                  final fNo = furnaceIntFromUi(searchState.currentFurnaceUiValue);
                                  final mNo = materialFromUi(searchState.currentMaterialUiValue);
                                  context.read<SearchBloc>().add(LoadFilteredChartData(
                                        startDate: s,
                                        endDate: e,
                                        furnaceNo: fNo?.toString(),
                                        materialNo: mNo,
                                      ));
                                  context.read<SearchBloc>().add(const LoadDropdownOptions());
                                }
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // 📅 Start date
                      Flexible(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Start Date', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            buildDateField(
                              context: context,
                              value: sDate,
                              label: _dateLabel(sDate) ?? 'Start',
                              date: sDate,
                              onTap: () => _pickDate(context, isStart: true),
                              onChanged: (d) {
                                if (d == null) return;
                                context.read<FiltersCubit>().setStartDate(d);
                              },
                            ),
                          ],
                        ),
                      ),

                      // const SizedBox(width: 8),
                      // const Padding(
                      //   padding: EdgeInsets.only(top: 16),
                      //   child: Text('→', style: TextStyle(fontWeight: FontWeight.bold)),
                      // ),
                      const SizedBox(width: 8),

                      // 📅 End date
                      Flexible(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('End Date', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            buildDateField(
                              context: context,
                              value: eDate,
                              label: _dateLabel(eDate) ?? 'End',
                              date: eDate,
                              onTap: () => _pickDate(context, isStart: false),
                              onChanged: (d) {
                                if (d == null) return;
                                context.read<FiltersCubit>().setEndDate(d);
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // 🏭 Furnace dropdown
                      Flexible(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Furnace', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            BlocBuilder<OptionsCubit, OptionsState>(
                              builder: (context, opts) {
                                final allLabel = 'All Furnaces';
                                final furnaces = [
                                  allLabel,
                                  ...(
                                    opts.lastFetchedFurnaces
                                        .map((e) => e.toString())
                                        .where((s) => s.isNotEmpty && s != allLabel)
                                        .map((s) => num.tryParse(s)) // parse to number
                                        .whereType<num>()            // drop non-numeric
                                        .toSet()                     // unique
                                        .toList()
                                          ..sort()                   // numeric sort
                                  ).map((n) => n.toString()),        // back to string
                                ];


                                String? current = searchState.currentFurnaceUiValue.isEmpty
                                    ? allLabel
                                    : searchState.currentFurnaceUiValue;
                                if (!furnaces.contains(current)) current = allLabel;

                                return buildDropdownField(
                                  key: ValueKey('furnace_$current'),
                                  context: context,
                                  hint: allLabel,
                                  value: current == allLabel ? null : current,
                                  items: furnaces,
                                  onChanged: (v) {
                                    final val = v == allLabel ? null : v;
                                    context.read<SearchBloc>().add(LoadFilteredChartData(
                                          startDate: sDate,
                                          endDate: eDate,
                                          furnaceNo: val,
                                          materialNo: searchState.currentMaterialUiValue,
                                        ));
                                    context.read<OptionsCubit>().loadDropdownOptions(index: 0, furnaceNo: val);
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // 🧱 Material dropdown
                      Flexible(
                        flex:4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Material No.', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            BlocBuilder<OptionsCubit, OptionsState>(
                              builder: (context, opts) {
                                final allLabel = 'All Material Nos.';
                                final materials = [
                                  allLabel,
                                  ...opts.lastFetchedCps.map((e) => e.toString()).where((e) => e.isNotEmpty).toSet().toList()..sort(),
                                ];

                                String? current = searchState.currentMaterialUiValue.isEmpty
                                    ? allLabel
                                    : searchState.currentMaterialUiValue;
                                if (!materials.contains(current)) current = allLabel;

                                return buildDropdownField(
                                  key: ValueKey('material_$current'),
                                  context: context,
                                  hint: allLabel,
                                  value: current == allLabel ? null : current,
                                  items: materials,
                                  onChanged: (v) {
                                    final val = v == allLabel ? null : v;
                                    context.read<SearchBloc>().add(LoadFilteredChartData(
                                          startDate: sDate,
                                          endDate: eDate,
                                          furnaceNo: searchState.currentFurnaceUiValue,
                                          materialNo: val,
                                        ));
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
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