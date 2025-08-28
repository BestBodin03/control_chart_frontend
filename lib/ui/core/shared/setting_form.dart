import 'package:control_chart/apis/settings/setting_apis.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/data/bloc/setting/setting_bloc.dart';
import 'package:control_chart/data/cubit/setting_form/setting_form_cubit.dart';
import 'package:control_chart/data/cubit/setting_form/setting_form_state.dart';
import 'package:control_chart/domain/models/customer_product.dart';
import 'package:control_chart/domain/models/furnace.dart';
import 'package:control_chart/domain/models/setting.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';
import 'package:control_chart/ui/core/shared/form_component.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/setting_var.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class SettingForm extends StatefulWidget {
  const SettingForm({super.key});

  @override
  State<SettingForm> createState() => _SettingFormState();
}

class _SettingFormState extends State<SettingForm> {
  late final SettingBloc _settingBloc;
  static const _periodItems = ['1 เดือน', '3 เดือน', '6 เดือน', '1 ปี', 'ตลอดเวลา', 'กำหนดเอง'];
  String selectedDisplayType = '';
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
          // Notifications
          BlocListener<SettingBloc, SettingState>(
            listener: (context, state) {
              if (state.isSaved) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('บันทึกข้อมูลเรียบร้อยแล้ว'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
          // Bridge SettingBloc dates -> SearchBloc
          BlocListener<SettingBloc, SettingState>(
            listenWhen: (prev, curr) =>
                prev.formState.startDate != curr.formState.startDate ||
                prev.formState.endDate != curr.formState.endDate,
            listener: (context, state) {
              final start = _toDateTime(state.formState.startDate);
              final end = _toDateTime(state.formState.endDate);
              if (start == null || end == null) return;

              final search = context.read<SearchBloc>().state.currentQuery;
              context.read<SearchBloc>().add(
                    LoadFilteredChartData(
                      startDate: start,
                      endDate: end,
                      furnaceNo: search.furnaceNo,
                      materialNo: search.materialNo,
                    ),
                  );
            },
          ),
        ],
        child: BlocBuilder<SettingBloc, SettingState>(
          builder: (context, state) {
            if (state.status == SettingStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == SettingStatus.error) {
              return const Center(child: Text('Error: ${'เกิดข้อผิดผลาด'}'));
            }

            final form = state.formState;
            final furnaces = state.furnaces;
            final matNumbers = state.matNumbers;

            return SingleChildScrollView(
              child: SizedBox(
                width: 332,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.colorBgGrey,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // วาง BlocBuilder ครอบเฉพาะ section นี้ เพื่ออ่าน/อัปเดตค่าใน SettingFormCubit
                        BlocBuilder<SettingFormCubit, SettingFormState>(
                          builder: (context, s) {
                            final cubit = context.read<SettingFormCubit>();

                            // ค่าที่ถูกเลือกอยู่ตอนนี้ (ดึงจาก state.ruleSelected ที่ isUsed == true)
                            final selectedRuleNames = s.ruleSelected
                                .where((r) => r.isUsed == true)
                                .map((r) => (r.ruleName ?? '').trim())
                                .where((name) => name.isNotEmpty)
                                .toList();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // -------------------- ชื่อโปรไฟล์ตั้งค่า --------------------
                                buildSectionTitle('ชื่อโปรไฟล์ตั้งค่า'),
                                const SizedBox(height: 8),
                                buildTextField(
                                  value: s.settingProfileName, // ค่าใน state
                                  hintText: 'ชื่อ',
                                  onChanged: (v) => cubit.updateSettingProfileName(v),
                                ),
                                const SizedBox(height: 16),

                                // -------------------- การแสดงผล --------------------
                                buildSectionTitle('การแสดงผล'),
                                const SizedBox(height: 8),
                                buildChoiceTabs(
                                  selectedValue: selectedDisplayType, // local UI ของคุณ
                                  itemsLabel: const ['เตา', 'เตา/เลขแมต', 'เลขแมต'],
                                  itemsValue: const ['FURNACE', 'FURNACE_CP', 'CP'],
                                  onChanged: (v) {
                                    setState(() => selectedDisplayType = v);
                                    // อัปเดตลง cubit ด้วย (ผูกกับ enum DisplayTypeReq)
                                    cubit.updateDisplayType(
                                      v == 'FURNACE'
                                          ? DisplayType.FURNACE
                                          : v == 'FURNACE_CP'
                                              ? DisplayType.FURNACE_CP
                                              : DisplayType.CP,
                                    );
                                    // สร้างบล็อกเริ่มต้นถ้ายังไม่มี
                                    if (cubit.state.specifics.isEmpty) {
                                      cubit.addSpecificSetting();
                                    }
                                  },
                                ),
                                const SizedBox(height: 16),

                                // -------------------- กฎแผนภูมิควบคุม --------------------
                                buildSectionTitle('กฎแผนภูมิควบคุม'),
                                const SizedBox(height: 8),
                                buildMultiSelectField(
                                  context: context,
                                  hintText: 'เลือกกฎ',
                                  items: ruleItems,
                                  selectedValues: selectedRuleNames,
                                  onChanged: (List<String> values) {
                                    // แปลงชื่อกฎ → RuleSelected (inline)
                                    final rules = values.map((name) {
                                      final id = ruleIdByName[name];
                                      return RuleSelected(
                                        ruleId: id, // อาจเป็น null ได้ถ้า map ไม่เจอ (โอเค)
                                        ruleName: name,
                                        isUsed: true,
                                      );
                                    }).toList();
                                    cubit.updateRuleSelected(rules);
                                  },
                                ),
                                const SizedBox(height: 16),

                                // -------------------- ระยะเวลาเปลี่ยนหน้าจอ --------------------
                                buildSectionTitle('ระยะเวลาเปลี่ยนหน้าจอ'),
                                const SizedBox(height: 8),
                                buildTextField(
                                  value: s.chartChangeInterval > 0 ? s.chartChangeInterval.toString() : '',
                                  hintText: 'ระยะเวลา (วินาที)',
                                  // ถ้า buildTextField รองรับ numeric keyboard ให้ตั้งเพิ่มได้ เช่น keyboardType: TextInputType.number
                                  onChanged: (v) {
                                    final parsed = int.tryParse(v.trim()) ?? 0;
                                    cubit.updateChartChangeInterval(parsed);
                                  },
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        Visibility(
                          visible: selectedDisplayType.isNotEmpty,
                          maintainState: true,
                          maintainAnimation: true,
                          maintainSize: false,
                          child: BlocBuilder<SettingFormCubit, SettingFormState>(
                            builder: (context, state) {
                              final cubit = context.read<SettingFormCubit>();
                              return Column(
                                children: List.generate(state.specifics.length, (i) {
                                  final sp = state.specifics[i];

                                  // แปลง enum -> label (inline)
                                  final currentPeriodLabel = () {
                                    switch (sp.periodType) {
                                      case PeriodType.ONE_MONTH:
                                        return '1 เดือน';
                                      case PeriodType.THREE_MONTHS:
                                        return '3 เดือน';
                                      case PeriodType.SIX_MONTHS:
                                        return '6 เดือน';
                                      case PeriodType.ONE_YEAR:
                                        return '1 ปี';
                                      case PeriodType.LIFETIME:
                                        return 'ตลอดเวลา';
                                      case PeriodType.CUSTOM:
                                        return 'กำหนดเอง';
                                      default:
                                        return form.periodValue; // fallback เดิมถ้ามี
                                    }
                                  }();

                                  return DecoratedBox(
                                    decoration: BoxDecoration(
                                      border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1)),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Header + Add/Remove
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              buildSectionTitle('ระยะเวลา'),
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(Icons.add_circle_rounded, color: AppColors.colorBrand),
                                                    iconSize: 24,
                                                    onPressed: () => cubit.addSpecificSetting(),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  IconButton(
                                                    icon: const Icon(Icons.remove_circle_outline_rounded, color: AppColors.colorAlert1),
                                                    iconSize: 24,
                                                    onPressed: state.specifics.isEmpty ? null : () => cubit.removeSpecificSetting(i),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),

                                          // Period dropdown (ใช้ cubit + sp)
                                          buildDropdownField(
                                            context: context,
                                            value: currentPeriodLabel,
                                            items: _periodItems,
                                            onChanged: (value) {
                                              if (value == null) return;

                                              // map label -> enum (inline)
                                              final now = DateTime.now();
                                              DateTime? startAuto;
                                              PeriodType? p;
                                              switch (value) {
                                                case '1 เดือน':
                                                  p = PeriodType.ONE_MONTH;
                                                  startAuto = DateTime(now.year, now.month - 1, now.day);
                                                  break;
                                                case '3 เดือน':
                                                  p = PeriodType.THREE_MONTHS;
                                                  startAuto = DateTime(now.year, now.month - 3, now.day);
                                                  break;
                                                case '6 เดือน':
                                                  p = PeriodType.SIX_MONTHS;
                                                  startAuto = DateTime(now.year, now.month - 6, now.day);
                                                  break;
                                                case '1 ปี':
                                                  p = PeriodType.ONE_YEAR;
                                                  startAuto = DateTime(now.year - 1, now.month, now.day);
                                                  break;
                                                case 'ตลอดเวลา':
                                                  p = PeriodType.LIFETIME;
                                                  startAuto = DateTime(2020, 1, 1);
                                                  break;
                                                default:
                                                  p = PeriodType.CUSTOM;
                                                  startAuto = null; // กำหนดเอง ไม่ auto set
                                              }

                                              cubit.updatePeriodType(i, p);
                                              if (p != PeriodTypeReq.CUSTOM) {
                                                cubit
                                                  ..updateStartDate(i, startAuto!)
                                                  ..updateEndDate(i, now);
                                              }
                                            },
                                          ),

                                          const SizedBox(height: 16),

                                          // Start / End Date (ใช้ค่าใน sp)
                                          Row(
                                            children: [
                                              Expanded(
                                                child: buildDateField(
                                                  context: context,
                                                  value: sp.startDate,
                                                  label: _dateLabel(sp.startDate) ?? 'เลือก',
                                                  date: sp.startDate ?? DateTime.now(),
                                                  onTap: () => _selectDate(context, true),
                                                  onChanged: (date) {
                                                    if (date == null) return;
                                                    cubit
                                                      ..updatePeriodType(i, PeriodType.CUSTOM) // ผู้ใช้เลือกเอง -> กำหนดเอง
                                                      ..updateStartDate(i, date);
                                                  },
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              const Text(
                                                'ถึง',
                                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: buildDateField(
                                                  context: context,
                                                  value: sp.endDate,
                                                  label: _dateLabel(sp.endDate) ?? 'Select Date',
                                                  date: sp.endDate ?? DateTime.now(),
                                                  onTap: () => _selectDate(context, false),
                                                  onChanged: (date) {
                                                    if (date == null) return;
                                                    cubit
                                                      ..updatePeriodType(i, PeriodType.CUSTOM)
                                                      ..updateEndDate(i, date);
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 16),

                                          // Furnace (ตาม display type)
                                          if (selectedDisplayType == 'FURNACE' || selectedDisplayType == 'FURNACE_CP') ...[
                                            buildSectionTitle('หมายเลขเตา'),
                                            const SizedBox(height: 8),
                                            buildDropdownField(
                                              context: context,
                                              value: sp.furnaceNo?.toString() ?? "0",
                                              items: _getFurnaceNumbers(furnaces),
                                              hint: "เลือกเตา",
                                              onChanged: (selected) {
                                                final val = (selected == "0" ? null : int.tryParse(selected ?? ""));
                                                if (val != null) cubit.updateFurnaceNo(i, val);
                                              },
                                            ),
                                            const SizedBox(height: 16),
                                          ],

                                          // Material (ตาม display type)
                                          if (selectedDisplayType == 'CP' || selectedDisplayType == 'FURNACE_CP') ...[
                                            buildSectionTitle('หมายเลขแมต'),
                                            const SizedBox(height: 8),
                                            buildDropdownField(
                                              context: context,
                                              value: sp.cpNo ?? "เลือกเลขแมต",
                                              items: _getMatNumbers(matNumbers),
                                              hint: "เลือกเลขแมต",
                                              onChanged: (selected) {
                                                final val = selected == "เลือกเลขแมต" ? "" : (selected ?? "");
                                                cubit.updateCpNo(i, val);
                                              },
                                            ),
                                            const SizedBox(height: 48),
                                          ],
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              );
                            },
                          ),
                        ),

                        SizedBox(
                          width: double.infinity,
                          height: 42,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.colorBrand,
                              foregroundColor: AppColors.colorBg,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                            onPressed: () => {
                              context.read<SettingFormCubit>().saveForm(),
                              
                              Navigator.pop(context)
                              },
                            child: const Text('บันทึก', style: AppTypography.textBody2WBold),
                          ),
                        )

                      ],
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

  static DateTime? _toDateTime(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v);
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
    final endDT = end is DateTime ? end : _toDateTime(end);
    if (startDT == null || endDT == null) return;

    final q = context.read<SearchBloc>().state.currentQuery;
    context.read<SearchBloc>().add(
          LoadFilteredChartData(
            startDate: startDT,
            endDate: endDT,
            furnaceNo: furnace ?? q.furnaceNo,
            materialNo: material ?? q.materialNo,
          ),
        );
  }

  void _updateDateRangeByPeriod(BuildContext context, String period) {
    final now = DateTime.now();
    DateTime startDate;
    switch (period) {
      case '1 เดือน':
        startDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case '3 เดือน':
        startDate = DateTime(now.year, now.month - 3, now.day);
        break;
      case '6 เดือน':
        startDate = DateTime(now.year, now.month - 6, now.day);
        break;
      case '1 ปี':
        startDate = DateTime(now.year - 1, now.month, now.day);
        break;
      case 'ตลอดเวลา':
        startDate = DateTime(2020, 1, 1);
        break;
      default:
        return;
    }
    context.read<SettingBloc>()
      ..add(UpdateStartDate(startDate: startDate))
      ..add(UpdateEndDate(endDate: now));
  }

  List<String> _getFurnaceNumbers(List<Furnace> furnaces) {
    final sorted = (furnaces.map((f) => f.furnaceNo).toList()..sort());
    return ["0", ...sorted.map((n) => n.toString())];
  }

  List<String> _getMatNumbers(List<CustomerProduct> mats) {
    final sorted = (mats.map((m) => m.cpNo).toList()..sort());
    return ["เลือกเลขแมต", ...sorted.map((n) => n.toString())];
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final settingState = _settingBloc.state;
    final searchState = context.read<SearchBloc>().state;

    final initial = isStartDate
        ? (searchState.currentQuery.startDate ??
            _toDateTime(settingState.formState.startDate) ??
            DateTime.now())
        : (searchState.currentQuery.endDate ??
            _toDateTime(settingState.formState.endDate) ??
            DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2050),
    );

    if (picked == null) return;

    final q = searchState.currentQuery;
    final newStart = isStartDate ? picked : (q.startDate ?? picked);
    final newEnd = isStartDate ? (q.endDate ?? picked) : picked;

    context.read<SettingBloc>().add(UpdatePeriodS('กำหนดเอง'));
    context.read<SettingBloc>()
      ..add(UpdateStartDate(startDate: newStart))
      ..add(UpdateEndDate(endDate: newEnd));

    context.read<SearchBloc>().add(
          LoadFilteredChartData(
            startDate: newStart,
            endDate: newEnd,
            furnaceNo: q.furnaceNo,
            materialNo: q.materialNo,
          ),
        );
  }
}
