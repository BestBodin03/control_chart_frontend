import 'package:control_chart/domain/models/chart_data_point.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/shared/control_chart_template.dart';
import 'package:flutter/material.dart';
    final sampleData = [
      ChartDataPoint(label: 'B06', value: 12),
      ChartDataPoint(label: 'C17', value: 28),
      ChartDataPoint(label: 'C24', value: 12),
      ChartDataPoint(label: '630', value: 16),
      ChartDataPoint(label: '901', value: 30),
      ChartDataPoint(label: 'A30', value: 33),
      ChartDataPoint(label: 'A05', value: 26),
      ChartDataPoint(label: 'A11', value: 10),
      ChartDataPoint(label: 'B30', value: 21),
      ChartDataPoint(label: 'B06', value: 12),
      ChartDataPoint(label: 'C17', value: 28),
      ChartDataPoint(label: 'C24', value: 32),
    ];

    final controlLimits = ControlLimits(
      usl: 32,  // Upper Specification Limit
      ucl: 30,  // Upper Control Limit  
      average: 19, // Average
      lcl: 8,   // Lower Control Limit
      lsl: 2,   // Lower Specification Limit
    );
    
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
          'CP No.',
          'Part Name',
          'Material No.',
          'จำนวนครั้ง',
        ], isHeader: true),
      ),
    );
  }

  Widget buildDataTable(int dataLength) {
    // Limit to maximum 8 rows
    final int displayLength = dataLength > 8 ? 8 : dataLength;
    
    return Column(
      children: List.generate(displayLength, (index) {
        return Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: index < displayLength - 1 
                ? BorderSide(color: Colors.black26, width: 0.5)
                : BorderSide.none,
            ),
            borderRadius: index == displayLength - 1
              ? BorderRadius.vertical(bottom: Radius.circular(10.0))
              : null,
          ),
          child: _buildTableRow(['5', '2400ui9987', 'SPRING', 'U*0wwk872548', dataLength.toString()], isHeader: false),
        );
      }),
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
                  right: index < cells.length - 1 // ✅ Only right border
                    ? BorderSide(color: Colors.black26, width: 0.5)
                    : BorderSide.none,
                ),
              ),
              child: Center( // Add Center for better alignment in 36px height
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

  Widget buildPagination() {
    return SizedBox(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(16.0))
          ),
                  child:
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('8-12 of 12'),
                SizedBox(width: 16),
                Text('Page:'),
                SizedBox(width: 8),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(child: Text('6')),
                ),
                SizedBox(width: 8),
                Icon(Icons.chevron_left, size: 20),
                SizedBox(width: 4),
                Icon(Icons.chevron_right, size: 20),
              ],
            ),
          ),
        ),
      );
  }

  Widget buildChartsSection() {
    return Row(
      children: [
        // Hardness Chart
        Expanded(
          child: _buildChartContainer(
            title: 'Hardness',
            isHighlighted: false,
          ),
        ),
        
        SizedBox(width: 16),
        
        // CDE, CDT Chart (Highlighted)
        Expanded(
          child: _buildChartContainer(
            title: 'CDE, CDT',
            isHighlighted: true,
          ),
        ),
      ],
    );
  }

  Widget _buildChartContainer({
    required String title,
    required bool isHighlighted,
  }) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(
          color: isHighlighted ? AppColors.colorAlert1 : AppColors.colorBlack,
          width: isHighlighted ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Chart Title
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Icon(Icons.fullscreen, size: 16),
              ],
            ),
          ),
          
          // Chart Content Area (Empty box for now)
          Expanded(
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
            child:ControlChartTemplate(
              dataPoints: sampleData,
              controlLimits: controlLimits,
              xAxisLabel: 'Date',
              yAxisLabel: 'Temperature',
              dataLineColor: Colors.blue,
            ),
            ),
          ),
        ],
      ),
    );
  }