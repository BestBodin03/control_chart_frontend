// import 'package:control_chart/ui/core/layout/app_bar.dart';
// import 'package:control_chart/ui/core/layout/main_menu.dart';
// import 'package:flutter/material.dart';

// class MainBody extends StatelessWidget {
//   MainBody({Key? key, required this.page}) : super(key: key);
//   Widget page;

//   @override
//   Widget build(BuildContext context) {

//     return Scaffold(
//       appBar: AppBar(title: const Text('AppBar without hamburger button')),
//       drawer: Drawer(
//                 child: ListView(
//                   padding: EdgeInsets.zero,
//                   children: [
//                     const DrawerHeader(
//                       decoration: BoxDecoration(color: Colors.blue),
//                       child: Text('Drawer Header'),
//                     ),
//                     ListTile(
//                       title: const Text('Item 1'),
//                       onTap: () {
//                       },
//                     ),
//                     ListTile(
//                       title: const Text('Item 2'),
//                       onTap: () {
//                       },
//                     ),
//                   ],
//                 ),
//               )
//     );
//   }
// }



                                          //     buildSectionTitle('ระยะเวลา'),
                                          //     Row(
                                          //       crossAxisAlignment: CrossAxisAlignment.end,
                                          //       children: [
                                          //         IconButton(
                                          //           icon: const Icon(Icons.add_circle_rounded, color: AppColors.colorBrand),
                                          //           iconSize: 24,
                                          //           onPressed: () async {
                                          //             final cubit = context.read<SettingFormCubit>();
                                          //             final newIndex = cubit.addSpecificSetting();     // ✅ ได้ index ใหม่แน่นอน
                                          //             await cubit.loadDropdownOptions(index: newIndex); // ✅ โหลดรายการของแถวนั้น
                                          //           }
                                          //         ),
                                          //         const SizedBox(width: 8),
                                          //         IconButton(
                                          //           icon: const Icon(Icons.remove_circle_outline_rounded, color: AppColors.colorAlert1),
                                          //           iconSize: 24,
                                          //           onPressed: state.specifics.isEmpty ? null : () => cubit.removeSpecificSetting(i),
                                          //         ),
                                          //       ],
                                          //     ),
                                          //   ],
                                          // ),

                                          // const SizedBox(height: 8),

                                          // // ===== ใน BlocBuilder<SettingFormCubit, SettingFormState> ด้านใน loop ของ specifics (มี index i) =====
                                          // buildDropdownField(
                                          //   key: ValueKey('period_$i'),
                                          //   context: context,
                                          //   value: _periodTypeToLabel(sp.periodType),
                                          //   items: const ['1 เดือน','3 เดือน','6 เดือน','1 ปี','ตลอดเวลา','กำหนดเอง'],
                                          //   onChanged: (value) {
                                          //     if (value == null) return;
                                          //     final now = DateTime.now();
                                          //     DateTime? startAuto;
                                          //     PeriodType period;

                                          //     switch (value) {
                                          //       case '1 เดือน': period = PeriodType.ONE_MONTH;   
                                          //         startAuto = DateTime(now.year, now.month - 1, now.day); break;
                                          //       case '3 เดือน': period = PeriodType.THREE_MONTHS; 
                                          //         startAuto = DateTime(now.year, now.month - 3, now.day); break;
                                          //       case '6 เดือน': period = PeriodType.SIX_MONTHS;   
                                          //         startAuto = DateTime(now.year, now.month - 6, now.day); break;
                                          //       case '1 ปี':    period = PeriodType.ONE_YEAR;     
                                          //         startAuto = DateTime(now.year - 1, now.month, now.day); break;
                                          //       case 'ตลอดเวลา': period = PeriodType.LIFETIME;    
                                          //         startAuto = DateTime(2024, 1, 1); break;
                                          //       default: period = PeriodType.CUSTOM;       
                                          //         startAuto = null;
                                          //     }

                                          //     cubit.updatePeriodType(i, period);
                                          //     if (period != PeriodType.CUSTOM) {
                                          //       cubit
                                          //         ..updateStartDate(i, startAuto!)
                                          //         ..updateEndDate(i, now);
                                          //     }

                                          //     cubit.loadDropdownOptions(index: i);
                                          //   },
                                          // ),


                                          //   const SizedBox(height: 16),

                                          //   // ------- Date pickers -------
                                          //   Row(
                                          //     children: [
                                          //       Expanded(
                                          //         child: buildDateField(
                                          //           key: ValueKey('start_$i'), // ✅
                                          //           context: context,
                                          //           value: sp.startDate,
                                          //           label: _dateLabel(sp.startDate) ?? 'Select Date',
                                          //           date: sp.startDate ?? DateTime.now(),
                                          //           onTap: () async {
                                          //             final picked = await showDatePicker(
                                          //               context: context,
                                          //               initialDate: sp.startDate ?? DateTime.now(),
                                          //               firstDate: DateTime(2020),
                                          //               lastDate: DateTime(2050),
                                          //             );
                                          //             if (picked == null) return;
                                          //             cubit.updateStartDate(i, picked, setCustom: true);
                                          //             cubit.loadDropdownOptions(index: i); // ✅
                                          //           },
                                          //         ),
                                          //       ),
                                          //       const SizedBox(width: 16),
                                          //       const Text('ถึง', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                          //       const SizedBox(width: 16),
                                          //       Expanded(
                                          //         child: buildDateField(
                                          //           key: ValueKey('end_$i'), // ✅
                                          //           context: context,
                                          //           value: sp.endDate,
                                          //           label: _dateLabel(sp.endDate) ?? 'Select Date',
                                          //           date: sp.endDate ?? DateTime.now(),
                                          //           onTap: () async {
                                          //             final picked = await showDatePicker(
                                          //               context: context,
                                          //               initialDate: sp.endDate ?? DateTime.now(),
                                          //               firstDate: DateTime(2020),
                                          //               lastDate: DateTime(2050),
                                          //             );
                                          //             if (picked == null) return;
                                          //             cubit
                                          //               ..updateEndDate(i, picked, setCustom: true)
                                          //               ..updatePeriodType(i, PeriodType.CUSTOM)
                                          //               ..loadDropdownOptions(index: i);
                                          //           },
                                          //         ),
                                          //       ),
                                          //     ],
                                          //   ),