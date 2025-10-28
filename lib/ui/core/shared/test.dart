// import 'package:control_chart/apis/settings/setting_apis.dart';
// import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
// import 'package:control_chart/data/bloc/setting/setting_bloc.dart';
// import 'package:control_chart/data/cubit/setting_form/setting_form_cubit.dart';
// import 'package:control_chart/data/cubit/setting_form/setting_form_state.dart';
// import 'package:control_chart/domain/models/customer_product.dart';
// import 'package:control_chart/domain/models/furnace.dart';
// import 'package:control_chart/domain/models/setting.dart';
// import 'package:control_chart/ui/core/design_system/app_color.dart';
// import 'package:control_chart/ui/core/design_system/app_typography.dart';
// import 'package:control_chart/ui/core/shared/form_component.dart';
// import 'package:control_chart/ui/core/shared/gradient_background.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:intl/intl.dart';

// class SettingForm extends StatefulWidget {
//   const SettingForm({super.key});

//   @override
//   State<SettingForm> createState() => _SettingFormState();
// }

// class _SettingFormState extends State<SettingForm> {
//   late final SettingBloc _settingBloc;
//   static const _periodItems = ['1 เดือน', '3 เดือน', '6 เดือน', '1 ปี', 'ตลอดเวลา', 'กำหนดเอง'];
//   String selectedDisplayType = '';
//   final double backgroundOpacity = 0.2;

//   @override
//   void initState() {
//     super.initState();
//     _settingBloc = SettingBloc(settingApis: SettingApis())..add(InitializeForm());
//   }

//   @override
//   void dispose() {
//     _settingBloc.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider.value(
//       value: _settingBloc,
//       child: MultiBlocListener(
//         listeners: [
//           // Notifications
//           BlocListener<SettingBloc, SettingState>(
//             listener: (context, state) {
//               if (state.isSaved) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('บันทึกข้อมูลเรียบร้อยแล้ว'), backgroundColor: Colors.green),
//                 );
//               }
//             },
//           ),
//           // Bridge SettingBloc dates -> SearchBloc
//           BlocListener<SettingBloc, SettingState>(
//             listenWhen: (prev, curr) =>
//                 prev.formState.startDate != curr.formState.startDate ||
//                 prev.formState.endDate != curr.formState.endDate,
//             listener: (context, state) {
//               final start = _toDateTime(state.formState.startDate);
//               final end   = _toDateTime(state.formState.endDate);
//               if (start == null || end == null) return;

//               final search = context.read<SearchBloc>().state.currentQuery;
//               context.read<SearchBloc>().add(LoadFilteredChartData(
//                 startDate: start,
//                 endDate: end,
//                 furnaceNo: search.furnaceNo,
//                 materialNo: search.materialNo,
//               ));
//             },
//           ),
//         ],
//         child: BlocBuilder<SettingBloc, SettingState>(
//           builder: (context, state) {
//             if (state.status == SettingStatus.loading) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             if (state.status == SettingStatus.error) {
//               return Center(child: Text('Error: ${'เกิดข้อผิดผลาด'}'));
//             }

//             final form = state.formState;
//             final furnaces = state.furnaces;
//             final matNumbers = state.matNumbers;
//             return SingleChildScrollView(
//               child: SizedBox(
//                       width: 332,
//                       child: DecoratedBox(
//                         decoration: BoxDecoration(
//                           color: AppColors.colorBgGrey,
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.all(16),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: <Widget>[
          
//                               buildSectionTitle('ชื่อโปรไฟล์ตั้งค่า'),
                
//                               const SizedBox(height: 8),
                
//                               buildTextField(
//                                 value: '',
//                                 hintText: 'ชื่อ'
//                               ),
                
//                               const SizedBox(height: 16),
                
//                               buildSectionTitle('การแสดงผล'),

//                               const SizedBox(height: 8),
                              
//                               buildChoiceTabs(
//                                 selectedValue: selectedDisplayType,
//                                 itemsLabel: ['เตา', 'เตา/เลขแมต', 'เลขแมต'],
//                                 itemsValue: ['FURNACE','FURNACE_CP','CP'],
//                                 onChanged: (v) => setState(() => selectedDisplayType = v),
//                                 // activeColor: AppColors.colorBrand,
//                                 // containerBg: AppColors.colorBrand
//                               ),
                
//                               const SizedBox(height: 16),
                
                
//                               buildSectionTitle('กฎแผนภูมิควบคุม'),
//                               const SizedBox(height: 8),
//                               buildMultiSelectField(
//                                 context: context,
//                                 hintText: 'เลือกกฎ',
//                                 selectedValues: form.selectedConditions,
//                                 items: const ['Rule1: Beyond Limit', 'Rule3: Trend'],
//                                 onChanged: (values) {
//                                   // context.read<SettingBloc>().add(UpdateSelectedConditions(values));
//                                 },
//                               ),
                
//                               const SizedBox(height: 16),
                
//                               buildSectionTitle('ระยะเวลาเปลี่ยนหน้าจอ'),
                
//                               const SizedBox(height: 8),
                
//                               buildTextField(
//                                 value: '',
//                                 hintText: 'ระยะเวลา (วินาที)'
//                               ),
                
//                               const SizedBox(height: 16),
//                             BlocBuilder<SettingFormCubit, SettingFormState>(
//                               builder: (context, state) {
//                                 final cubit = context.read<SettingFormCubit>();

//                                 String fmt(DateTime? d) {
//                                   if (d == null) return 'Pick date';
//                                   return '${d.year.toString().padLeft(4, '0')}-'
//                                         '${d.month.toString().padLeft(2, '0')}-'
//                                         '${d.day.toString().padLeft(2, '0')}';
//                                 }

//                                 Future<void> pickStart(int index, DateTime? current) async {
//                                   final now = DateTime.now();
//                                   final picked = await showDatePicker(
//                                     context: context,
//                                     initialDate: current ?? now,
//                                     firstDate: DateTime(2000),
//                                     lastDate: DateTime(2100),
//                                   );
//                                   if (picked != null) cubit.updateStartDate(index, picked);
//                                 }

//                                 Future<void> pickEnd(int index, DateTime? current, DateTime? start) async {
//                                   final now = DateTime.now();
//                                   final picked = await showDatePicker(
//                                     context: context,
//                                     initialDate: current ?? (start ?? now),
//                                     firstDate: DateTime(2000),
//                                     lastDate: DateTime(2100),
//                                   );
//                                   if (picked != null) cubit.updateEndDate(index, picked);
//                                 }

//                                 return Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     // Header + add/remove
//                                     Row(
//                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Text('ระยะเวลา', style: Theme.of(context).textTheme.titleMedium),
//                                         Row(
//                                           children: [
//                                             IconButton(
//                                               icon: const Icon(Icons.add_circle_rounded),
//                                               onPressed: cubit.addSpecificSetting,
//                                             ),
//                                             IconButton(
//                                               icon: const Icon(Icons.remove_circle_outline_rounded),
//                                               onPressed: state.specifics.isEmpty
//                                                   ? null
//                                                   : () => cubit.removeSpecificSetting(state.specifics.length - 1),
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                     const SizedBox(height: 12),

//                                     // Repeatable blocks (Period + Furnace No + Mat No)
//                                     ...List.generate(state.specifics.length, (i) {
//                                       final sp = state.specifics[i];
//                                       return Card(
//                                         key: ValueKey('spec-$i'),
//                                         elevation: 0.5,
//                                         margin: const EdgeInsets.only(bottom: 12),
//                                         child: Padding(
//                                           padding: const EdgeInsets.all(12),
//                                           child: Column(
//                                             crossAxisAlignment: CrossAxisAlignment.start,
//                                             children: [
//                                               // block header + per-item remove
//                                               Row(
//                                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                                 children: [
//                                                   Text('Block ${i + 1}',
//                                                       style: Theme.of(context).textTheme.titleSmall),
//                                                   IconButton(
//                                                     icon: const Icon(Icons.close_rounded),
//                                                     tooltip: 'Remove this block',
//                                                     onPressed: () => cubit.removeSpecificSetting(i),
//                                                   ),
//                                                 ],
//                                               ),
//                                               const SizedBox(height: 8),

//                                               // Period row (type + start + end)
//                                               Row(
//                                                 children: [
//                                                   Expanded(
//                                                     flex: 2,
//                                                     child: DropdownButtonFormField<PeriodTypeReq>(
//                                                       key: ValueKey('periodType-$i-${sp.periodType}'),
//                                                       value: sp.periodType,
//                                                       decoration: const InputDecoration(
//                                                         labelText: 'Type',
//                                                         border: OutlineInputBorder(),
//                                                       ),
//                                                       items: PeriodTypeReq.values
//                                                           .map((e) => DropdownMenuItem(
//                                                                 value: e,
//                                                                 child: Text(e.name),
//                                                               ))
//                                                           .toList(),
//                                                       onChanged: (val) {
//                                                         if (val != null) cubit.updatePeriodType(i, val);
//                                                       },
//                                                     ),
//                                                   ),
//                                                   const SizedBox(width: 8),
//                                                   Expanded(
//                                                     flex: 2,
//                                                     child: OutlinedButton(
//                                                       key: ValueKey('start-$i-${sp.startDate?.millisecondsSinceEpoch}'),
//                                                       onPressed: () => pickStart(i, sp.startDate),
//                                                       child: Align(
//                                                         alignment: Alignment.centerLeft,
//                                                         child: Text('Start: ${fmt(sp.startDate)}'),
//                                                       ),
//                                                     ),
//                                                   ),
//                                                   const SizedBox(width: 8),
//                                                   Expanded
//                                                   (
//                                                     flex: 2,
//                                                     child: OutlinedButton(
//                                                       key: ValueKey('end-$i-${sp.endDate?.millisecondsSinceEpoch}'),
//                                                       onPressed: () => pickEnd(i, sp.endDate, sp.startDate),
//                                                       child: Align(
//                                                         alignment: Alignment.centerLeft,
//                                                         child: Text('End: ${fmt(sp.endDate)}'),
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),

//                                               const SizedBox(height: 12),

//                                               // Furnace No
//                                               TextFormField(
//                                                 key: ValueKey('furnace-$i-${sp.furnaceNo}'),
//                                                 initialValue: sp.furnaceNo?.toString() ?? '',
//                                                 decoration: const InputDecoration(
//                                                   labelText: 'Furnace No',
//                                                   border: OutlineInputBorder(),
//                                                 ),
//                                                 keyboardType: TextInputType.number,
//                                                 onChanged: (v) =>
//                                                     cubit.updateFurnaceNo(i, int.tryParse(v) ?? 0),
//                                               ),

//                                               const SizedBox(height: 12),

//                                               // Mat No (uses cpNo field in your model)
//                                               TextFormField(
//                                                 key: ValueKey('mat-$i-${sp.cpNo}'),
//                                                 initialValue: sp.cpNo ?? '',
//                                                 decoration: const InputDecoration(
//                                                   labelText: 'Mat No',
//                                                   hintText: 'e.g. MAT-001',
//                                                   border: OutlineInputBorder(),
//                                                 ),
//                                                 onChanged: (v) => cubit.updateCpNo(i, v),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       );
//                                     }),
//                                   ],
//                                 );
//                               },
//                             ),


//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//               );
//           },
//         ),
//       ),
//     );
//   }

//   // ============== Helpers ==============

//   // แปลง dynamic -> DateTime?
//   static DateTime? _toDateTime(dynamic v) {
//     if (v == null) return null;
//     if (v is DateTime) return v;
//     if (v is String)  return DateTime.tryParse(v);
//     return null;
//   }

//   static String? _dateLabel(DateTime? d) => d == null ? null : DateFormat('MM/dd/yy').format(d);

//   void _dispatchSearchWith(
//     BuildContext context, {
//     required dynamic start,
//     required dynamic end,
//     String? furnace,
//     String? material,
//   }) {
//     final startDT = start is DateTime ? start : _toDateTime(start);
//     final endDT   = end   is DateTime ? end   : _toDateTime(end);
//     if (startDT == null || endDT == null) return;

//     final q = context.read<SearchBloc>().state.currentQuery;
//     context.read<SearchBloc>().add(LoadFilteredChartData(
//       startDate: startDT,
//       endDate: endDT,
//       furnaceNo: furnace ?? q.furnaceNo,
//       materialNo: material ?? q.materialNo,
//     ));
//   }

//   // Update by period (เดิม)
//   void _updateDateRangeByPeriod(BuildContext context, String period) {
//     final now = DateTime.now();
//     DateTime startDate;
//     switch (period) {
//       case '1 เดือน':   startDate = DateTime(now.year, now.month - 1, now.day); break;
//       case '3 เดือน':   startDate = DateTime(now.year, now.month - 3, now.day); break;
//       case '6 เดือน':   startDate = DateTime(now.year, now.month - 6, now.day); break;
//       case '1 ปี':      startDate = DateTime(now.year - 1, now.month, now.day); break;
//       case 'ตลอดเวลา':  startDate = DateTime(2020, 1, 1); break;
//       default: // 'กำหนดเอง'
//         return; // ไม่ auto-update
//     }
//     context.read<SettingBloc>()
//       ..add(UpdateStartDate(startDate: startDate))
//       ..add(UpdateEndDate(endDate: now));
//     // SearchBloc จะถูกอัปเดตผ่าน BlocListener อยู่แล้ว
//   }

//   List<String> _getFurnaceNumbers(List<Furnace> furnaces) {
//     final sorted = (furnaces.map((f) => f.furnaceNo).toList()..sort());
//     return ["0", ...sorted.map((n) => n.toString())];
//   }

//   List<String> _getMatNumbers(List<CustomerProduct> mats) {
//     final sorted = (mats.map((m) => m.cpNo).toList()..sort());
//     return ["เลือกเลขแมต", ...sorted.map((n) => n.toString())];
//   }


//   Future<void> _selectDate(BuildContext context, bool isStartDate) async {
//     final settingState = _settingBloc.state;
//     final searchState = context.read<SearchBloc>().state;

//     final initial = isStartDate
//         ? (searchState.currentQuery.startDate ?? _toDateTime(settingState.formState.startDate) ?? DateTime.now())
//         : (searchState.currentQuery.endDate   ?? _toDateTime(settingState.formState.endDate)   ?? DateTime.now());

//     final picked = await showDatePicker(
//       context: context,
//       initialDate: initial,
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2050),
//     );

//     if (picked == null) return;

//     // Rule 1: เมื่อผู้ใช้เลือกวันเอง -> บังคับ period = "กำหนดเอง" + อัปเดตทั้งสอง Bloc
//     final q = searchState.currentQuery;
//     final newStart = isStartDate ? picked : (q.startDate ?? picked);
//     final newEnd   = isStartDate ? (q.endDate ?? picked) : picked;

//     context.read<SettingBloc>().add(UpdatePeriodS('กำหนดเอง'));
//     context.read<SettingBloc>()
//       ..add(UpdateStartDate(startDate: newStart))
//       ..add(UpdateEndDate(endDate: newEnd));

//     context.read<SearchBloc>().add(LoadFilteredChartData(
//       startDate: newStart,
//       endDate: newEnd,
//       furnaceNo: q.furnaceNo,
//       materialNo: q.materialNo,
//     ));
//   }
// }
