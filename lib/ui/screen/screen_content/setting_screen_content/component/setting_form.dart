
import 'package:control_chart/apis/settings/setting_filtering.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';
import 'package:control_chart/ui/core/shared/form_component.dart';
import 'package:control_chart/ui/core/shared/gradient_background.dart';
import 'package:flutter/material.dart';

class SettingForm extends StatefulWidget {
  const SettingForm({super.key});

  @override
  State<SettingForm> createState() => _SettingFormState();
}

class _SettingFormState extends State<SettingForm> {
  DateTime startDate = DateTime(2024, 12, 30);
  DateTime endDate = DateTime(2024, 2, 24);
  String selectedItem = '1';
  String limitValue = '9';
  String periodValue = '1 เดือน';
  String selectedItems = '';
  List<String> selectedConditons = [];
  double backgroundOpacity = 0.2;

  @override
  void initState() {
    super.initState();
    // Call API when widget initializes
    getHttp();
  }

  @override
  Widget build(BuildContext context) {
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
                // border:Border.all(
                //   color: Colors.black
                // ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.6),
                    blurRadius: 10,
                    offset: Offset(-5, -5),
                  ),
                  BoxShadow(
                    color: AppColors.colorBrandTp.withOpacity(0.4),
                    blurRadius: 15,
                    offset: Offset(5, 5),
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
                
                      buildDropdownField(
                        context: context,
                        value: periodValue,
                        items: ['1 เดือน', '3 เดือน', '6 เดือน', '1 ปี', 'กำหนดเอง'],
                        onChanged: (value) {
                          setState(() {
                            periodValue = value!;
                          });
                        },
                      ),
                  
                      const SizedBox(height: 16.0),
                      
                      Row(
                        children: [
                          Expanded(
                            child: buildDateField(
                              label: '30/12/24',
                              date: startDate,
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
                              label: '24/2/24',
                              date: endDate,
                              onTap: () => _selectDate(context, false),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Item Selection
                      buildSectionTitle('หมายเลขเตา'),
                      const SizedBox(height: 8),
                      // Product Selection
                      buildDropdownField(
                        context: context,
                        value: selectedItem,
                        items: ['1','2','3','4'],
                        onChanged: (value) {
                          setState(() {
                            selectedItem = value!;
                          });
                        },
                      ),
                      
                      const SizedBox(height: 16),
                          
                      // Days Selection
                      buildSectionTitle('Material No.'),
                      const SizedBox(height: 8),
                      buildDropdownField(
                        context: context,
                        value: periodValue,
                        items: ['1 เดือน', '3 เดือน', '6 เดือน', '1 ปี', 'กำหนดเอง'],
                        onChanged: (value) {
                          setState(() {
                            periodValue = value!;
                          });
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Test Type Selection
                      buildSectionTitle('การแจ้งเตือน'),
                      const SizedBox(height: 8),
                      buildMultiSelectField(
                        context: context,
                        selectedValues: selectedConditons, 
                        items: ['เกิน UCL', 'เกิน LCL', 'เกิน USL', 'เกิน LSL'],
                        onChanged: (values) {
                          setState(() {
                            selectedConditons = values; 
                          });
                        },
                      ),
                      
                      const SizedBox(height: 16),
                  
                      buildSectionTitle('ระยะเวลาการเปลี่ยนหน้าจอ (วินาที)'),
                      const SizedBox(height: 8),
                      // Product Selection
                      buildTextField(
                        value: selectedItem,
                        onChanged: (value) {
                          setState(() {
                            selectedItem = value;
                          });
                        },
                      ),
                  
                      const SizedBox(height: 48),
                      
                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle form submission
                            _submitForm();
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
  }



  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? startDate : endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  void _submitForm() {
    // Handle form submission logic here
    print('Form submitted with:');
    print('Start Date: $startDate');
    print('End Date: $endDate');
    print('Selected Item: $selectedItem');
    print('Test Type: $selectedConditons');
    print('Limit Value: $limitValue');
    print('Period Value: $periodValue');
    
    // You can add navigation, API calls, or other logic here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('บันทึกข้อมูลเรียบร้อยแล้ว'),
        backgroundColor: Colors.green,
      ),
    );
  }
}