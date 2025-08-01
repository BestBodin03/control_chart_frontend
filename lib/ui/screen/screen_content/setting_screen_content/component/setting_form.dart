

import 'package:control_chart/apis/settings/setting_apis.dart';
import 'package:control_chart/data/bloc/chart_details/chart_details_bloc.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
// import 'package:control_chart/data/bloc/search_chart_details/search_event.dart';
// import 'package:control_chart/data/bloc/search_chart_details/search_state.dart';
import 'package:control_chart/data/bloc/setting/setting_bloc.dart';
// import 'package:control_chart/data/bloc/setting/setting_event.dart';
// import 'package:control_chart/data/bloc/setting/setting_state.dart';
import 'package:control_chart/domain/models/customer_product.dart';
import 'package:control_chart/domain/models/furnace.dart';
import 'package:control_chart/domain/types/chart_filter_query.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';
import 'package:control_chart/ui/core/shared/form_component.dart';
import 'package:control_chart/ui/core/shared/gradient_background.dart';
import 'package:control_chart/ui/core/shared/table_component.dart';
import 'package:control_chart/utils/date_autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingForm extends StatefulWidget {
  const SettingForm({super.key});

  @override
  State<SettingForm> createState() => _SettingFormState();
}

class _SettingFormState extends State<SettingForm> {
  late SettingBloc _settingBloc;
  double backgroundOpacity = 0.2;

  @override
  void initState() {
    super.initState();
    _settingBloc = SettingBloc(settingApis: SettingApis());
    _settingBloc.add(InitializeForm());
  }

  @override
  void dispose() {
    _settingBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: _settingBloc,
        )
      ],
child: MultiBlocListener(
        listeners: [
          // Listener สำหรับ SettingBloc notifications
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
              if (state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),

          BlocListener<SettingBloc, SettingState>(
          listenWhen: (previous, current) {
            // Only listen when dates actually change
          if (previous.formState.startDate != current.formState.startDate ||
            previous.formState.endDate != current.formState.endDate) {
          return true;
          }
            return false;
          },
          listener: (context, state) {
            if (state.formState.startDate != null && state.formState.endDate != null) {
            context.read<SearchBloc>().add(UpdateDateRange(
              startDate: state.formState.startDate!,
              endDate: state.formState.endDate!,
            ));
            }
          },
        ),
        ],
        child: BlocBuilder<SettingBloc, SettingState>(
          builder: (context, state) {
            // Handle loading states
            if (state.status == SettingStatus.loading) {
            return const Center(child: CircularProgressIndicator());
            }

            if (state.status == SettingStatus.error) {
            return Center(child: Text('Error: ${state.errorMessage ?? 'Unknown error'}'));
            }

            if (state.formState == null) {
            return const Center(child: Text('กำลังโหลด...'));
            }

            final formState = state.formState;
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
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.6),
                          blurRadius: 10,
                          offset: const Offset(-5, -5),
                        ),
                        BoxShadow(
                          color: AppColors.colorBrandTp.withValues(alpha: 0.4),
                          blurRadius: 15,
                          offset: const Offset(5, 5),
                        ),
                      ],
                    ),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildSectionTitle('ระยะเวลา'),
                            const SizedBox(height: 8.0),
                          
                            // Period Dropdown
                              buildDropdownField(
                                  context: context,
                                  value: formState.periodValue,
                                  items: ['1 เดือน', '3 เดือน', '6 เดือน', '1 ปี', 'ตลอดเวลา', 'กำหนดเอง'],
                                  onChanged: (value) {
                                    // print('📅 Period selected: $value');
                                    context.read<SettingBloc>().add(UpdatePeriodS(value!));
                                  },
                              ),

                            const SizedBox(height: 16.0),

                            Row(
                              children: [
                                // Start Date
                                BlocBuilder<SearchBloc, SearchState>(
                                  builder: (context, searchState) {
                                    return Expanded(
                                      child: buildDateField(
                                        context: context,
                                        value: formState.startDate, // ใช้ formState เหมือน dropdown
                                        label: formState.startDateLabel,
                                        date: formState.startDate!,
                                        onTap: () => _selectDate(context, true),
                                        onChanged: (date) {
                                          // print('📅 Start Date selected: $date');
                                          context.read<SearchBloc>().add(
                                            LoadFilteredChartData(startDate: date!)
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(width: 16),

                                const Text(
                                  'ถึง',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                
                                // End Date
                                // End Date
                                BlocBuilder<SearchBloc, SearchState>(
                                  builder: (context, searchState) {
                                    return Expanded(
                                      child: buildDateField(
                                        context: context,
                                        value: searchState.currentQuery.endDate, // ใช้ searchState แทน formState
                                        label: searchState.currentQuery.endDate.toString(), // แก้ไขจาก USEEEEEEEEEEEEEEE
                                        date: searchState.currentQuery.endDate!,
                                        onTap: () => _selectDate(context, false),
                                        onChanged: (date) {
                                          context.read<SearchBloc>().add(
                                            LoadFilteredChartData(endDate: date!)
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Furnace Selection
                            buildSectionTitle('หมายเลขเตา'),
                            const SizedBox(height: 8),
                            BlocBuilder<SearchBloc, SearchState>(
                              builder: (context, searchState) {
                                return buildDropdownField(
                                  context: context,
                                  value: searchState.currentQuery.furnaceNo != null ? null : formState.selectedItem,
                                  items: _getFurnaceNumbers(furnaces),
                                  onChanged: (value) {
                                    // print('🔥 Furnace selected: $value');
                                    context.read<SearchBloc>().add(LoadFilteredChartData(furnaceNo: value));
                                  },
                                );
                              },
                            ),
                            
                            const SizedBox(height: 16),

                            // Material No. Selection 
                            buildSectionTitle('Material No.'),
                            const SizedBox(height: 8),
                            BlocBuilder<SearchBloc, SearchState>(
                              builder: (context, searchState) {
                                return buildDropdownField(
                                  context: context,
                                  value: searchState.currentQuery.materialNo != null ? null : formState.selectedMatNo,
                                  items: _getMatNumbers(matNumbers),
                                  onChanged: (value) {
                                    // print('🧪 Material selected: $value');
                                    context.read<SearchBloc>().add(LoadFilteredChartData(materialNo: value));
                                  },
                                );
                              },
                            ),
      
                            const SizedBox(height: 16),

                            // Conditions Selection
                            buildSectionTitle('การแจ้งเตือน'),
                            const SizedBox(height: 8),
                            buildMultiSelectField(
                              context: context,
                              selectedValues: formState.selectedConditions,
                              items: ['เกิน UCL', 'เกิน LCL', 'เกิน USL', 'เกิน LSL'],
                              onChanged: (values) {
                                // context.read<SettingBloc>().add(UpdateSelectedConditions(values));
                              },
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Limit Value
                            buildSectionTitle('ระยะเวลาการเปลี่ยนหน้าจอ (วินาที)'),
                            const SizedBox(height: 8),
                            buildTextField(
                              value: formState.limitValue,
                              onChanged: (value) {
                                // context.read<SettingBloc>().add(UpdateLimitValue(value));
                              },
                            ),
                            
                            const SizedBox(height: 48),
                            
                            // Submit Button
                            SizedBox(
                              width: double.infinity,
                              height: 42,
                              child: ElevatedButton(
                                onPressed: state.isLoading ? null : () {
                                  context.read<SettingBloc>().add(SaveFormData());
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.colorBrand,
                                  foregroundColor: AppColors.colorBg,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                child: state.isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Text(
                                        'บันทึก',
                                        style: AppTypography.textBody1WBold,
                                      ),
                              ),
                            ),
                          ],
                        ),
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

  List<String> _getFurnaceNumbers(List<Furnace> furnaces) {
    final furnaceNumbers = furnaces.map((furnace) => furnace.furnaceNo).toList();
    furnaceNumbers.sort();
    return furnaceNumbers.map((num) => num.toString()).toList();
  }

  List<String> _getMatNumbers(List<CustomerProduct> matNumbers) {
    final matNoNumbers = matNumbers.map((mat) => mat.cpNo).toList();
    matNoNumbers.sort();
    return matNoNumbers;
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final state = _settingBloc.state;
    if (state.formState == null) return;

    final initialDate = isStartDate 
      ? (state.formState.startDate)
      : (state.formState.endDate);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (picked != null) {
      print(picked);
    try {
      if (isStartDate) {
        context.read<SettingBloc>().add(UpdateStartDate(
          // startDateLabel: DateAutoComplete.formatDateLabel(picked, isStartDate),
          startDate: picked));
      } else {
        context.read<SettingBloc>().add(UpdateEndDate(
          // endDateLabel: DateAutoComplete.formatDateLabel(picked, true),
          endDate: picked));
      }
    } catch (e) {
      }
    }
  }
}