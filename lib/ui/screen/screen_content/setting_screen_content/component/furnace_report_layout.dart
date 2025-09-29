import 'dart:math' as math;

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
    // Single top-level BlocBuilder provides the right SearchBloc state once
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, smallSearchState) {
        debugPrint(smallSearchState.currentQuery.startDate.toString());
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: CustomScrollView(
            slivers: [
              // --- Header table block ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black26),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Column(
                      children: [
                        buildHeaderTable(),
                        _buildDataSection(context, smallSearchState),
                      ],
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // --- Charts row fills remaining height (no magic numbers) ---
              SliverFillRemaining(
                hasScrollBody: false, // let child expand to fill
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch, // fill vertical space
                    children: [
                      Expanded(
                        child: SizedBox.expand( // panel fills available height
                          child: ClipRect(
                            // OPTIONAL: if inner content can be taller, allow inner scroll:
                            // child: SingleChildScrollView(child: buildChartsSectionSurfaceHardnessSmall(smallSearchState)),
                            child: buildChartsSectionSurfaceHardnessSmall(smallSearchState),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox.expand(
                          child: ClipRect(
                            // child: buildChartsSectionSurfaceHardnessSmall(smallSearchState),
                            // OPTIONAL: inner scroll if needed
                            // child: SingleChildScrollView(child: buildChartsSectionCdeCdtSmall(smallSearchState)),
                            child: buildChartsSectionCdeCdtSmall(smallSearchState),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Extract data section logic to a method (still using the same SearchBloc)
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
            Text('Error: ${searchState.errorMessage ?? 'เกิดข้อผิดพลาด'}'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                // Fire the event on the SAME SearchBloc above
                context.read<SearchBloc>().add(LoadFilteredChartData());
              },
              child: const Text('Try again!'),
            ),
          ],
        ),
      );
    }

    // Success or initial -> render the data table with the provided state
    return buildDataTable(searchState);
  }
}
