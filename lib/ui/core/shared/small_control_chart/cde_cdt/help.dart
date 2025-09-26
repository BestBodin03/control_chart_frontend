// Modified to accept SearchState parameter and show two small charts (I & MR)
import 'package:control_chart/data/bloc/search_chart_details/extension/search_state_extension.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/domain/extension/map.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';
import 'package:control_chart/ui/core/shared/small_control_chart/cde_cdt/control_chart_template_small_cde_cdt.dart';
import 'package:flutter/material.dart';

Widget buildChartsSectionCdeCdtSmall(SearchState searchState) {
  final title =
      searchState.controlChartStats?.secondChartSelected?.label ?? 'N/A';

  return Row(
    children: [
      Expanded(
        child: _buildChartContainerCdeCdt(
          title: title,
          searchState: searchState,
        ),
      ),
    ],
  );
}

Widget _buildChartContainerCdeCdt({
  required String title,
  required SearchState searchState,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Title
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: AppTypography.textBody2BBold),
          ],
        ),
      ),

      // Outer bordered card
      DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.colorBrandTp.withValues(alpha: 0.15),
          border: Border.all(
            color: AppColors.colorBrandTp.withValues(alpha: 0.35),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // INDIVIDUAL
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  "Control Chart",
                  style: AppTypography.textBody3BBold,
                  textAlign: TextAlign.center,
                ),
              ),
              _buildSingleChartCdeCdt(
                searchState: searchState,
                isMovingRange: false),

              // MR
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  "Moving Range",
                  style: AppTypography.textBody3BBold,
                  textAlign: TextAlign.center,
                ),
              ),
              _buildMrChartCdeCdt(
                searchState: searchState,
                isMovingRange: true),
            ],
          ),
        ),
      ),
    ],
  );
}

Widget _buildSingleChartCdeCdt({
  required SearchState searchState,
  // required ChartType chartType,
  required bool isMovingRange,
}) {
  return SizedBox(
    width: double.infinity,
    // width: 100.0,
    height: 144.0,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.colorBg, // Changed from black26 to light background
        borderRadius: BorderRadius.circular(8),
      ),
      child: _buildMrChartContentCdeCdt(
        searchState: searchState,
        // chartType: chartType,
        isMovingRange: isMovingRange,
      ),
    ),
  );
}

Widget _buildMrChartCdeCdt({
  required SearchState searchState,
  // required ChartType chartType,
  required bool isMovingRange,
}) {
  return SizedBox(
    // width: double.infinity,
    width: 100.0,
    height: 144.0,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.colorBg, // Changed from black26 to light background
        borderRadius: BorderRadius.circular(8),
      ),
      child: _buildChartContentCdeCdt(
        searchState: searchState,
        // chartType: chartType,
        isMovingRange: true,
      ),
    ),
  );
}

Widget _buildChartContentCdeCdt({
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
              'จำนวนข้อมูลไม่เพียงพอ ต้องการข้อมูลอย่างน้อย 5 รายการ',
              style: TextStyle(fontSize: 14, color: Colors.red),
            ),
        ],
      ),
    );
  }
  
  // Handle empty data
  if (searchState.controlChartStats == null || searchState.chartDetails.isEmpty) {
    return Center(
      child: Center(
        child: Text('ไม่มีข้อมูล', style: TextStyle(fontSize: 12, color: Colors.red)),
      ),
    );
  }

  // Generate unique key for chart
  final query = searchState.currentQuery;
  final uniqueKey = '${query.startDate?.day}-'
      '${query.endDate?.millisecondsSinceEpoch}-'
      '${query.furnaceNo}-'
      '${query.materialNo}-';
  final dataPoints = searchState.chartDataPointsCdeCdt;

  return ClipRRect(
    borderRadius: BorderRadius.circular(4),
    child: ControlChartTemplateSmallCdeCdt(
      key: ValueKey(uniqueKey.hashCode.toString()),
      dataPoints: dataPoints,
      controlChartStats: searchState.controlChartStats!,
      dataLineColor: AppColors.colorBrand,
      width: double.infinity,
      // width: 100.0,
      height: 144.0, 
      isMovingRange: false,
    ),
  );
}

Widget _buildMrChartContentCdeCdt({
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
              'จำนวนข้อมูลไม่เพียงพอ ต้องการข้อมูลอย่างน้อย 5 รายการ',
              style: TextStyle(fontSize: 14, color: Colors.red),
            ),
        ],
      ),
    );
  }
  
  // Handle empty data
  if (searchState.controlChartStats == null || searchState.chartDetails.isEmpty) {
    return Center(
      child: Center(
        child: Text('ไม่มีข้อมูล', style: TextStyle(fontSize: 12, color: Colors.red)),
      ),
    );
  }

  // Generate unique key for chart
  final query = searchState.currentQuery;
  final uniqueKey = '${query.startDate?.day}-'
      '${query.endDate?.millisecondsSinceEpoch}-'
      '${query.furnaceNo}-'
      '${query.materialNo}-';
  final dataPoints = searchState.chartDataPointsCdeCdt;

  return ClipRRect(
    borderRadius: BorderRadius.circular(4),
    child: ControlChartTemplateSmallCdeCdt(
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