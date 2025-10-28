import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:control_chart/apis/settings/setting_apis.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/data/bloc/setting/setting_bloc.dart';
import 'package:control_chart/data/cubit/setting_form/extension/setting_form_cubit_global_period.dart';
import 'package:control_chart/data/cubit/setting_form/setting_form_cubit.dart';
import 'package:control_chart/data/cubit/setting_form/setting_form_state.dart';
import 'package:control_chart/domain/models/chart_detail.dart';
import 'package:control_chart/domain/models/setting.dart';
import 'package:control_chart/domain/types/toastKind.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';
import 'package:control_chart/ui/core/shared/form_component.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/component/profile/profile.dart';

class SettingForm extends StatefulWidget {
  const SettingForm({
    super.key,
    this.profile,
    this.onAddProfile,
  });

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
    final renderBox = _saveBtnKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final topLeft = renderBox.localToGlobal(Offset.zero);

    final Color bg = switch (kind) {
      ToastKind.success => const Color(0xFF22C55E),
      ToastKind.error => const Color(0xFFDC2626),
      ToastKind.info => AppColors.colorBrand,
    };

    _toastEntry?.remove();

    _toastEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: topLeft.dx,
          top: topLeft.dy,
          width: size.width,
          height: size.height,
          child: IgnorePointer(
            ignoring: true,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 8,
                      offset: Offset(0, 2),
                      color: Colors.black26,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      kind == ToastKind.error
                          ? Icons.error_rounded
                          : Icons.check_circle_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.2,
                        ),
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      final formCubit = context.read<SettingFormCubit>();

      if (formCubit.state.specifics.isEmpty) {
        formCubit.addSpecificSetting();
      }

      for (var i = 0; i < formCubit.state.specifics.length; i++) {
        final sp = formCubit.state.specifics[i];
        formCubit.loadDropdownOptions(
          index: i,
          furnaceNo:
              (sp.furnaceNo == null || sp.furnaceNo == 0) ? null : sp.furnaceNo!.toString(),
          cpNo: (sp.cpNo == null || sp.cpNo!.trim().isEmpty) ? null : sp.cpNo,
        );
      }

      _loadInitialChartData(formCubit);
    });
  }

  void _loadInitialChartData(SettingFormCubit formCubit) {
    if (formCubit.state.specifics.isEmpty) return;

    final sp = formCubit.state.specifics.first;
    final startDate = sp.startDate ?? formCubit.state.globalStartDate;
    final endDate = sp.endDate ?? formCubit.state.globalEndDate;

    if (startDate == null || endDate == null) {
      final now = DateTime.now();
      final defaultStart = DateTime(now.year, now.month - 1, now.day);

      context.read<SearchBloc>().add(
            LoadFilteredChartData(
              startDate: defaultStart,
              endDate: now,
              // furnaceNo: null,
              // materialNo: null,
            ),
          );
      return;
    }

    context.read<SearchBloc>().add(
          LoadFilteredChartData(
            startDate: startDate,
            endDate: endDate,
            // furnaceNo: null,
            // materialNo: null,
          ),
        );
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
              if (prev.specifics.length != curr.specifics.length) return true;
              for (var i = 0; i < curr.specifics.length; i++) {
                final p = prev.specifics[i];
                final c = curr.specifics[i];
                if (p.startDate != c.startDate || p.endDate != c.endDate) return true;
              }
              return false;
            },
            listener: (context, state) {
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
              return const Center(child: Text('Error: ${'An unknown error occured'}'));
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

                            s.ruleSelected
                                .where((r) => r.isUsed == true)
                                .map((r) => (r.ruleName ?? '').trim())
                                .where((name) => name.isNotEmpty)
                                .toList();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildSectionTitle('Profile Name'),
                                const SizedBox(height: 8),
                                buildTextField(
                                  value: s.settingProfileName,
                                  hintText: 'Name',
                                  onChanged: (v) => cubit.updateSettingProfileName(v),
                                ),
                                const SizedBox(height: 16),
                                buildSectionTitle('Display Type'),
                                const SizedBox(height: 8),
                                buildChoiceTabs(
                                  selectedValue: selectedDisplayType,
                                  itemsLabel: const [
                                    'Furnace',
                                    'Furnace/Material No.',
                                    'Material No.'
                                  ],
                                  itemsValue: const ['FURNACE', 'FURNACE_CP', 'CP'],
                                  disabled: cubit.state.profileId.isNotEmpty,
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
                                buildSectionTitle('Page Duration (second)'),
                                const SizedBox(height: 8),
                                buildTextField(
                                  value: s.chartChangeInterval > 0
                                      ? s.chartChangeInterval.toString()
                                      : '',
                                  hintText: 'Duration (second)',
                                  onChanged: (v) {
                                    final parsed = int.tryParse(v.trim()) ?? 0;
                                    cubit.updateChartChangeInterval(parsed);
                                  },
                                ),
                                const SizedBox(height: 8),
                                buildSectionTitle('Period'),
                                const SizedBox(height: 8),
                                buildDropdownField(
                                  key: const ValueKey('global_period'),
                                  context: context,
                                  value: _periodTypeToLabel(cubit.state.specifics[0].periodType),
                                  items: const [
                                    '1 month',
                                    '3 months',
                                    '6 months',
                                    '1 year',
                                    'All time',
                                    'custom',
                                  ],
                                  onChanged: (value) {
                                    if (value == null) return;
                                    final now = DateTime.now();
                                    DateTime? startAuto;
                                    PeriodType period;

                                    switch (value) {
                                      case '1 month':
                                        period = PeriodType.ONE_MONTH;
                                        startAuto =
                                            DateTime(now.year, now.month - 1, now.day);
                                        break;
                                      case '3 months':
                                        period = PeriodType.THREE_MONTHS;
                                        startAuto =
                                            DateTime(now.year, now.month - 3, now.day);
                                        break;
                                      case '6 months':
                                        period = PeriodType.SIX_MONTHS;
                                        startAuto =
                                            DateTime(now.year, now.month - 6, now.day);
                                        break;
                                      case '1 year':
                                        period = PeriodType.ONE_YEAR;
                                        startAuto =
                                            DateTime(now.year - 1, now.month, now.day);
                                        break;
                                      case 'All time':
                                        period = PeriodType.LIFETIME;
                                        startAuto = DateTime(2024, 1, 1);
                                        break;
                                      default:
                                        period = PeriodType.CUSTOM;
                                        startAuto = null;
                                    }

                                    cubit.updateGlobalPeriod(
                                      period,
                                      startAuto,
                                      period != PeriodType.CUSTOM
                                          ? now
                                          : cubit.state.globalEndDate,
                                    );

                                    for (int i = 0;
                                        i < cubit.state.specifics.length;
                                        i++) {
                                      cubit.loadDropdownOptions(index: i);
                                    }
                                  },
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: buildDateField(
                                        key: const ValueKey('global_start_date'),
                                        context: context,
                                        value: cubit.state.globalStartDate,
                                        label: _dateLabel(
                                                cubit.state.specifics[0].startDate) ??
                                            'Start Date',
                                        date:
                                            cubit.state.globalStartDate ?? DateTime.now(),
                                        onTap: () async {
                                          final picked = await showDatePicker(
                                            context: context,
                                            initialDate: cubit.state.globalStartDate ??
                                                DateTime.now(),
                                            firstDate: DateTime(2020),
                                            lastDate: DateTime(2050),
                                          );
                                          if (picked == null) return;

                                          cubit.updateGlobalStartDate(picked);
                                          debugPrint(
                                              'The StartDate is = ${cubit.state.globalStartDate?.toIso8601String()}');

                                          for (int i = 0;
                                              i < cubit.state.specifics.length;
                                              i++) {
                                            cubit.loadDropdownOptions(index: i);
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    const Text(
                                      'To',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: buildDateField(
                                        key: const ValueKey('global_end_date'),
                                        context: context,
                                        value: cubit.state.globalEndDate,
                                        label: _dateLabel(
                                                cubit.state.specifics[0].endDate) ??
                                            'End',
                                        date:
                                            cubit.state.globalEndDate ?? DateTime.now(),
                                        onTap: () async {
                                          final picked = await showDatePicker(
                                            context: context,
                                            initialDate: cubit.state.globalEndDate ??
                                                DateTime.now(),
                                            firstDate: DateTime(2020),
                                            lastDate: DateTime(2050),
                                          );
                                          if (picked == null) return;

                                          cubit.updateGlobalEndDate(picked);
                                          debugPrint(
                                              'The EndDate is = ${cubit.state.globalEndDate?.toIso8601String()}');

                                          for (int i = 0;
                                              i < cubit.state.specifics.length;
                                              i++) {
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
                                  // ✅ Capture the current index, not the sp object
                                  return Builder(
                                    builder: (innerContext) {
                                      // ✅ Get fresh sp from current state inside the builder
                                      final currentSp = state.specifics[i];
                                      
                                      final recordCount = innerContext.select<SearchBloc, int>(
                                        (bloc) => cubit.getRecordCountFromChartDetails(
                                          currentSp,  // ✅ Use the fresh sp
                                          bloc.state.chartDetails,
                                        ),
                                      );

                                      return Container(
                                        key: ValueKey(currentSp.id ?? 'spec_$i'),
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            border: Border(
                                              top: BorderSide(
                                                color: Colors.grey.shade300,
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 16.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        buildSectionTitle('Page ${i + 1}'),
                                                        const SizedBox(width: 8),
                                                        Text(
                                                          '($recordCount records)',
                                                          style: const TextStyle(
                                                            fontSize: 14,
                                                            color: AppColors.colorBlack,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 32,),

                                                        SizedBox(
                                                          height: 36,
                                                          child: DecoratedBox(
                                                            decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                      8),
                                                              border: Border.all(
                                                                color: Colors
                                                                    .grey.shade300,
                                                              ),
                                                            ),
                                                            child: Padding(
                                                              padding: const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal: 6),
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize.min,
                                                                children: [
                                                                  IconButton(
                                                                    tooltip:
                                                                        'New Page',
                                                                    onPressed:
                                                                        () async {
                                                                      final cubit = context
                                                                          .read<
                                                                              SettingFormCubit>();
                                                                      final newIndex =
                                                                          cubit
                                                                              .addSpecificSetting();
                                                                      await cubit
                                                                          .loadDropdownOptions(
                                                                              index:
                                                                                  newIndex);
                                                                    },
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(4),
                                                                    constraints:
                                                                        const BoxConstraints(),
                                                                    iconSize: 24,
                                                                    icon: const Icon(
                                                                      Icons
                                                                          .add_circle_rounded,
                                                                      color: AppColors
                                                                          .colorBrand,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      width: 6),
                                                                  SizedBox(
                                                                    width: 1,
                                                                    height: 20,
                                                                    child:
                                                                        DecoratedBox(
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Colors
                                                                            .grey
                                                                            .shade300,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      width: 6),
                                                                  IconButton(
                                                                    tooltip:
                                                                        'Delete Page ${i + 1}',
                                                                    onPressed: state
                                                                                .specifics
                                                                                .length <=
                                                                            1
                                                                        ? null
                                                                        : () => cubit
                                                                            .removeSpecificSetting(
                                                                                i),
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(4),
                                                                    constraints:
                                                                        const BoxConstraints(),
                                                                    iconSize: 24,
                                                                    icon: Icon(
                                                                      Icons
                                                                          .remove_circle_outline_rounded,
                                                                      color: state
                                                                                  .specifics
                                                                                  .length <=
                                                                              1
                                                                          ? Colors.grey
                                                                              .shade300
                                                                          : AppColors
                                                                              .colorAlert1,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    // ... rest of your buttons
                                                  ],
                                                ),
                                                const SizedBox(height: 16),
                                                if (selectedDisplayType == 'FURNACE' ||
                                                    selectedDisplayType == 'FURNACE_CP') ...[
                                                  buildSectionTitle('Furnace No.'),
                                                  const SizedBox(height: 8),
                                                  buildDropdownField(
                                                    key: ValueKey('furnace_$i'),
                                                    context: context,
                                                    value: currentSp.furnaceNo?.toString() ?? 'All Furnaces',
                                                    items: _getFurnaceNumbersByIndex(state, i),
                                                    hint: 'All Furnaces',
                                                    onChanged: (selected) {
                                                      final val = (selected == 'All Furnaces')
                                                          ? null
                                                          : int.tryParse(selected ?? '');
                                                      cubit.updateFurnaceNo(i, val);
                                                      cubit.loadDropdownOptions(
                                                        index: i,
                                                        furnaceNo: val?.toString(),
                                                        cpNo: null,
                                                      );
                                                    },
                                                  ),
                                                  const SizedBox(height: 16),
                                                ],
                                                if (selectedDisplayType == 'CP' ||
                                                    selectedDisplayType == 'FURNACE_CP') ...[
                                                  buildSectionTitle('Material No.'),
                                                  const SizedBox(height: 8),
                                                  buildDropdownField(
                                                    key: ValueKey('cp_$i'),
                                                    context: context,
                                                    value: currentSp.cpNo ?? 'All Material Nos.',
                                                    items: _getMatNumbersByIndex(state, i),
                                                    hint: 'All Material Nos.',
                                                    onChanged: (selected) {
                                                      final val = selected == 'All Material Nos.'
                                                          ? null
                                                          : selected;
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
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }),
                              );
                            },
                          ),
                        ),
                        Builder(
                          builder: (context) {
                            final cubit = context.read<SettingFormCubit>();
                            final profileId =
                                context.select((SettingFormCubit c) =>
                                    c.state.profileId);
                            final isEditing = (profileId.isNotEmpty);
                            final status =
                                context.select((SettingFormCubit c) =>
                                    c.state.status);
                            final error =
                                context.select((SettingFormCubit c) =>
                                    c.state.error);
                            final isSubmitting =
                                status == SubmitStatus.submitting;

                            return SizedBox(
                              width: double.infinity,
                              height: 42,
                              child: ElevatedButton(
                                key: _saveBtnKey,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.colorBrand,
                                  foregroundColor: AppColors.colorBg,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: isSubmitting
                                    ? null
                                    : () async {
                                        // Get chart details for validation
                                        final chartDetails = context.read<SearchBloc>().state.chartDetails;
                                        
                                        // Validate form with chart details
                                      final validationErrors = cubit.validateFormWithChartDetails(chartDetails);
                                      if (validationErrors.isNotEmpty) {
                                        await _showErrorDialog(context, validationErrors);
                                        return;
                                      }

                                        debugPrint('The ID Value To save $profileId');

                                        var savedSuccess = await cubit.saveForm(
                                          id: isEditing ? profileId : null,
                                        );

                                        debugPrint(savedSuccess.toString());

                                        if (savedSuccess) {
                                          await _showToastOnSaveButton(
                                            'Data already saved.',
                                            kind: ToastKind.success,
                                          );
                                          if (!context.mounted) return;
                                          Navigator.pop(context, true);
                                        } else {
                                          await _showToastOnSaveButton(
                                            error ??
                                                (isEditing
                                                    ? 'Update Failed'
                                                    : 'Save Failed'),
                                            kind: ToastKind.error,
                                            duration: const Duration(milliseconds: 2000),
                                          );
                                        }
                                      },
                                child: isSubmitting
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        isEditing ? 'Update' : 'Save',
                                        style: AppTypography.textBody2WBold,
                                      ),
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
  String _periodTypeToLabel(PeriodType? p) {
    switch (p) {
      case PeriodType.ONE_MONTH:
        return '1 month';
      case PeriodType.THREE_MONTHS:
        return '3 months';
      case PeriodType.SIX_MONTHS:
        return '6 months';
      case PeriodType.ONE_YEAR:
        return '1 year';
      case PeriodType.LIFETIME:
        return 'All time';
      case PeriodType.CUSTOM:
      default:
        return 'custom';
    }
  }

  static String? _dateLabel(DateTime? d) =>
      d == null ? null : DateFormat('MM/dd/yy').format(d);

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

  int _getChartDetailCountForIndex(
    int index,
    List<ChartDetail> chartDetails,
    SpecificSettingState sp,
  ) {
    final filtered = chartDetails.where((c) {
      final matchFurnace =
          sp.furnaceNo == null || c.chartGeneralDetail.furnaceNo == sp.furnaceNo;
      final matchCp = sp.cpNo == null || c.cpNo == sp.cpNo;
      return matchFurnace && matchCp;
    }).toList();
    return filtered.length;
  }
}

Future<void> _showErrorDialog(BuildContext context, List<String> errors) async {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: AppColors.colorAlert1,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text(
              'Data Validation Errors',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please correct the following data:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.colorBlack,
                ),
              ),
              const SizedBox(height: 12),
              ...errors.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${entry.key + 1}. ',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.colorAlert1,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.colorBrand,
                foregroundColor: AppColors.colorBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Close',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
