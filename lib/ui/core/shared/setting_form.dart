import 'package:control_chart/apis/settings/setting_apis.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/data/bloc/setting/setting_bloc.dart';
import 'package:control_chart/data/bloc/setting_profile/setting_profile_bloc.dart';
import 'package:control_chart/data/cubit/setting_cubit.dart';
import 'package:control_chart/data/cubit/setting_cubit_state.dart';
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
  late final SettingFormCubit _settingCubit;
  static const _periodItems = ['1 เดือน', '3 เดือน', '6 เดือน', '1 ปี', 'ตลอดเวลา', 'กำหนดเอง'];
  String selectedDisplayType = '';
  final double backgroundOpacity = 0.2;

  @override
  void initState() {
    super.initState();
    _settingBloc = SettingBloc(settingApis: SettingApis())..add(InitializeForm());

    // โหลดตัวเลือกทั้งหมดตั้งต้น (ไม่ส่งพารามิเตอร์)
    // ต้องแน่ใจว่ามี SettingFormCubit อยู่บน context แล้ว
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<SettingFormCubit>().loadDropdownOptions();
      }
    });
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
          BlocListener<SettingFormCubit, SettingFormState>(
            listenWhen: (prev, curr) {
              // ฟังเมื่อมีการเปลี่ยน start/end date ใน specifics ใด ๆ
              if (prev.specifics.length != curr.specifics.length) return true;
              for (var i = 0; i < curr.specifics.length; i++) {
                final p = prev.specifics[i];
                final c = curr.specifics[i];
                if (p.startDate != c.startDate || p.endDate != c.endDate) return true;
              }
              return false;
            },
            listener: (context, state) {
              // เลือก block ตัวแรกเป็นตัวอ้างอิง (ถ้าคุณมี active index ให้ใช้ตัวนั้นแทน)
              if (state.specifics.isEmpty) return;
              final sp = state.specifics.first;
              if (sp.startDate == null || sp.endDate == null) return;

              final search = context.read<SearchBloc>().state.currentQuery;
              context.read<SearchBloc>().add(
                LoadFilteredChartData(
                  startDate: sp.startDate!,
                  endDate: sp.endDate!,
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

                            if (selectedDisplayType.isEmpty) {
                              switch (s.displayType) {
                                case DisplayType.FURNACE:
                                  selectedDisplayType = 'FURNACE';
                                  break;
                                case DisplayType.FURNACE_CP:
                                  selectedDisplayType = 'FURNACE_CP';
                                  break;
                                case DisplayType.CP:
                                  selectedDisplayType = 'CP';
                                  break;
                              }
                            }

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
                                  selectedValue: selectedDisplayType,
                                  itemsLabel: const ['เตา', 'เตา/เลขแมต', 'เลขแมต'],
                                  itemsValue: const ['FURNACE', 'FURNACE_CP', 'CP'],
                                  onChanged: (v) {
                                    setState(() => selectedDisplayType = v);
                                    cubit.updateDisplayType(
                                      v == 'FURNACE'
                                          ? DisplayType.FURNACE
                                          : v == 'FURNACE_CP'
                                              ? DisplayType.FURNACE_CP
                                              : DisplayType.CP,
                                    );
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

                                          // ===== ใน BlocBuilder<SettingFormCubit, SettingFormState> ด้านใน loop ของ specifics (มี index i) =====

                                          buildDropdownField(
                                            context: context,
                                            value: _periodTypeToLabel(sp.periodType),      // ✅ bind กับ Cubit state
                                            items: const ['1 เดือน','3 เดือน','6 เดือน','1 ปี','ตลอดเวลา','กำหนดเอง'],
                                            onChanged: (value) {
                                              if (value == null) return;

                                              final now = DateTime.now();
                                              DateTime? startAuto;
                                              PeriodType period;

                                              switch (value) {
                                                case '1 เดือน':
                                                  period = PeriodType.ONE_MONTH;
                                                  startAuto = DateTime(now.year, now.month - 1, now.day);
                                                  break;
                                                case '3 เดือน':
                                                  period = PeriodType.THREE_MONTHS;
                                                  startAuto = DateTime(now.year, now.month - 3, now.day);
                                                  break;
                                                case '6 เดือน':
                                                  period = PeriodType.SIX_MONTHS;
                                                  startAuto = DateTime(now.year, now.month - 6, now.day);
                                                  break;
                                                case '1 ปี':
                                                  period = PeriodType.ONE_YEAR;
                                                  startAuto = DateTime(now.year - 1, now.month, now.day);
                                                  break;
                                                case 'ตลอดเวลา':
                                                  period = PeriodType.LIFETIME;
                                                  startAuto = DateTime(2024, 1, 1);
                                                  break;
                                                default: // 'กำหนดเอง'
                                                  period = PeriodType.CUSTOM;
                                                  startAuto = null;
                                              }

                                              // ✅ อัปเดต periodType ก่อน
                                              cubit.updatePeriodType(i, period);

                                              // ✅ ถ้าไม่ใช่ CUSTOM ให้เซตช่วงวันที่อัตโนมัติ
                                              if (period != PeriodType.CUSTOM) {
                                                cubit
                                                  ..updateStartDate(i, startAuto!)
                                                  ..updateEndDate(i, now);
                                              }

                                              // (ถ้าต้องการ trigger search ทันที)
                                              // if (sp.startDate != null && sp.endDate != null) {
                                              //   _dispatchSearchWith(context, start: startAuto ?? sp.startDate, end: now);
                                              // }
                                            },
                                          ),



                                          const SizedBox(height: 16),

                                          // Start / End Date (ใช้ค่าใน sp)
                                          Row(
                                            children: [
                                              // START DATE
                                              Expanded(
                                                child: buildDateField(
                                                  context: context,
                                                  value: sp.startDate,
                                                  label: _dateLabel(sp.startDate) ?? 'Select Date',
                                                  date: sp.startDate ?? DateTime.now(),

                                                  // ✅ ทำทุกอย่างใน onTap (async)
                                                  onTap: () async {
                                                    final picked = await showDatePicker(
                                                      context: context,
                                                      initialDate: sp.startDate ?? DateTime.now(),
                                                      firstDate: DateTime(2020),
                                                      lastDate: DateTime(2050),
                                                    );
                                                    if (picked == null) return;

                                                    final cubit = context.read<SettingFormCubit>();
                                                    cubit
                                                      .updateStartDate(i, picked, setCustom: true);
                                                      // ..updatePeriodType(i, PeriodType.CUSTOM);

                                                    _dispatchSearchWith(
                                                      context,
                                                      start: picked,
                                                      end: sp.endDate ?? DateTime.now(),
                                                    );
                                                  },
                                                ),
                                              ),

                                              const SizedBox(width: 16),
                                              const Text(
                                                'ถึง',
                                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
                                              ),
                                              const SizedBox(width: 16),
                              
                                              // END DATE
                                              Expanded(
                                                child: buildDateField(
                                                  context: context,
                                                  value: sp.endDate,
                                                  label: _dateLabel(sp.endDate) ?? 'Select Date',
                                                  date: sp.endDate ?? DateTime.now(),
                                                  onTap: () async {
                                                    final picked = await showDatePicker(
                                                      context: context,
                                                      initialDate: sp.endDate ?? DateTime.now(),
                                                      firstDate: DateTime(2020),
                                                      lastDate: DateTime(2050),
                                                    );
                                                    if (picked == null) return;

                                                    final cubit = context.read<SettingFormCubit>();
                                                    
                                                    cubit
                                                      ..updateEndDate(i, picked, setCustom: true)
                                                      ..updatePeriodType(i, PeriodType.CUSTOM);

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
                                              items: _getFurnaceNumbers(state.furnaceOptions),
                                              hint: "All Furnaces",
                                              onChanged: (selected) {
                                                cubit.loadDropdownOptions(furnaceNo: selected?.toString(), cpNo: null);
                                                final val = (selected == 0 ? null : int.tryParse(selected ?? ""));
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
                                              items: _getMatNumbers(state.cpOptions),
                                              hint: "เลือกเลขแมต",
                                              onChanged: (selected) {
                                                // cubit.loadDropdownOptions(furnaceNo: null, cpNo: sp.cpNo);
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
                            onPressed: () async {
                              final cubit = context.read<SettingFormCubit>();
                              final ok = await cubit.saveForm();

                                if (ok) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('บันทึกข้อมูลเรียบร้อยแล้ว'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  Navigator.pop(context, true); // ✅ ส่ง true กลับไป
                                } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(cubit.state.error ?? 'บันทึกไม่สำเร็จ'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                // ❌ error → ไม่ pop, อยู่หน้าเดิมให้แก้ไข
                              }
                            },
                            child: const Text(
                              'บันทึก',
                              style: AppTypography.textBody2WBold,
                            ),
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
                                          // helper: แปลง enum -> label ที่ dropdown ใช้
                                          String _periodTypeToLabel(PeriodType? p) {
                                            switch (p) {
                                              case PeriodType.ONE_MONTH:    return '1 เดือน';
                                              case PeriodType.THREE_MONTHS: return '3 เดือน';
                                              case PeriodType.SIX_MONTHS:   return '6 เดือน';
                                              case PeriodType.ONE_YEAR:     return '1 ปี';
                                              case PeriodType.LIFETIME:     return 'ตลอดเวลา';
                                              case PeriodType.CUSTOM:
                                              default:                      return 'กำหนดเอง';
                                            }
                                          }
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

  // // Update by period (เดิม)
  // void _updateDateRangeByPeriod(BuildContext context, String period) {
  //   final now = DateTime.now();
  //   final cubit = context.read<SettingFormCubit>();
  //   DateTime startDate;
  //   switch (period) {
  //     case '1 เดือน':   startDate = DateTime(now.year, now.month - 1, now.day); break;
  //     case '3 เดือน':   startDate = DateTime(now.year, now.month - 3, now.day); break;
  //     case '6 เดือน':   startDate = DateTime(now.year, now.month - 6, now.day); break;
  //     case '1 ปี':      startDate = DateTime(now.year - 1, now.month, now.day); break;
  //     case 'ตลอดเวลา':  startDate = DateTime(2020, 1, 1); break;
  //     default: // 'กำหนดเอง'
  //       return; // ไม่ auto-update
  //   }

  //   cubit
  //   ..updateStartDate(index, date),
  //   ..updateEndDate(index, endDate);
  //   // SearchBloc จะถูกอัปเดตผ่าน BlocListener อยู่แล้ว
  // }

  List<String> _getFurnaceNumbers(List<String> furnaces) {
    final sorted = (furnaces.map((f) => f).toList()..sort());
    return ["0", ...sorted.map((n) => n.toString())];
  }

  List<String> _getMatNumbers(List<String> mats) {
    final sorted = (mats.map((m) => m).toList()..sort());
    return ["All Material No.", ...sorted.map((n) => n.toString())];
  }


  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final settingState = _settingBloc.state;
    final searchState = context.read<SearchBloc>().state;

    final initial = isStartDate
        ? (searchState.currentQuery.startDate ?? 
        _toDateTime(settingState.formState.startDate) ?? DateTime.now())
        : (searchState.currentQuery.endDate   ?? 
        _toDateTime(settingState.formState.endDate)   ?? DateTime.now());

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

    context.read<SettingBloc>().add(UpdatePeriodS('กำหนดเอง'));
    context.read<SettingBloc>()
      ..add(UpdateStartDate(startDate: newStart))
      ..add(UpdateEndDate(endDate: newEnd));
  }
}
