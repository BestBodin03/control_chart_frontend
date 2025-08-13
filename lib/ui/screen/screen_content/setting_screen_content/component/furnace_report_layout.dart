
// import 'package:control_chart/apis/settings/setting_apis.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
// import 'package:control_chart/data/bloc/setting/setting_bloc.dart';
// import 'package:control_chart/data/cubit/setting_cubit.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';
import 'package:control_chart/ui/core/shared/table_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FurnaceReportLayout extends StatelessWidget {
  const FurnaceReportLayout({super.key});

  @override
  Widget build(BuildContext context) {
    // Single BlocBuilder at the top level to share state
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, searchState) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Header Table
                  DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black26),
                      borderRadius: const BorderRadius.all(Radius.circular(10))
                    ),
                    child: Column( 
                      children: [
                        buildHeaderTable(),
                        // Pass searchState to data table instead of nested BlocBuilder
                        _buildDataSection(context, searchState),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  // buildPagination(),
                  const SizedBox(height: 16),
                  
                  // Use shared searchState
                  Text(
                    'Furnace No. ${searchState.currentQuery.furnaceNo ?? 'N/A'}/ ${searchState.currentQuery.materialNo ?? 'N/A'} | QUERY PARAMS: ${searchState.currentQuery.toQueryParams().values}',
                    style: AppTypography.textBody1BBold
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Pass searchState to charts section - THIS IS THE KEY CHANGE
                  buildChartsSection(searchState), // Now passing searchState!
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Extract data section logic to separate method
  Widget _buildDataSection(BuildContext context, SearchState searchState) {
    if (searchState.status == SearchStatus.loading) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: CircularProgressIndicator(),
      );
    }
    
    if (searchState.status == SearchStatus.failure) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text('Error: ${searchState.errorMessage ?? 'Something went wrong'}'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                context.read<SearchBloc>().add(LoadFilteredChartData());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    return buildDataTable(searchState);
  }
}