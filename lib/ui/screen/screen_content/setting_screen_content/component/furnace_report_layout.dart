import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';
import 'package:control_chart/ui/core/shared/table_component.dart';
import 'package:flutter/material.dart';

class FurnaceReportLayout extends StatelessWidget {
  const FurnaceReportLayout({super.key});

@override
Widget build(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: LayoutBuilder( // ✅ รับขนาดจาก parent
      builder: (context, constraints) {
        double contentWidth = constraints.maxWidth > 1200 
          ? 1200 // ✅ สูงสุด 1200px บนหน้าจอใหญ่
          : constraints.maxWidth * 0.95; // ✅ 95% บนหน้าจอเล็ก
          
        return Center(
          child: SingleChildScrollView(
            child: SizedBox(
              width: contentWidth,
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
                        buildDataTable(),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  buildPagination(),
                  SizedBox(height: 16),
                  
                  Text(
                    'Furnace No. 8/ 240098B34',
                    style: AppTypography.textBody1BBold
                  ),
                  
                  SizedBox(height: 16),
                  buildChartsSection(),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}
}