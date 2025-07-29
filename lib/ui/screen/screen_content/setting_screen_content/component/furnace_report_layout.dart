
// import 'package:control_chart/apis/settings/setting_apis.dart';
// import 'package:control_chart/data/cubit/setting_cubit.dart';
// import 'package:control_chart/data/cubit/setting_cubit_state.dart';
// import 'package:control_chart/ui/core/design_system/app_color.dart';
// import 'package:control_chart/ui/core/design_system/app_typography.dart';
// import 'package:control_chart/ui/core/shared/gradient_background.dart';
// import 'package:control_chart/ui/core/shared/table_component.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class FurnaceReportLayout extends StatelessWidget {
//   const FurnaceReportLayout({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => SettingCubit(
//         context.read<SettingApis>()
//       )..
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Center(
//           child: SingleChildScrollView(
//             child: SizedBox(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   // Header Table
//                   DecoratedBox(
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.black26),
//                       borderRadius: BorderRadius.all(Radius.circular(10))
//                     ),
//                     child: Column( 
//                       children: [
//                         buildHeaderTable(),
//                         BlocBuilder<SettingCubit, SettingCubitState>(
//                           builder: (context, state) {
//                             if (state is SettingCubitLoading) {
//                               return Padding(
//                                 padding: const EdgeInsets.all(20.0),
//                                 child: CircularProgressIndicator(),
//                               );
//                             }
                            
//                             if (state is SettingCubitError) {
//                               return Padding(
//                                 padding: const EdgeInsets.all(20.0),
//                                 child: Column(
//                                   children: [
//                                     Text('Error: ${state.message}'),
//                                     SizedBox(height: 8),
//                                     ElevatedButton(
//                                       onPressed: () {
//                                         context.read<SettingCubit>()
//                                             .loadChartDetailCount();
//                                       },
//                                       child: Text('Retry'),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             }
                            
//                             if (state is SettingCubitLoaded) {
//                               return buildDataTable(state.count);
//                             }
                            
//                             return buildDataTable(0); // fallback
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
                  
//                   SizedBox(height: 16),
//                   buildPagination(),
//                   SizedBox(height: 16),
                  
//                   Text(
//                     'Furnace No. 8/ 240098B34',
//                     style: AppTypography.textBody1BBold
//                   ),
                  
//                   SizedBox(height: 16),
//                   buildChartsSection(),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }