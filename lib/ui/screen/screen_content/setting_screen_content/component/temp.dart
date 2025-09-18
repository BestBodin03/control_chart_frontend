import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/shared/pill_button.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/setting_content.dart';
import 'package:flutter/material.dart';

class SearchBox extends StatelessWidget {
  const SearchBox({super.key, required this.value, required this.onChanged, required this.hintText});

  final String value;
  final ValueChanged<String> onChanged;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                const Icon(Icons.search, size: 16, color: Color(0xFF64748B)),
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: value)
                      ..selection = TextSelection.collapsed(offset: value.length),
                    onChanged: onChanged,
                    decoration: InputDecoration(
                      hintText: hintText,
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// class SelectBox<T> extends StatelessWidget {
//   const SelectBox({super.key, 
//     required this.value,
//     required this.items,
//     required this.onChanged,
//   });

//   final T value;
//   final Map<T, String> items;
//   final ValueChanged<T?> onChanged;

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: 190,
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: DecoratedBox(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             border: Border.all(color: const Color(0xFFE2E8F0)),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 10),
//             child: DropdownButton<T>(
//               isExpanded: true,
//               value: value,
//               underline: const SizedBox.shrink(),
//               icon: const Icon(Icons.expand_more),
//               items: items.entries
//                   .map(
//                     (e) => DropdownMenuItem<T>(
//                       value: e.key,
//                       child: Text(
//                         e.value,
//                         style: Theme.of(context).textTheme.labelMedium,
//                       ),
//                     ),
//                   )
//                   .toList(),
//               onChanged: onChanged,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class EmptyState extends StatelessWidget {
//   const EmptyState({super.key, 
//     required this.title,
//     required this.description,
//     this.extra,
//   });

//   final String title;
//   final String description;
//   final String? extra;

//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: Alignment.topCenter,
//       child: SizedBox(
//         width: 560,
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(16),
//           child: DecoratedBox(
//             decoration: BoxDecoration(
//               color: Colors.white.withValues(alpha: 0.8),
//               border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid),
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.auto_awesome, size: 36, color: Colors.grey.shade500),
//                   const SizedBox(height: 10),
//                   Text(
//                     title,
//                     style: Theme.of(context)
//                         .textTheme
//                         .titleSmall
//                         ?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 6),
//                   Text(
//                     description,
//                     style: Theme.of(context)
//                         .textTheme
//                         .bodySmall
//                         ?.copyWith(color: const Color(0xFF475569)),
//                     textAlign: TextAlign.center,
//                   ),
//                   if (extra != null) ...[
//                     const SizedBox(height: 8),
//                     Text(
//                       extra!,
//                       style: Theme.of(context)
//                           .textTheme
//                           .labelSmall
//                           ?.copyWith(color: const Color(0xFF94A3B8)),
//                     ),
//                   ]
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

class CardBox extends StatelessWidget {
  const CardBox({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(12),
          child: child,
        ),
      ),
    );
  }
}

class RowIconTitle extends StatelessWidget {
  const RowIconTitle({super.key, required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF0F172A)),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
        ),
      ],
    );
  }
}

class OutlineButton extends StatelessWidget {
  const OutlineButton({super.key, required this.label, required this.onTap, this.icon});

  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: const Color(0xFF334155)),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(color: const Color(0xFF334155)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LabeledDropdown extends StatelessWidget {
  const LabeledDropdown({super.key, 
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: DropdownButton<String>(
                isExpanded: true,
                value: value,
                hint: const Text('— เลือกค่า —'),
                underline: const SizedBox.shrink(),
                icon: const Icon(Icons.expand_more),
                items: items
                    .map(
                      (e) => DropdownMenuItem<String>(
                        value: e,
                        child: Text(
                          e,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class PreviewTable extends StatelessWidget {
  const PreviewTable({super.key, required this.rows, required this.cols});

  final int rows;
  final int cols;

  @override
  Widget build(BuildContext context) {
    // header
    final header = TableRow(
      decoration: const BoxDecoration(color: Color(0xFFF1F5F9)),
      children: List.generate(
        cols,
        (i) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Text(
            'คอลัมน์ ${i + 1}',
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
          ),
        ),
      ),
    );

    final bodyRows = List.generate(rows, (r) {
      return TableRow(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: const Color(0xFFF1F5F9), width: r == 0 ? 1 : .6),
          ),
        ),
        children: List.generate(
          cols,
          (c) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Text(
              'ตัวอย่างข้อมูล ${r + 1}-${c + 1}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: const Color(0xFF334155)),
            ),
          ),
        ),
      );
    });

    return Table(
      columnWidths: const {},
      border: const TableBorder.symmetric(inside: BorderSide.none, outside: BorderSide.none),
      children: [header, ...bodyRows],
    );
  }
}

// ----------------------------------------------------
// Helpers
// ----------------------------------------------------

// String fmtDate(DateTime? d) {
//   final dd = d?.day.toString().padLeft(2, '0');
//   final mm = d?.month.toString().padLeft(2, '0');
//   final yy = d?.year.toString();
//   // return '$dd/$mm/$yy';
//   return '$dd/$mm';
// }
