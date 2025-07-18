  import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';
import 'package:flutter/material.dart';

Widget buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.textBody2BBold
    );
  }

  Widget buildTextField({
    required String value,
    bool readOnly = false,
    Function(String)? onChanged,
  }) {
    return SizedBox(
      height: 42.0,
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

  Widget buildDropdownField({
    required String value,
    required List<String> items,
    required Function(String?) onChanged, required BuildContext context,
  }) {
    return SizedBox(
      height: 42.0,
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

  Widget buildMultiSelectField({
  required BuildContext context,
  required List<String> selectedValues,
  required List<String> items,
  required Function(List<String>) onChanged,
  String? hintText,
}) {
    return SizedBox(
      height: 42.0,
      child: InkWell(
        onTap: () async {
          List<String> tempSelected = List.from(selectedValues);
          
          await showDialog(
            context: context,
            builder: (context) => StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                title: const Text('เลือกเงื่อนไข'),
                content: 
                SizedBox(
                  width: 300.0,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return CheckboxListTile(
                        title: Text(item),
                        value: tempSelected.contains(item),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              tempSelected.add(item);
                            } else {
                              tempSelected.remove(item);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('ยกเลิก'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      onChanged(tempSelected);
                      Navigator.pop(context);
                    },
                    child: const Text('ยืนยัน'),
                  ),
                ],
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  selectedValues.isEmpty
                      ? (hintText ?? 'เลือกเงื่อนไข')
                      : selectedValues.length == 1
                          ? selectedValues.first
                          : selectedValues.toString(),
                  style: TextStyle(
                    color: selectedValues.isEmpty ? Colors.grey.shade600 : AppColors.colorBlack,
                    fontSize: 16,
                  ),
                ),
              ),
              const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDateField({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 42.0,
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
              color: AppColors.colorBlack,
            ),
          ),
        ),
      ),
    );
  }