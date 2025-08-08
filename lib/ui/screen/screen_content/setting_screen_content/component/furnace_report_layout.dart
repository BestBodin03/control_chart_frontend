
import 'package:control_chart/apis/settings/setting_apis.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/data/bloc/setting/setting_bloc.dart';
import 'package:control_chart/data/cubit/setting_cubit.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';
import 'package:control_chart/ui/core/shared/table_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FurnaceReportLayout extends StatelessWidget {
  const FurnaceReportLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, searchState) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: SingleChildScrollView(
              child: SizedBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Header Table
                    DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black26),
                        borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                      child: Column( 
                        children: [
                          buildHeaderTable(),
                          BlocBuilder<SearchBloc, SearchState>(
                            builder: (context, searchState) {
                              if (searchState.isLoading) {
                                return Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: CircularProgressIndicator(),
                                );
                              }
                              
                              if (searchState.hasError) {
                                return Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    children: [
                                      Text('Error: ${searchState.errorMessage ?? 'Something went wrong'}'),
                                      SizedBox(height: 8),
                                      ElevatedButton(
                                        onPressed: () {
                                          context.read<SearchBloc>().add(LoadFilteredChartData());
                                        },
                                        child: Text('Retry'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              
                              if (searchState.chartDetails.isNotEmpty) {
                                return buildDataTable(searchState); // ส่ง searchState ทั้งหมด
                              }
                              
                              return buildDataTable(searchState); // fallback with empty state
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    // buildPagination(),
                    SizedBox(height: 16),
                    
                    // ใช้ข้อมูลจาก SearchBloc
                    Text(
                      'Furnace No. ${searchState.currentQuery.furnaceNo ?? 'N/A'}/ ${searchState.currentQuery.materialNo ?? 'N/A'}',
                      style: AppTypography.textBody1BBold
                    ),
                    
                    SizedBox(height: 16),
                    buildChartsSection(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}