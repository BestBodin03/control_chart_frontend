import 'package:control_chart/apis/settings/setting_apis.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/data/bloc/setting/setting_bloc.dart';
import 'package:control_chart/data/cubit/setting_form/setting_form_cubit.dart';
import 'package:control_chart/data/cubit/setting_form/setting_form_state.dart';
import 'package:control_chart/domain/models/setting.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';
import 'package:control_chart/ui/core/shared/form_component.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/component/profile/profile.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/setting_var.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class SettingForm extends StatefulWidget {
  const SettingForm({
    super.key,
    this.profile});

    final Profile? profile;

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

  // โหลด options ครั้งแรกหลัง build แรก
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;
    final formCubit = context.read<SettingFormCubit>();

    if (formCubit.state.specifics.isEmpty) {
      formCubit.addSpecificSetting(); // ให้มีอย่างน้อย 1 แถว
    }

    // โหลดรายการของ “ทุกแถว” ตาม index
    for (var i = 0; i < formCubit.state.specifics.length; i++) {
      formCubit.loadDropdownOptions(index: i); // ↩️ ให้ Cubit ดึง period/start/end เองจาก state
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
                                                    onPressed: () async {
                                                      final cubit = context.read<SettingFormCubit>();
                                                      final newIndex = cubit.addSpecificSetting();     // ✅ ได้ index ใหม่แน่นอน
                                                      await cubit.loadDropdownOptions(index: newIndex); // ✅ โหลดรายการของแถวนั้น
                                                    }
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
  key: ValueKey('period_$i'),
  context: context,
  value: _periodTypeToLabel(sp.periodType),
  items: const ['1 เดือน','3 เดือน','6 เดือน','1 ปี','ตลอดเวลา','กำหนดเอง'],
  onChanged: (value) {
    if (value == null) return;
    final now = DateTime.now();
    DateTime? startAuto;
    PeriodType period;

    switch (value) {
      case '1 เดือน': period = PeriodType.ONE_MONTH;   startAuto = DateTime(now.year, now.month - 1, now.day); break;
      case '3 เดือน': period = PeriodType.THREE_MONTHS; startAuto = DateTime(now.year, now.month - 3, now.day); break;
      case '6 เดือน': period = PeriodType.SIX_MONTHS;   startAuto = DateTime(now.year, now.month - 6, now.day); break;
      case '1 ปี':    period = PeriodType.ONE_YEAR;     startAuto = DateTime(now.year - 1, now.month, now.day); break;
      case 'ตลอดเวลา': period = PeriodType.LIFETIME;    startAuto = DateTime(2024, 1, 1); break;
      default:         period = PeriodType.CUSTOM;       startAuto = null;
    }

    cubit.updatePeriodType(i, period);
    if (period != PeriodType.CUSTOM) {
      cubit
        ..updateStartDate(i, startAuto!)
        ..updateEndDate(i, now);
    }

    // ✅ รีโหลดรายการของ “แถวนี้” ให้ตรงกับ period ใหม่
    cubit.loadDropdownOptions(index: i);
  },
),


                                            const SizedBox(height: 16),

                                            // ------- Date pickers -------
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: buildDateField(
                                                    key: ValueKey('start_$i'), // ✅
                                                    context: context,
                                                    value: sp.startDate,
                                                    label: _dateLabel(sp.startDate) ?? 'Select Date',
                                                    date: sp.startDate ?? DateTime.now(),
                                                    onTap: () async {
                                                      final picked = await showDatePicker(
                                                        context: context,
                                                        initialDate: sp.startDate ?? DateTime.now(),
                                                        firstDate: DateTime(2020),
                                                        lastDate: DateTime(2050),
                                                      );
                                                      if (picked == null) return;
                                                      cubit.updateStartDate(i, picked, setCustom: true);
                                                      cubit.loadDropdownOptions(index: i); // ✅
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                const Text('ถึง', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: buildDateField(
                                                    key: ValueKey('end_$i'), // ✅
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
                                                      cubit
                                                        ..updateEndDate(i, picked, setCustom: true)
                                                        ..updatePeriodType(i, PeriodType.CUSTOM)
                                                        ..loadDropdownOptions(index: i);
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 16),

                                            // ------- Furnace -------
                                            if (selectedDisplayType == 'FURNACE' || selectedDisplayType == 'FURNACE_CP') ...[
                                              buildSectionTitle('หมายเลขเตา'),
                                              const SizedBox(height: 8),
                                              buildDropdownField(
                                                key: ValueKey('furnace_$i'), // ✅
                                                context: context,
                                                value: sp.furnaceNo?.toString() ?? "All Furnaces",
                                                // ⬇️ ดึง items ตาม index
                                                items: _getFurnaceNumbersByIndex(state, i),
                                                hint: "All Furnaces",
                                                onChanged: (selected) {
                                                  final val = (selected == "All Furnaces") ? null : int.tryParse(selected ?? "");
                                                  cubit.updateFurnaceNo(i, val);
                                                  cubit.loadDropdownOptions(
                                                    index: i,
                                                    // ส่งค่าปัจจุบันของแถวนี้ไปด้วย (ให้ API ฟิลเตอร์ร่วม)
                                                    furnaceNo: val?.toString(),
                                                    cpNo: state.specifics[i].cpNo,
                                                  );
                                                },
                                              ),
                                              const SizedBox(height: 16),
                                            ],

                                            // ------- Material -------
                                            if (selectedDisplayType == 'CP' || selectedDisplayType == 'FURNACE_CP') ...[
                                              buildSectionTitle('หมายเลขแมต'),
                                              const SizedBox(height: 8),
                                              buildDropdownField(
                                                key: ValueKey('cp_$i'), // ✅
                                                context: context,
                                                value: sp.cpNo ?? "All Material Nos.",
                                                items: _getMatNumbersByIndex(state, i),
                                                hint: "All Material Nos.",
                                                onChanged: (selected) {
                                                  final val = selected == "All Material Nos." ? null : selected;
                                                  cubit.updateCpNo(i, val);
                                                  cubit.loadDropdownOptions(
                                                    index: i,
                                                    furnaceNo: state.specifics[i].furnaceNo?.toString(),
                                                    cpNo: val,
                                                  );
                                                },
                                              ),
                                              const SizedBox(height: 48),
                                            ],
                                        ]
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

                              final bool isUpdate = widget.profile!.id.isNotEmpty;
                              print('the value of update or create: $isUpdate');
                              print(widget.profile!.id);

                              // ถ้าเป็นโหมด update → เซ็ตค่าเริ่มจาก profile เดิมก่อน
                              if (isUpdate) {
                                cubit
                                  ..updateSettingProfileName(widget.profile!.name)
                                  ..updateDisplayType(widget.profile!.profileDisplayType!)
                                  ..updateChartChangeInterval(widget.profile!.chartChangeInterval!)
                                  ..updateRuleSelected(widget.profile!.ruleSelected!)
                                  ..updateSpecifics(widget.profile!.specifics!)
                                  ..updateIsUsed(false);
                              }

                              // ✅ save โดยมีหรือไม่มี id
                              final success = await cubit.saveForm(
                                id: isUpdate ? widget.profile!.id : null,
                              );

                              if (success) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(isUpdate ? 'อัปเดตข้อมูลเรียบร้อยแล้ว' : 'บันทึกข้อมูลเรียบร้อยแล้ว'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  Navigator.pop(context, true);
                                }
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(cubit.state.error ?? (isUpdate ? 'อัปเดตไม่สำเร็จ' : 'บันทึกไม่สำเร็จ')),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            child: Text(
                              (widget.profile?.id.isNotEmpty ?? false) ? 'อัปเดต' : 'บันทึก',
                              style: AppTypography.textBody2WBold,
                            ),
                          ),
                        ),
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

  List<String> _getFurnaceNumbersByIndex(SettingFormState s, int i) {
    final list = s.furnaceOptionsByIndex[i] ?? const <String>[];

    final sorted = List<String>.from(list)
      ..sort((a, b) {
        final ai = int.tryParse(a) ?? 0;
        final bi = int.tryParse(b) ?? 0;
        return ai.compareTo(bi);
      });

    return ['All Furnaces', ...sorted];
  }

  List<String> _getMatNumbersByIndex(SettingFormState s, int i) {
    final list = s.cpOptionsByIndex[i] ?? const <String>[];

    final sorted = List<String>.from(list)..sort();

    return ['All Material Nos.', ...sorted];
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
