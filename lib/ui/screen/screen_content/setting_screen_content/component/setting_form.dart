
import 'package:control_chart/apis/settings/setting_apis.dart';
import 'package:control_chart/data/bloc/setting/setting_bloc.dart';
import 'package:control_chart/data/bloc/setting/setting_event.dart';
import 'package:control_chart/data/bloc/setting/setting_state.dart';
import 'package:control_chart/domain/models/customer_product.dart';
import 'package:control_chart/domain/models/furnace.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';
import 'package:control_chart/ui/core/shared/form_component.dart';
import 'package:control_chart/ui/core/shared/gradient_background.dart';
import 'package:control_chart/utils/date_autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingForm extends StatefulWidget {
  const SettingForm({super.key});

  @override
  State<SettingForm> createState() => _SettingFormState();
}

class _SettingFormState extends State<SettingForm> {
  DateTime startDate = DateTime(2024, 12, 30);
  DateTime endDate = DateTime(2024, 2, 24);
  String selectedItem = '';
  String limitValue = '9';
  String periodValue = '1 เดือน';
  List<String> selectedConditons = [];
  double backgroundOpacity = 0.2;
  List<Furnace> furnaces = [];
  List<CustomerProduct> matNo = [];
  String startDateLabel = '';
  String endDateLabel = '';

  final _formKey = GlobalKey<FormState>();

   @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingBloc(settingApis: SettingApis())..add(LoadAllData()),
      child: BlocConsumer<SettingBloc, SettingState>(
        listener: (context, state) {
          if (state is FormDataState && state.isSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('บันทึกข้อมูลเรียบร้อยแล้ว'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is! FormDataState) {
            return Center(child: CircularProgressIndicator());
          }

          final formState = state.formState;

          return Form(
            key: _formKey,
            child: GradientBackground(
              opacity: 0.2,
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
                          offset: Offset(-5, -5),
                        ),
                        BoxShadow(
                          color: AppColors.colorBrandTp.withValues(alpha: 0.4),
                          blurRadius: 15,
                          offset: Offset(5, 5),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildSectionTitle('ระยะเวลา'),
                          const SizedBox(height: 8.0),
                          buildDropdownField(
                            context: context,
                            value: formState.periodValue,
                            items: ['1 เดือน', '3 เดือน', '6 เดือน', '1 ปี', 'ตลอดเวลา', 'กำหนดเอง'],
                            onChanged: (value) {
                              context.read<SettingBloc>().add(UpdatePeriod(value!));
                            },
                          ),
                          
                          const SizedBox(height: 16.0),
                          
                          // Date range selector
                          Row(
                            children: [
                              Expanded(
                                child: buildDateField(
                                  label: formState.startDateLabel,
                                  date: formState.startDate,
                                  onTap: () => _selectDate(context, true),
                                ),
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
                              Expanded(
                                child: buildDateField(
                                  label: formState.endDateLabel,
                                  date: formState.endDate,
                                  onTap: () => _selectDate(context, false),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Item Selection
                          buildSectionTitle('หมายเลขเตา'),
                          const SizedBox(height: 8),
                          buildDropdownField(
                            context: context,
                            value: formState.selectedItem,
                            items: _getFurnaceItems(state.furnaces),
                            onChanged: (value) {
                              context.read<SettingBloc>().add(UpdateSelectedItem(value!));
                            },
                          ),
                          
                          const SizedBox(height: 16),
                              
                          // Material No Selection
                          buildSectionTitle('Material No.'),
                          const SizedBox(height: 8),
                          buildDropdownField(
                            context: context,
                            value: formState.selectedMatNo,
                            items: _getMatNoItems(state.matNumbers),
                            onChanged: (value) {
                              context.read<SettingBloc>().add(UpdateSelectedMatNo(value!));
                            },
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Test Type Selection
                          buildSectionTitle('การแจ้งเตือน'),
                          const SizedBox(height: 8),
                          buildMultiSelectField(
                            context: context,
                            selectedValues: formState.selectedConditions,
                            items: ['เกิน UCL', 'เกิน LCL', 'เกิน USL', 'เกิน LSL'],
                            onChanged: (values) {
                              context.read<SettingBloc>().add(UpdateSelectedConditions(values));
                            },
                          ),
                          
                          const SizedBox(height: 16),
                    
                          buildSectionTitle('ระยะเวลาการเปลี่ยนหน้าจอ (วินาที)'),
                          const SizedBox(height: 8),
                          buildTextField(
                            value: formState.limitValue,
                            onChanged: (value) {
                              context.read<SettingBloc>().add(UpdateLimitValue(value));
                            },
                          ),
                    
                          const SizedBox(height: 48),
                          
                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            height: 42,
                            child: ElevatedButton(
                              onPressed: () {
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
                              child: const Text(
                                'บันทึก',
                                style: AppTypography.textBody1WBold
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
    );
  }

  List<String> _getFurnaceItems(List<Furnace>? furnaces) {
    if (furnaces == null) return [];
    final furnaceNumbers = furnaces.map((furnace) => furnace.furnaceNo).toList();
    furnaceNumbers.sort();
    return furnaceNumbers.map((num) => num.toString()).toList();
  }

  List<String> _getMatNoItems(List<CustomerProduct>? matNumbers) {
    if (matNumbers == null) return [];
    final matNoNumbers = matNumbers.map((mat) => mat.cpNo).toList();
    matNoNumbers.sort();
    return matNoNumbers;
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final currentState = context.read<SettingBloc>().state as FormDataState;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? currentState.formState.startDate : currentState.formState.endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (picked != null) {
      if (isStartDate) {
        context.read<SettingBloc>().add(UpdateStartDate(picked));
      } else {
        context.read<SettingBloc>().add(UpdateEndDate(picked));
      }
    }
  }
}