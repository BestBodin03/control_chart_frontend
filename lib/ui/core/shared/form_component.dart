import 'package:control_chart/domain/models/choice_item.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';
import 'package:flutter/material.dart';

Widget buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.textBody2BBold
    );
  }

Widget buildChoiceTabs({
  required String selectedValue,
  required List<String> itemsLabel,
  required List<String> itemsValue,
  ValueChanged<String>? onChanged,
  bool disabled = false, // 👈 เพิ่มพารามิเตอร์นี้
  double height = 42,
  double gap = 8,
  BorderRadius borderRadius = const BorderRadius.all(Radius.circular(10)),
  Color activeColor = AppColors.colorBrand,
  Color inactiveBg = Colors.white,
  Color inactiveBorder = const Color(0xFFD1D5DB),
  Color containerBg = const Color(0xFFF3F4F6),
}) {
  assert(itemsLabel.length == itemsValue.length,
      "itemsLabel and itemsValue must have the same length");

  return LayoutBuilder(
    builder: (context, constraints) {
      final buttonWidth =
          (constraints.maxWidth - (gap * (itemsLabel.length - 1))) /
              itemsLabel.length;

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(itemsLabel.length, (i) {
          final label = itemsLabel[i];
          final value = itemsValue[i];
          final active = value == selectedValue;

          return SizedBox(
            width: buttonWidth,
            height: height,
            child: TextButton(
              onPressed: disabled ? null : () => onChanged?.call(value), // 👈 ปิดการคลิกเมื่อ disabled
              style: ButtonStyle(
                // พื้นหลัง: ถ้า active ให้เป็น activeColor เสมอ แม้ disabled
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (active) return activeColor;
                  if (states.contains(WidgetState.disabled)) return Colors.grey.shade300;
                }),
                // สีตัวอักษร: active เป็นขาว, disabled ที่ไม่ active ให้จางลง
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  if (active) return Colors.white;
                  if (states.contains(WidgetState.disabled)) return Colors.black38;
                  return Colors.black87;
                }),
                // เส้นขอบ: active = activeColor, ถ้า disabled และไม่ active → ขอบจาง
                side: WidgetStateProperty.resolveWith((states) {
                  if (active) return BorderSide(color: activeColor);
                  final base = states.contains(WidgetState.disabled)
                      ? inactiveBorder.withValues(alpha: 0.5)
                      : inactiveBorder;
                  return BorderSide(color: base);
                }),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(borderRadius: borderRadius),
                ),
                overlayColor: WidgetStateProperty.resolveWith((states) {
                  if (disabled) return Colors.transparent;
                  return AppColors.colorBrandTp.withValues(alpha: 0.5);
                }),
              ),
              child: Text(label, style: const TextStyle(fontSize: 14)),
            ),
          );
        }),
      );
    },
  );
}


Widget buildTextField({
  Key? key,
  required String value,
  String? hintText,
  bool readOnly = false,
  Function(String)? onChanged,
}) {
  return SizedBox(
    height: 42.0,
    child: TextFormField(
      initialValue: value,   // 👈 ใช้ initialValue แทน controller
      readOnly: readOnly,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintStyle: TextStyle(color: Colors.grey.shade600),
        hintText: hintText,
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
          borderSide: const BorderSide(color: AppColors.colorBrandTp),
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
    ValueKey? key,
    String? value, // เปลี่ยนเป็น nullable
    required List<String> items,
    required Function(String?) onChanged,
    required BuildContext context,
    String? hint, // เพิ่ม hint parameter
    String? label, // เพิ่ม label parameter
  }) {
    return SizedBox(
      height: 42.0,
      child: DropdownButtonFormField<String>(
        value: (value != null && items.contains(value)) ? value : null, // ตรวจสอบว่า value อยู่ใน items
        hint: hint != null ? Text(hint) : null, // แสดง hint เมื่อไม่มีค่าเลือก
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item == "0" ? "เลือกเตา" : item),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label, // เพิ่ม label
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
            borderSide: const BorderSide(color: AppColors.colorBrandTp),
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
        dropdownColor: AppColors.colorBg,
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
                title: const Text('เลือกกฎ'),
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
    ValueKey? key,
    required String label,
    required DateTime date,
    required VoidCallback onTap,
    Function(DateTime?)? onChanged,
    DateTime? value,
    required BuildContext context,
    
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
              fontSize: 12,
              color: AppColors.colorBlack,
            ),
          ),
        ),
      ),
    );
  }