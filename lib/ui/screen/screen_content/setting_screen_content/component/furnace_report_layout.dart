
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/ui/core/shared/small_control_chart/cde_cdt/help.dart';
import 'package:control_chart/ui/core/shared/small_control_chart/surface_hardness/help.dart';
import 'package:control_chart/ui/core/shared/table_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FurnaceReportLayout extends StatelessWidget {
  const FurnaceReportLayout({super.key});

  @override
  Widget build(BuildContext context) {
    // Single BlocBuilder at the top level to share state
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, smallSearchState) {
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
                        _buildDataSection(context, smallSearchState),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  // buildPagination(),
                  // const SizedBox(height: 16),
                  
                  // // Use shared searchState
                  // Text(
                  //   'Furnace No. ${smallSearchState.currentQuery.furnaceNo?.isNotEmpty == true ? smallSearchState.currentQuery.furnaceNo : '-'}, '
                  //   'Material No. ${smallSearchState.currentQuery.materialNo?.isNotEmpty == true ? smallSearchState.currentQuery.materialNo : '-'}',
                  //   style: AppTypography.textBody1BBold
                  // ),
                  
                  // const SizedBox(height: 16),

                  Flex(
                    direction: Axis.vertical,
                    children: [
                      Row(
                        children: [
                          Expanded(child: buildChartsSectionSurfaceHardnessSmallLikeMedium(smallSearchState)),
                          SizedBox(width: 16),
                          Expanded(child: buildChartsSectionCdeCdtSmall(smallSearchState)),
                        ],
                      ),
                    ],
                  ),

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
            Text('Error: ${searchState.errorMessage ?? 'เกิดข้อผิดผลาด'}'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                context.read<SearchBloc>().add(LoadFilteredChartData());
              },
              child: const Text('ลองอีกครั้ง'),
            ),
          ],
        ),
      );
    }
    
    return buildDataTable(searchState);
  }
  
  // buildChartsSectionSurfaceHardnessSmall(SearchState smallSearchState) {}
}