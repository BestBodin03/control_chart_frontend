

import 'package:control_chart/data/bloc/search_chart_details/extension/search_state_extension.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';
import 'package:control_chart/ui/core/shared/small_control_chart/surface_hardness/control_chart_template_small.dart';
import 'package:flutter/material.dart';

import '../../../data/bloc/search_chart_details/search_bloc.dart';
import '../design_system/app_color.dart';

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