
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/bloc/search_chart_details/search_bloc.dart';
import '../design_system/app_color.dart';

Widget buildHeaderTable() {
  return SizedBox(
    height: 32,
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
  int? hoveredRowIndex;
  int? selectedRowIndex;

  if (chartDetails.isEmpty) {
    return const SizedBox(
      height: 200,
      child: Center(child: Text('ไม่มีข้อมูล')),
    );
  }

  const rowHeight = 32.0;
  const maxRowsForFitContent = 6;
  final isScrollable = chartDetails.length > maxRowsForFitContent;

  return SizedBox(
    height: isScrollable ? 200 : null,
    child: ListView.builder(
      shrinkWrap: !isScrollable,
      physics: isScrollable
          ? const ClampingScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      itemCount: chartDetails.length,
      itemBuilder: (context, index) {
        final chartDetail = chartDetails[index];
        final isLast = index == chartDetails.length - 1;
        final isHovered = hoveredRowIndex == index;
        final isSelected = selectedRowIndex == index;

        final count = chartDetail.count ?? 0;
        final isDisabled = count < 5;

        return SizedBox(
          height: rowHeight,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                bottom: index < chartDetails.length - 1
                    ? const BorderSide(color: Colors.black26, width: 0.5)
                    : BorderSide.none,
              ),
              borderRadius: isLast
                  ? const BorderRadius.vertical(bottom: Radius.circular(10))
                  : null,
            ),
            child: MouseRegion(
              child: Material(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.10)
                    : (isHovered
                        ? AppColors.colorBrandTp
                        : Colors.transparent),
                child: InkWell(
                  onTap: isDisabled
                      ? null // ❌ ถ้า count < 5 ห้ามกด
                      : () {
                          final q = context.read<SearchBloc>().state.currentQuery;
                          final fn = chartDetail.furnaceNo?.toString();
                          final mat = chartDetail.matNo;

                          final bloc = context.read<SearchBloc>();

                          bloc.add(LoadFilteredChartData(
                            startDate: q.startDate,
                            endDate: q.endDate,
                            furnaceNo: fn ?? q.furnaceNo,
                            materialNo: mat ?? q.materialNo,
                          ));

                          bloc.add(const LoadDropdownOptions());
                        },
                  child: Opacity(
                    opacity: isDisabled ? 0.4 : 1.0, // 🌫️ จางถ้า count < 5
                    child: _buildTableRow(
                      [
                        chartDetail.furnaceNo?.toString() ?? '-',
                        chartDetail.matNo ?? '-',
                        chartDetail.partName ?? '-',
                        chartDetail.count?.toString() ?? '0',
                      ],
                      isHeader: false,
                    ),
                  ),
                ),
              ),
            ),
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

