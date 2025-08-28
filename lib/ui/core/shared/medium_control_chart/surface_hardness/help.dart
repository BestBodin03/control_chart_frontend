import 'package:control_chart/data/bloc/search_chart_details/extension/search_state_extension.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';
import 'package:control_chart/ui/core/shared/medium_control_chart/surface_hardness/control_chart_template.dart';
import 'package:flutter/material.dart';

Widget buildChartsSectionSurfaceHardness(SearchState searchState) {
  return Row(
    children: [
      Expanded(
        child: _buildChartContainer(
          title: 'Surface Hardness',
          searchState: searchState,
          // chartType: ChartType.cdeCdt,
        ),
      ),
    ],
  );
}

// Add enum for chart types
// enum ChartType { surfaceHardness, cdeCdt }

Widget _buildChartContainer({
  required String title,
  required SearchState searchState,
  // required ChartType chartType,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(0,0,0,8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: AppTypography.textBody2BBold),
          ],
        ),
      ),
      // Outer bordered card
      SizedBox(
        child: DecoratedBox(
          decoration: BoxDecoration(
              color: AppColors.colorBrandTp.withValues(alpha: 0.15), // pale blue tint
              border: Border.all(color: AppColors.colorBrandTp.withValues(alpha: 0.35), width: 1),
              borderRadius: BorderRadius.circular(8.0),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Chart type label
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    "Individual", 
                    style: AppTypography.textBody3BBold,
                    textAlign: TextAlign.center,
                  ),
                ),

                // Individual Chart container
                _buildSingleChart(
                  searchState: searchState,
                  // chartType: chartType,
                  isMovingRange: false,
                ),

                // Chart type label
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    "Moving Range", 
                    style: AppTypography.textBody3BBold,
                    textAlign: TextAlign.center,
                  ),
                ),

                // Moving Range Chart container
                _buildMrChart(
                  searchState: searchState,
                  // chartType: chartType,
                  isMovingRange: true,
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

Widget _buildSingleChart({
  required SearchState searchState,
  // required ChartType chartType,
  required bool isMovingRange,
}) {
  return SizedBox(
    width: double.infinity,
    // width: 100.0,
    // height: 180,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.grey.shade50, // Changed from black26 to light background
        borderRadius: BorderRadius.circular(8),
      ),
      child: _buildChartContent(
        searchState: searchState,
        // chartType: chartType,
        isMovingRange: isMovingRange,
      ),
    ),
  );
}

Widget _buildMrChart({
  required SearchState searchState,
  // required ChartType chartType,
  required bool isMovingRange,
}) {
  return SizedBox(
    width: double.infinity,
    // width: 100.0,
    // height: 144.0,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.grey.shade50, // Changed from black26 to light background
        borderRadius: BorderRadius.circular(8),
      ),
      child: _buildMrChartContent(
        searchState: searchState,
        // chartType: chartType,
        isMovingRange: true,
      ),
    ),
  );
}

Widget _buildChartContent({
  required SearchState searchState,
  // required ChartType chartType,
  required bool isMovingRange,
}) {
  // Handle loading state
  if (searchState.status == SearchStatus.loading) {
    return const Center(
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
  
  // Handle error state
  if (searchState.status == SearchStatus.failure) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 16, color: Colors.red),
          SizedBox(height: 4),
          Text(
            'จำนวนข้อมูลไม่เพียงพอ',
            style: TextStyle(fontSize: 10, color: Colors.red),
          ),
        ],
      ),
    );
  }
  
  // Handle empty data
  if (searchState.controlChartStats == null || searchState.chartDetails.isEmpty) {
    return Center(
      child: Text(
        'No Data',
        style: TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }

  // Generate unique key for chart
  final query = searchState.currentQuery;
  final uniqueKey = '${query.startDate?.day}-'
      '${query.endDate?.millisecondsSinceEpoch}-'
      '${query.furnaceNo}-'
      '${query.materialNo}-';
  final dataPoints = searchState.chartDataPoints;

  return ClipRRect(
    borderRadius: BorderRadius.circular(4),
    child: ControlChartTemplate(
      key: ValueKey(uniqueKey.hashCode.toString()),
      dataPoints: dataPoints,
      controlChartStats: searchState.controlChartStats!,
      dataLineColor: AppColors.colorBrand,
      width: double.infinity,
      // width: 100.0,
      // height: 144.0, 
      isMovingRange: false,
    ),
  );
}

Widget _buildMrChartContent({
  required SearchState searchState,
  // required ChartType chartType,
  required bool isMovingRange,
}) {
  // Handle loading state
  if (searchState.status == SearchStatus.loading) {
    return const Center(
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
  
  // Handle error state
  if (searchState.status == SearchStatus.failure) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 16, color: Colors.red),
          SizedBox(height: 4),
          Text(
            'จำนวนข้อมูลไม่เพียงพอ',
            style: TextStyle(fontSize: 10, color: Colors.red),
          ),
        ],
      ),
    );
  }
  
  // Handle empty data
  if (searchState.controlChartStats == null || searchState.chartDetails.isEmpty) {
    return Center(
      child: Text(
        'No Data',
        style: TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }

  // Generate unique key for chart
  final query = searchState.currentQuery;
  final uniqueKey = '${query.startDate?.day}-'
      '${query.endDate?.millisecondsSinceEpoch}-'
      '${query.furnaceNo}-'
      '${query.materialNo}-';
  final dataPoints = searchState.chartDataPoints;

  return ClipRRect(
    borderRadius: BorderRadius.circular(4),
    child: ControlChartTemplate(
      key: ValueKey(uniqueKey.hashCode.toString()),
      dataPoints: dataPoints,
      controlChartStats: searchState.controlChartStats!,
      dataLineColor: AppColors.colorBrand,
      width: double.infinity,
      // width: 100.0,
      height: 144.0, 
      isMovingRange: true,
    ),
  );
}