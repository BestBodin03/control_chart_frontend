import 'package:control_chart/apis/settings/setting_apis.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/data/bloc/setting/setting_bloc.dart';
import 'package:control_chart/domain/models/customer_product.dart';
import 'package:control_chart/domain/models/furnace.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';
import 'package:control_chart/ui/core/shared/form_component.dart';
import 'package:control_chart/ui/core/shared/gradient_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

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
    return BlocProvider.value(
      value: _settingBloc,
      child: MultiBlocListener(
        listeners: [
          // SettingBloc notifications
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

          // Bridge SettingBloc dates to SearchBloc
          BlocListener<SettingBloc, SettingState>(
            listenWhen: (previous, current) {
              return previous.formState.startDate != current.formState.startDate ||
                     previous.formState.endDate != current.formState.endDate;
            },
            listener: (context, state) {
              if (state.formState.startDate != null && state.formState.endDate != null) {
                try {
                  // Parse dates properly
                  DateTime startDateTime;
                  DateTime endDateTime;
                  
                  if (state.formState.startDate is DateTime) {
                    startDateTime = state.formState.startDate!;
                  } else {
                    startDateTime = state.formState.startDate as DateTime;
                  }
                  
                  if (state.formState.endDate is DateTime) {
                    endDateTime = state.formState.endDate!;
                  } else {
                    endDateTime = state.formState.endDate as DateTime;
                  }
                  
                  // Get current SearchBloc state to preserve other filters
                  final searchState = context.read<SearchBloc>().state;
                  
                  context.read<SearchBloc>().add(LoadFilteredChartData(
                    startDate: startDateTime,
                    endDate: endDateTime,
                    furnaceNo: searchState.currentQuery.furnaceNo,
                    materialNo: searchState.currentQuery.materialNo,
                  ));
                } catch (e) {
                  print('Error syncing dates to SearchBloc: $e');
                }
              }
            },
          ),
        ],
        child: BlocBuilder<SettingBloc, SettingState>(
          builder: (context, state) {
            if (state.status == SettingStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == SettingStatus.error) {
              return Center(child: Text('Error: ${state.errorMessage ?? 'Unknown error'}'));
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
                          
                            // Period Dropdown - Use SettingBloc
                            buildDropdownField(
                              context: context,
                              value: formState.periodValue,
                              items: ['1 เดือน', '3 เดือน', '6 เดือน', '1 ปี', 'ตลอดเวลา', 'กำหนดเอง'],
                              onChanged: (value) {
                                context.read<SettingBloc>().add(UpdatePeriodS(value!));
                                // Also update date range based on period
                                _updateDateRangeByPeriod(context, value);
                              },
                            ),

                            const SizedBox(height: 16.0),

                            Row(
                              children: [
                                // Start Date - Show SearchBloc state but sync with SettingBloc
                                BlocBuilder<SearchBloc, SearchState>(
                                  builder: (context, searchState) {
                                    return Expanded(
                                      child: buildDateField(
                                        context: context,
                                        value: searchState.currentQuery.startDate,
                                        label: searchState.currentQuery.startDate != null 
                                              ? DateFormat('MM/dd/yy').format(searchState.currentQuery.startDate!)
                                              : (formState.startDate != null 
                                                  ? DateFormat('MM/dd/yy').format(formState.startDate is String 
                                                      ? formState.startDate!
                                                      : formState.startDate as DateTime)
                                                  : 'Select Date'),
                                        date: searchState.currentQuery.startDate ?? 
                                              (formState.startDate is String 
                                                  ? formState.startDate! 
                                                  : formState.startDate ?? DateTime.now()),
                                        onTap: () => _selectDate(context, true),
                                        onChanged: (date) {
                                          if (date != null) {
                                            // Update both SettingBloc and SearchBloc
                                            context.read<SettingBloc>().add(UpdateStartDate(startDate: date));
                                            context.read<SearchBloc>().add(
                                              LoadFilteredChartData(
                                                startDate: date,
                                                endDate: formState.endDate ?? searchState.currentQuery.endDate,
                                                furnaceNo: searchState.currentQuery.furnaceNo,
                                                materialNo: searchState.currentQuery.materialNo
                                              )
                                            );
                                          }
                                        },
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(width: 16),
                                const Text('ถึง', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87)),
                                const SizedBox(width: 16),
                                
                                // End Date - Show SearchBloc state but sync with SettingBloc
                                BlocBuilder<SearchBloc, SearchState>(
                                  builder: (context, searchState) {
                                    return Expanded(
                                      child: buildDateField(
                                        context: context,
                                        value: searchState.currentQuery.endDate,
                                        label: searchState.currentQuery.endDate != null 
                                              ? DateFormat('MM/dd/yy').format(searchState.currentQuery.endDate!)
                                              : (formState.endDate != null 
                                                  ? DateFormat('MM/dd/yy').format(formState.endDate is String 
                                                      ? formState.endDate! 
                                                      : formState.endDate as DateTime)
                                                  : 'Select Date'),
                                        date: searchState.currentQuery.endDate ?? 
                                              (formState.endDate is String 
                                                  ? formState.endDate!
                                                  : formState.endDate ?? DateTime.now()),
                                        onTap: () => _selectDate(context, false),
                                        onChanged: (date) {
                                          if (date != null) {
                                            // Update both SettingBloc and SearchBloc
                                            context.read<SettingBloc>().add(UpdateEndDate(endDate: date));
                                            context.read<SearchBloc>().add(
                                              LoadFilteredChartData(
                                                startDate: formState.startDate ?? searchState.currentQuery.startDate,
                                                endDate: date,
                                                furnaceNo: searchState.currentQuery.furnaceNo,
                                                materialNo: searchState.currentQuery.materialNo
                                              )
                                            );
                                          }
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Furnace Selection - Fixed dropdown value logic
                            buildSectionTitle('หมายเลขเตา'),
                            const SizedBox(height: 8),
                            BlocBuilder<SearchBloc, SearchState>(
                              builder: (context, searchState) {
                                return buildDropdownField(
                                  context: context,
                                  // Use SearchBloc value if available, otherwise use SettingBloc fallback
                                  value: searchState.currentQuery.furnaceNo ?? formState.selectedItem,
                                  items: _getFurnaceNumbers(furnaces),
                                  onChanged: (value) {
                                    context.read<SearchBloc>().add(LoadFilteredChartData(
                                      startDate: formState.startDate ?? searchState.currentQuery.startDate,
                                      endDate: formState.endDate ?? searchState.currentQuery.endDate,
                                      furnaceNo: value,
                                      materialNo: searchState.currentQuery.materialNo
                                    ));
                                  },
                                );
                              },
                            ),
                            
                            const SizedBox(height: 16),

                            // Material No. Selection - Fixed dropdown value logic
                            buildSectionTitle('Material No.'),
                            const SizedBox(height: 8),
                            BlocBuilder<SearchBloc, SearchState>(
                              builder: (context, searchState) {
                                return buildDropdownField(
                                  context: context,
                                  // Use SearchBloc value if available, otherwise use SettingBloc fallback
                                  value: searchState.currentQuery.materialNo ?? formState.selectedMatNo,
                                  items: _getMatNumbers(matNumbers),
                                  onChanged: (value) {
                                    context.read<SearchBloc>().add(LoadFilteredChartData(
                                      startDate: formState.startDate ?? searchState.currentQuery.startDate,
                                      endDate: formState.endDate ?? searchState.currentQuery.endDate,
                                      furnaceNo: searchState.currentQuery.furnaceNo,
                                      materialNo: value
                                    ));
                                  },
                                );
                              },
                            ),
      
                            const SizedBox(height: 16),

                            // Conditions Selection - Use SettingBloc
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
                            
                            // Limit Value - Use SettingBloc
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
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  elevation: 0,
                                ),
                                child: state.isLoading
                                    ? const SizedBox(
                                        width: 20, height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                                      )
                                    : const Text('บันทึก', style: AppTypography.textBody1WBold),
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

  // Helper method to update date range based on period selection
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
      default: // 'กำหนดเอง'
        return; // Don't auto-update for custom
    }
    
    // Update both SettingBloc and SearchBloc
    context.read<SettingBloc>().add(UpdateStartDate(startDate: startDate));
    context.read<SettingBloc>().add(UpdateEndDate(endDate: now));
    
    // SearchBloc will be updated via the BlocListener above
  }

  List<String> _getFurnaceNumbers(List<Furnace> furnaces) {
    final sortedNumbers = furnaces
        .map((furnace) => furnace.furnaceNo)
        .toList()
      ..sort(); // sort ตัวเลขก่อน
    
    return [
      "0",
      ...sortedNumbers.map((num) => num.toString())
    ];
  }

  List<String> _getMatNumbers(List<CustomerProduct> matNumbers) {
    // Sort ตัวเลขก่อน แล้วค่อยแปลง String
    final sortedNumbers = matNumbers
        .map((mat) => mat.cpNo)
        .toList()
      ..sort();
    
    return [
      "เลือกเลขแมต",
      ...sortedNumbers.map((num) => num.toString())
    ];
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final settingState = _settingBloc.state;
    final searchState = context.read<SearchBloc>().state;
    
    // Use SearchBloc date if available, otherwise use SettingBloc date
    DateTime initialDate;
    if (isStartDate) {
      initialDate = searchState.currentQuery.startDate ?? 
                   (settingState.formState.startDate is String 
                       ? settingState.formState.startDate! 
                       : settingState.formState.startDate ?? DateTime.now());
    } else {
      initialDate = searchState.currentQuery.endDate ?? 
                   (settingState.formState.endDate is String 
                       ? settingState.formState.endDate! 
                       : settingState.formState.endDate ?? DateTime.now());
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (picked != null) {
      try {
        // Update SettingBloc
        if (isStartDate) {
          context.read<SettingBloc>().add(UpdateStartDate(startDate: picked));
        } else {
          context.read<SettingBloc>().add(UpdateEndDate(endDate: picked));
        }
        
        // Update SearchBloc immediately
        context.read<SearchBloc>().add(LoadFilteredChartData(
          startDate: isStartDate ? picked : searchState.currentQuery.startDate,
          endDate: isStartDate ? searchState.currentQuery.endDate : picked,
          furnaceNo: searchState.currentQuery.furnaceNo,
          materialNo: searchState.currentQuery.materialNo,
        ));
      } catch (e) {
        print('Error updating date: $e');
      }
    }
  }
}