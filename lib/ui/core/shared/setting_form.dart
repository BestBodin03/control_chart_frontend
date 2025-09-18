import 'package:control_chart/apis/settings/setting_apis.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/data/bloc/setting/setting_bloc.dart';
import 'package:control_chart/data/bloc/setting_profile/setting_profile_bloc.dart';
import 'package:control_chart/data/cubit/setting_form/extension/setting_form_cubit_global_period.dart';
import 'package:control_chart/data/cubit/setting_form/setting_form_cubit.dart';
import 'package:control_chart/data/cubit/setting_form/setting_form_state.dart';
import 'package:control_chart/domain/models/setting.dart';
import 'package:control_chart/domain/types/toastKind.dart';
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
    this.profile,
     this.onAddProfile});

    final Profile? profile;
    final VoidCallback? onAddProfile;

  @override
  State<SettingForm> createState() => _SettingFormState();
}

class _SettingFormState extends State<SettingForm> {
  late final SettingBloc _settingBloc;
  String selectedDisplayType = '';
  final double backgroundOpacity = 0.2;
  final GlobalKey _saveBtnKey = GlobalKey();
  OverlayEntry? _toastEntry;

Future<void> _showToastOnSaveButton(
  String text, {
  ToastKind kind = ToastKind.success,
  Duration duration = const Duration(milliseconds: 1500),
}) async {
  // หา widget ปุ่มจาก GlobalKey
  final renderBox = _saveBtnKey.currentContext?.findRenderObject() as RenderBox?;
  if (renderBox == null) return;

  final size = renderBox.size;
  final topLeft = renderBox.localToGlobal(Offset.zero);

  // สีตามชนิด
  final Color bg = switch (kind) {
    ToastKind.success => const Color(0xFF22C55E), // green-600
    ToastKind.error   => const Color(0xFFDC2626), // red-600
    ToastKind.info    => AppColors.colorBrand,
  };

  // ลบของเดิมถ้ามี
  _toastEntry?.remove();

  _toastEntry = OverlayEntry(
    builder: (context) {
      return Positioned(
        left: topLeft.dx,
        top: topLeft.dy,
        width: size.width,
        height: size.height,
        child: IgnorePointer(
          ignoring: true, // ไม่บังการกดปุ่ม
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(blurRadius: 8, offset: Offset(0, 2), color: Colors.black26),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    kind == ToastKind.error ? Icons.error_rounded : Icons.check_circle_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      text,
                      style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.2),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );

  final overlay = Overlay.maybeOf(context);
  if (overlay == null) return;

  overlay.insert(_toastEntry!);
  await Future.delayed(duration);
  _toastEntry?.remove();
  _toastEntry = null;
}


@override
void initState() {
  super.initState();
  _settingBloc = SettingBloc(settingApis: SettingApis())..add(InitializeForm());

  // โหลด options ครั้งแรกหลัง build แรก
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!context.mounted) return;
    final formCubit = context.read<SettingFormCubit>();

    if (formCubit.state.specifics.isEmpty) {
      formCubit.addSpecificSetting(); // ให้มีอย่างน้อย 1 แถว
    }

    // โหลดรายการของ “ทุกแถว” ตาม index
for (var i = 0; i < formCubit.state.specifics.length; i++) {
  final sp = formCubit.state.specifics[i];
  formCubit.loadDropdownOptions(
    index: i,
    furnaceNo: (sp.furnaceNo == null || sp.furnaceNo == 0)
        ? null
        : sp.furnaceNo!.toString(),
    cpNo: (sp.cpNo == null || sp.cpNo!.trim().isEmpty)
        ? null
        : sp.cpNo,
  );
}

  });
}


  @override
  void dispose() {
    _settingBloc.close();
    _toastEntry?.remove();
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
                            // debugPrint('The ID of this profile card: $s.profileId');
                            // debugPrint('In setting form ${cubit.state.specifics[0].periodType}');

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
                            s.ruleSelected
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
                                  disabled: cubit.state.profileId.isNotEmpty, // 👈 ล็อกเมื่อมี profileId
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
                                      cubit.updateRuleSelected();
                                    }
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

                                const SizedBox(height: 8),
                                buildSectionTitle('ระยะเวลา'),
                                const SizedBox(height: 8),

                                buildDropdownField(
                                  key: const ValueKey('global_period'),
                                  context: context,
                                  value: _periodTypeToLabel(cubit.state.specifics[0].periodType),
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
                                      default: 
                                        period = PeriodType.CUSTOM;       
                                        startAuto = null;
                                    }

                                    // Update global period settings
                                    cubit.updateGlobalPeriod(
                                      period, 
                                      startAuto, 
                                      period != PeriodType.CUSTOM ? now : cubit.state.globalEndDate
                                    );
                                    
                                    // Reload dropdown options for all specifics
                                    for (int i = 0; i < cubit.state.specifics.length; i++) {
                                      cubit.loadDropdownOptions(index: i);
                                    }
                                  },
                                ),

                                const SizedBox(height: 16),

                                

                                // ------- Global Date pickers -------
                                Row(
                                  children: [
                                    Expanded(
                                      child: buildDateField(
                                        key: const ValueKey('global_start_date'),
                                        context: context,
                                        value: cubit.state.globalStartDate,
                                        label: _dateLabel(cubit.state.specifics[0].startDate) ?? 'Start Date',
                                        date: cubit.state.globalStartDate ?? DateTime.now(),
                                        onTap: () async {
                                          final picked = await showDatePicker(
                                            context: context,
                                            initialDate: cubit.state.globalStartDate ?? DateTime.now(),
                                            firstDate: DateTime(2020),
                                            lastDate: DateTime(2050),
                                          );
                                          if (picked == null) return;
                                          
                                          cubit.updateGlobalStartDate(picked);
                                          
                                          // Reload dropdown options for all specifics
                                          for (int i = 0; i < cubit.state.specifics.length; i++) {
                                            cubit.loadDropdownOptions(index: i);
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    const Text('ถึง', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: buildDateField(
                                        key: const ValueKey('global_end_date'),
                                        context: context,
                                        value: cubit.state.globalEndDate,
                                        label: _dateLabel(cubit.state.specifics[0].endDate) ?? 'End',
                                        date: cubit.state.globalEndDate ?? DateTime.now(),
                                        onTap: () async {
                                          final picked = await showDatePicker(
                                            context: context,
                                            initialDate: cubit.state.globalEndDate ?? DateTime.now(),
                                            firstDate: DateTime(2020),
                                            lastDate: DateTime(2050),
                                          );
                                          if (picked == null) return;
                                          
                                          cubit.updateGlobalEndDate(picked);
                                          
                                          // Reload dropdown options for all specifics
                                          for (int i = 0; i < cubit.state.specifics.length; i++) {
                                            cubit.loadDropdownOptions(index: i);
                                          }
                                        },
                                      ),
                                    ),
                                  ],
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
                                            buildSectionTitle('หน้าที่ ${i + 1}'),
                                            SizedBox(
                                              height: 36,
                                              child: DecoratedBox(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(color: Colors.grey.shade300),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      // Add button
                                                      IconButton(
                                                        tooltip: 'เพิ่มหน้า',
                                                        onPressed: () async {
                                                          final cubit = context.read<SettingFormCubit>();
                                                          final newIndex = cubit.addSpecificSetting();
                                                          await cubit.loadDropdownOptions(index: newIndex);
                                                        },
                                                        padding: EdgeInsets.all(4),
                                                        constraints: const BoxConstraints(),
                                                        iconSize: 24,
                                                        icon: const Icon(
                                                          Icons.add_circle_rounded,
                                                          color: AppColors.colorBrand,
                                                        ),
                                                      ),

                                                      const SizedBox(width: 6),

                                                      // Divider
                                                      SizedBox(
                                                        width: 1,
                                                        height: 20,
                                                        child: DecoratedBox(
                                                          decoration: BoxDecoration(color: Colors.grey.shade300),
                                                        ),
                                                      ),

                                                      const SizedBox(width: 6),
                                                      // Remove button
                                                      IconButton(
                                                        tooltip: 'ลบหน้า',
                                                        onPressed: state.specifics.length <= 1 
                                                            ? null 
                                                            : () => cubit.removeSpecificSetting(i), // ✅ Pass the index i
                                                        padding: EdgeInsets.all(4),
                                                        constraints: const BoxConstraints(),
                                                        iconSize: 24,
                                                        icon: Icon(
                                                          Icons.remove_circle_outline_rounded,
                                                          color: state.specifics.length <= 1
                                                              ? Colors.grey.shade300
                                                              : AppColors.colorAlert1,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )

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
                                                    cpNo: null,
                                                    // cpNo: state.specifics[i].cpNo,
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
                                                    // furnaceNo: null,
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

                      Builder(
                        builder: (context) {
                          final cubit = context.read<SettingFormCubit>();
                          final profileId  = context.select((SettingFormCubit c) => c.state.profileId);
                          final isEditing  = (profileId.isNotEmpty);
                          final status     = context.select((SettingFormCubit c) => c.state.status);
                          final error      = context.select((SettingFormCubit c) => c.state.error);
                          final isSubmitting = status == SubmitStatus.submitting;

                          return SizedBox(
                            width: double.infinity,
                            height: 42,
                            child: ElevatedButton(
                              key: _saveBtnKey, // 👈 สำคัญ! ไว้หาตำแหน่ง/ขนาดปุ่ม
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.colorBrand,
                                foregroundColor: AppColors.colorBg,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                elevation: 0,
                              ),
                              onPressed: isSubmitting ? null : () async {
                                debugPrint('The ID Value To save $profileId');

                                var savedSuccess = await cubit.saveForm(
                                  id: isEditing ? profileId : null,
                                );

                                // if (!context.mounted) return;

                                debugPrint(savedSuccess.toString());

                              if (savedSuccess) {
                                await _showToastOnSaveButton(
                                  'บันทึกข้อมูลเรียบร้อยแล้ว',
                                  kind: ToastKind.success, // ✅ เขียว
                                );
                                if (!context.mounted) return;
                                // context.read<SettingProfileBloc>().add(const RefreshSettingProfiles());
                                Navigator.pop(context, true); // parent will refresh
                              } else {
                                await _showToastOnSaveButton(
                                  error ?? (isEditing ? 'อัปเดตไม่สำเร็จ' : 'บันทึกไม่สำเร็จ'),
                                  kind: ToastKind.error,      // ❌ แดง
                                  duration: const Duration(milliseconds: 2000),
                                );
                              }

                              },
                              child: isSubmitting
                                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                  : Text(isEditing ? 'อัปเดต' : 'บันทึก', style: AppTypography.textBody2WBold),
                            ),
                          );
                        },
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

  static String? _dateLabel(DateTime? d) => d == null ? null : DateFormat('MM/dd/yy').format(d);

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

}
