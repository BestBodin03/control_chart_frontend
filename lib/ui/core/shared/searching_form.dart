import 'package:control_chart/apis/settings/setting_apis.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/data/bloc/setting/setting_bloc.dart';
import 'package:control_chart/domain/models/customer_product.dart';
import 'package:control_chart/domain/models/furnace.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/shared/form_component.dart';
import 'package:control_chart/ui/core/shared/gradient_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class SearchingForm extends StatefulWidget {
  const SearchingForm({super.key});

  @override
  State<SearchingForm> createState() => _SearchingFormState();
}

class _SearchingFormState extends State<SearchingForm> {
  late final SettingBloc _settingBloc;
  static const _periodItems = ['1 เดือน', '3 เดือน', '6 เดือน', '1 ปี', 'ตลอดเวลา', 'กำหนดเอง'];
  final double backgroundOpacity = 0.2;

  @override
  void initState() {
    super.initState();
    _settingBloc = SettingBloc(settingApis: SettingApis())..add(InitializeForm());
  }

  @override
  void dispose() {
    _settingBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _settingBloc,
      child: MultiBlocListener(
        listeners: [

          BlocListener<SettingBloc, SettingState>(
            listenWhen: (prev, curr) =>
                prev.formState.startDate != curr.formState.startDate ||
                prev.formState.endDate != curr.formState.endDate,
            listener: (context, state) {
              final start = _toDateTime(state.formState.startDate);
              final end   = _toDateTime(state.formState.endDate);
              if (start == null || end == null) return;

              final search = context.read<SearchBloc>().state.currentQuery;
              context.read<SearchBloc>().add(LoadFilteredChartData(
                startDate: start,
                endDate: end,
                furnaceNo: search.furnaceNo,
                materialNo: search.materialNo,
              ));
            },
          ),
        ],
        child: BlocBuilder<SettingBloc, SettingState>(
          builder: (context, state) {
            if (state.status == SettingStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == SettingStatus.error) {
              return Center(child: Text('Error: ${'เกิดข้อผิดผลาด'}'));
            }

            final form = state.formState;
            final furnaces = state.furnaces;
            final matNumbers = state.matNumbers;

            return GradientBackground(
              opacity: backgroundOpacity,
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flex(
                            direction: Axis.horizontal,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              buildSectionTitle('ระยะเวลา'),
                              BlocSelector<SettingBloc, SettingState, SettingStatus>(
                                selector: (s) => s.status,
                                builder: (context, status) {
                                  final isBusy = status == SettingStatus.loading;
                                  return IconButton(
                                    tooltip: isBusy ? 'กำลังรีเฟรช…' : 'รีเฟรช',
                                    padding: EdgeInsets.all(8),
                                    constraints: const BoxConstraints(),
                                    splashRadius: 16,
                                    onPressed: isBusy
                                        ? null
                                        : () {
                                            context.read<SearchBloc>().add(ClearFilters());
                                            context.read<SettingBloc>().add(UpdatePeriodS('1 เดือน'));
                                            // หรือ: context.read<SettingBloc>().add(InitializeForm());
                                          },
                                    icon: isBusy
                                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                        : const Icon(Icons.refresh_rounded, size: 24, color: AppColors.colorBrand),
                                  );
                                },
                              ),
                            ],
                          ),


                          const SizedBox(height: 8),

                          buildDropdownField(
                            context: context,
                            value: form.periodValue,
                            items: _periodItems,
                            onChanged: (value) {
                              if (value == null) return;
                              context.read<SettingBloc>().add(UpdatePeriodS(value));
                              _updateDateRangeByPeriod(context, value); // เดิม
                            },
                          ),

                          const SizedBox(height: 16),

                          Row(
                            children: [
                              // Start Date
                              BlocBuilder<SearchBloc, SearchState>(
                                builder: (context, searchState) {
                                  final sDate = searchState.currentQuery.startDate ?? _toDateTime(form.startDate);
                                  return Expanded(
                                    child: buildDateField(
                                      context: context,
                                      value: sDate,
                                      label: _dateLabel(sDate) ?? 'Select Date',
                                      date: sDate ?? DateTime.now(),
                                      onTap: () => _selectDate(context, true),
                                      onChanged: (date) {
                                        if (date == null) return;
                                        context.read<SettingBloc>().add(UpdateStartDate(startDate: date));
                                        _dispatchSearchWith(context, start: date, end: form.endDate ?? searchState.currentQuery.endDate);
                                      },
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 16),
                              const Text('ถึง', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87)),
                              const SizedBox(width: 16),

                              // End Date
                              BlocBuilder<SearchBloc, SearchState>(
                                builder: (context, searchState) {
                                  final eDate = searchState.currentQuery.endDate ?? _toDateTime(form.endDate);
                                  return Expanded(
                                    child: buildDateField(
                                      context: context,
                                      value: eDate,
                                      label: _dateLabel(eDate) ?? 'Select Date',
                                      date: eDate ?? DateTime.now(),
                                      onTap: () => _selectDate(context, false),
                                      onChanged: (date) {
                                        if (date == null) return;
                                        context.read<SettingBloc>().add(UpdateEndDate(endDate: date));
                                        _dispatchSearchWith(context, start: form.startDate ?? searchState.currentQuery.startDate, end: date);
                                      },
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Furnace
                          buildSectionTitle('หมายเลขเตา'),
                          const SizedBox(height: 8),
                          BlocBuilder<SearchBloc, SearchState>(
                            builder: (context, searchState) {
                              return buildDropdownField(
                                context: context,
                                value: searchState.currentQuery.furnaceNo ?? form.selectedItem,
                                items: _getFurnaceNumbers(furnaces),
                                hint: "All Furnaces",
                                onChanged: (selected) {
                                  final val = selected == "0" ? "" : selected;
                                  _dispatchSearchWith(
                                    context,
                                    start: form.startDate ?? searchState.currentQuery.startDate,
                                    end:   form.endDate   ?? searchState.currentQuery.endDate,
                                    furnace: val,
                                    material: searchState.currentQuery.materialNo,
                                  );
                                },
                              );
                            },
                          ),

                          const SizedBox(height: 16),

                          // Material
                          buildSectionTitle('Material No.'),
                          const SizedBox(height: 8),
                          BlocBuilder<SearchBloc, SearchState>(
                            builder: (context, searchState) {
                              return buildDropdownField(
                                context: context,
                                value: searchState.currentQuery.materialNo,
                                items: _getMatNumbers(matNumbers),
                                hint: "All Material No.",
                                onChanged: (selected) {
                                  final val = selected == "All Material No." ? "" : selected;
                                  _dispatchSearchWith(
                                    context,
                                    start: form.startDate ?? searchState.currentQuery.startDate,
                                    end:   form.endDate   ?? searchState.currentQuery.endDate,
                                    furnace: searchState.currentQuery.furnaceNo,
                                    material: val,
                                  );
                                },
                              );
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ============== Helpers ==============

  // แปลง dynamic -> DateTime?
  static DateTime? _toDateTime(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String)  return DateTime.tryParse(v);
    return null;
  }

  static String? _dateLabel(DateTime? d) => d == null ? null : DateFormat('MM/dd/yy').format(d);

  void _dispatchSearchWith(
    BuildContext context, {
    required dynamic start,
    required dynamic end,
    String? furnace,
    String? material,
  }) {
    final startDT = start is DateTime ? start : _toDateTime(start);
    final endDT   = end   is DateTime ? end   : _toDateTime(end);
    if (startDT == null || endDT == null) return;

    final q = context.read<SearchBloc>().state.currentQuery;
    context.read<SearchBloc>().add(LoadFilteredChartData(
      startDate: startDT,
      endDate: endDT,
      furnaceNo: furnace ?? q.furnaceNo,
      materialNo: material ?? q.materialNo,
    ));
  }

  // Update by period (เดิม)
  void _updateDateRangeByPeriod(BuildContext context, String period) {
    final now = DateTime.now();
    DateTime startDate;
    switch (period) {
      case '1 เดือน':   startDate = DateTime(now.year, now.month - 1, now.day); break;
      case '3 เดือน':   startDate = DateTime(now.year, now.month - 3, now.day); break;
      case '6 เดือน':   startDate = DateTime(now.year, now.month - 6, now.day); break;
      case '1 ปี':      startDate = DateTime(now.year - 1, now.month, now.day); break;
      case 'ตลอดเวลา':  startDate = DateTime(2020, 1, 1); break;
      default: // 'กำหนดเอง'
        return; // ไม่ auto-update
    }
    context.read<SettingBloc>()
      ..add(UpdateStartDate(startDate: startDate))
      ..add(UpdateEndDate(endDate: now));
    // SearchBloc จะถูกอัปเดตผ่าน BlocListener อยู่แล้ว
  }

  List<String> _getFurnaceNumbers(List<Furnace> furnaces) {
    final sorted = (furnaces.map((f) => f.furnaceNo).toList()..sort());
    return ["0", ...sorted.map((n) => n.toString())];
  }

  List<String> _getMatNumbers(List<CustomerProduct> mats) {
    final sorted = (mats.map((m) => m.cpNo).toList()..sort());
    return ["All Material No.", ...sorted.map((n) => n.toString())];
  }


  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final settingState = _settingBloc.state;
    final searchState = context.read<SearchBloc>().state;

    final initial = isStartDate
        ? (searchState.currentQuery.startDate ?? _toDateTime(settingState.formState.startDate) ?? DateTime.now())
        : (searchState.currentQuery.endDate   ?? _toDateTime(settingState.formState.endDate)   ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2050),
    );

    if (picked == null) return;

    // Rule 1: เมื่อผู้ใช้เลือกวันเอง -> บังคับ period = "กำหนดเอง" + อัปเดตทั้งสอง Bloc
    final q = searchState.currentQuery;
    final newStart = isStartDate ? picked : (q.startDate ?? picked);
    final newEnd   = isStartDate ? (q.endDate ?? picked) : picked;

    if(!context.mounted) return;

    context.read<SettingBloc>().add(UpdatePeriodS('กำหนดเอง'));
    context.read<SettingBloc>()
      ..add(UpdateStartDate(startDate: newStart))
      ..add(UpdateEndDate(endDate: newEnd));

    context.read<SearchBloc>().add(LoadFilteredChartData(
      startDate: newStart,
      endDate: newEnd,
      furnaceNo: q.furnaceNo,
      materialNo: q.materialNo,
    ));
  }
}
