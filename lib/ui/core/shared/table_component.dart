import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/domain/models/chart_data_point.dart';
import 'package:control_chart/domain/models/control_chart_stats.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';
import 'package:control_chart/ui/core/shared/control_chart_template.dart';
import 'package:control_chart/ui/core/shared/control_chart_template_small.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Widget buildHeaderTable() {
  return SizedBox(
    height: 32, // Fixed height for performance
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.colorBrandTp,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(10.0),
        ),
        border: Border(
          bottom: BorderSide(color: Colors.black26, width: 1),
        ),
      ),
      child: _buildTableRow([
        'Furnace No.',
        'Material No.',
        'Part Name',
        'จำนวนครั้ง',
      ], isHeader: true),
    ),
  );
}

Widget buildDataTable(SearchState searchState) {
  final chartDetails = searchState.searchTable ?? [];
  
  if (chartDetails.isEmpty) {
    return SizedBox(
      height: 200,
      child: Center(child: Text('ไม่มีข้อมูล')),
    );
  }
  
  final rowHeight = 32.0;
  final maxRowsForFitContent = 6;
  final isScrollable = chartDetails.length > maxRowsForFitContent;
  
  return SizedBox(
    height: isScrollable ? 200 : null, // null = fit content
    child: ListView.builder(
      shrinkWrap: !isScrollable, // shrinkWrap เมื่อไม่ scrollable
      physics: isScrollable 
        ? ClampingScrollPhysics() 
        : NeverScrollableScrollPhysics(),
      itemCount: chartDetails.length,
      itemBuilder: (context, index) {
        final chartDetail = chartDetails[index];
        
        return SizedBox(
          height: rowHeight,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                bottom: index < chartDetails.length - 1 
                  ? BorderSide(color: Colors.black26, width: 0.5)
                  : BorderSide.none,
              ),
              borderRadius: index == chartDetails.length - 1
                ? BorderRadius.vertical(bottom: Radius.circular(10.0))
                : null,
            ),
            child: _buildTableRow([
              chartDetail.furnaceNo?.toString() ?? '-',
              chartDetail.matNo ?? '-',
              chartDetail.partName ?? '-',
              chartDetail.count?.toString() ?? '0'
            ], isHeader: false),
          ),
        );
      },
    ),
  );
}

Widget _buildTableRow(List<String> cells, {required bool isHeader}) {
  return SizedBox(
    height: 28, // Fixed height for better performance
    child: Row(
      children: cells.asMap().entries.map((entry) {
        int index = entry.key;
        String text = entry.value;
        return Expanded(
          flex: _getFlexValue(index),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                right: index < cells.length - 1
                  ? BorderSide(color: Colors.black26, width: 0.5)
                  : BorderSide.none,
              ),
            ),
            child: Center(
              child: Text(
                text,
                style: isHeader ? _headerTextStyle : _bodyTextStyle,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }).toList(),
    ),
  );
}

const TextStyle _headerTextStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.bold,
  color: Colors.black,
);

const TextStyle _bodyTextStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.normal,
  color: AppColors.colorBlack,
);

int _getFlexValue(int columnIndex) {
  switch (columnIndex) {
    case 0: return 10; // Furnace No.
    case 1: return 10; // CP No.
    case 2: return 15; // Part Name
    case 3: return 15; // Material No.
    case 4: return 10; // จำนวนครั้ง
    default: return 10;
  }
}

// Modified to accept SearchState parameter
Widget buildChartsSection(SearchState searchState) {
  return Row(
    children: [
      // Hardness Chart
      Expanded(
        child: _buildChartContainer(
          title: 'Surface Hardness',
          searchState: searchState,
          chartType: ChartType.surfaceHardness,
        ),
      ),
      
      SizedBox(width: 8.0),
      
      // CDE, CDT Chart
      Expanded(
        child: _buildChartContainer(
          title: 'CDE, CDT',
          searchState: searchState,
          chartType: ChartType.cdeCdt,
        ),
      ),
    ],
  );
}

// Add enum for chart types
enum ChartType { surfaceHardness, cdeCdt }

Widget _buildChartContainer({
  required String title,
  required SearchState searchState,
  required ChartType chartType,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Outer bordered card
      SizedBox(
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.colorBlack),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  chartType: chartType,
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
                _buildSingleChart(
                  searchState: searchState,
                  chartType: chartType,
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
  required ChartType chartType,
  required bool isMovingRange,
}) {
  return SizedBox(
    width: double.infinity,
    height: 144.0,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.grey.shade50, // Changed from black26 to light background
        borderRadius: BorderRadius.circular(8),
      ),
      child: _buildChartContent(
        searchState: searchState,
        chartType: chartType,
        isMovingRange: isMovingRange,
      ),
    ),
  );
}

Widget _buildChartContent({
  required SearchState searchState,
  required ChartType chartType,
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
            'Error',
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
      '${query.materialNo}-'
      '${chartType.name}-'
      '${isMovingRange ? 'mr' : 'individual'}';

  // Prepare data points based on chart type
  List<ChartDataPoint> dataPoints = searchState.chartDetails.map((chartDetail) {

    return ChartDataPoint(
      label: "${chartDetail.chartGeneralDetail.collectedDate.month.toString().padLeft(2, '0')}/${chartDetail.chartGeneralDetail.collectedDate.day.toString().padLeft(2, '0')}",
      fullLabel: "${chartDetail.chartGeneralDetail.collectedDate.month.toString().padLeft(2, '0')}/${chartDetail.chartGeneralDetail.collectedDate.day.toString().padLeft(2, '0')}/${chartDetail.chartGeneralDetail.collectedDate.year.toString().padLeft(4)}",
      furnaceNo: chartDetail.chartGeneralDetail.furnaceNo.toString(),
      matNo: chartDetail.cpNo,
      value: chartDetail.machanicDetail.surfaceHardnessMean,
    );
  }).toList();

  // Return the actual chart
  return ClipRRect(
    borderRadius: BorderRadius.circular(4),
    child: ControlChartTemplateSmall(
      key: ValueKey(uniqueKey.hashCode.toString()),
      dataPoints: dataPoints,
      controlChartStats: searchState.controlChartStats!,
      dataLineColor: AppColors.colorBrand,
      width: double.infinity, // Adjusted for small container
      height: 144.0, // Fit within container
    ),
  );


// Color _getChartColor(ChartType chartType, bool isMovingRange) {
//   switch (chartType) {
//     case ChartType.surfaceHardness:
//       return isMovingRange 
//         ? const Color.fromARGB(255, 167, 163, 228)
//         : const Color.fromARGB(255, 100, 150, 200);
//     case ChartType.cdeCdt:
//       return isMovingRange 
//         ? const Color.fromARGB(255, 228, 167, 163)
//         : const Color.fromARGB(255, 200, 100, 150);
//   }
// }
}