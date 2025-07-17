import 'package:control_chart/ui/core/layout/gradient_background.dart';
import 'package:flutter/material.dart';

class DataFormPage extends StatefulWidget {
  const DataFormPage({super.key});

  @override
  State<DataFormPage> createState() => _DataFormPageState();
}

class _DataFormPageState extends State<DataFormPage> {
  DateTime startDate = DateTime(2024, 12, 30);
  DateTime endDate = DateTime(2024, 2, 24);
  String selectedItem = '1';
  String selectedTestType = 'เก็บ ULC, USL, LCL และ LSL';
  String limitValue = '9';
  String daysValue = '30 วัน';

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(32.0, 16.0, 32.0, 32.0),
      child: SizedBox(
        width: 360,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('ระยะเวลา'),
              const SizedBox(height: 8),
               Row(
                children: [
                  Expanded(
                    child: _buildDateField(
                      label: '30/12/2024',
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
                    child: _buildDateField(
                      label: '24/2/2024',
                      date: endDate,
                      onTap: () => _selectDate(context, false),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Item Selection
              _buildSectionTitle('หมายเลขเตา'),
              const SizedBox(height: 8),
              // Product Selection
              _buildDropdownField(
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
              _buildSectionTitle('Material No.'),
              const SizedBox(height: 8),
              _buildDropdownField(
                value: daysValue,
                items: ['30 วัน', '7 วัน', '15 วัน', '60 วัน', '90 วัน'],
                onChanged: (value) {
                  setState(() {
                    daysValue = value!;
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              // Test Type Selection
              _buildSectionTitle('การแจ้งเตือน'),
              const SizedBox(height: 8),
              _buildDropdownField(
                value: selectedTestType,
                items: [
                  'เก็บ ULC, USL, LCL และ LSL',
                  'เก็บ ULC และ USL',
                  'เก็บ LCL และ LSL',
                  'เก็บทั้งหมด'
                ],
                onChanged: (value) {
                  setState(() {
                    selectedTestType = value!;
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle form submission
                    _submitForm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D3748),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'บันทึก',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
    )
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required String value,
    bool readOnly = false,
    Function(String)? onChanged,
  }) {
    return SizedBox(
      height: 50,
      child: TextField(
        controller: TextEditingController(text: value),
        readOnly: readOnly,
        onChanged: onChanged,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blue),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return SizedBox(
      height: 50,
      child: DropdownButtonFormField<String>(
        value: value,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blue),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        icon: const Icon(
          Icons.keyboard_arrow_down,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 50,
      child: InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            suffixIcon: const Icon(
              Icons.calendar_today,
              color: Colors.grey,
              size: 20,
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
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
    print('Test Type: $selectedTestType');
    print('Limit Value: $limitValue');
    print('Days Value: $daysValue');
    
    // You can add navigation, API calls, or other logic here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('บันทึกข้อมูลเรียบร้อยแล้ว'),
        backgroundColor: Colors.green,
      ),
    );
  }
}