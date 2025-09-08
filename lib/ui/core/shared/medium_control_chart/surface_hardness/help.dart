import 'package:control_chart/data/bloc/search_chart_details/extension/search_state_extension.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/domain/types/chart_filter_query.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';
import 'package:control_chart/ui/core/shared/medium_control_chart/surface_hardness/control_chart_template.dart';
import 'package:control_chart/ui/screen/screen_content/home_screen_content/home_content_var.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/component/temp.dart';
import 'package:flutter/material.dart';

Widget buildChartsSectionSurfaceHardness(HomeContentVar settingProfile, SearchState searchState) {
  return SizedBox.expand( // ← กินพื้นที่ที่ _ChartFillBox จัดให้แบบเต็ม ๆ
    child: _buildChartContainer(
        title:
          "Furnace ${settingProfile.furnaceNo ?? "-"} "
          " | Material ${settingProfile.materialNo ?? '-'}"
          " | Date ${fmtDate(settingProfile.startDate)} - ${fmtDate(settingProfile.endDate)}",
        searchState: searchState,
    ),
  );
}


// Add enum for chart types
// enum ChartType { surfaceHardness, cdeCdt }

Widget _buildChartContainer({
  required String title,
  required SearchState searchState,
}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final totalH = constraints.maxHeight;
      const outerPadTop = 8.0;
      const outerPadBottom = 16.0;
      const titleH = 24.0;              // ความสูงข้อความหัวข้อด้านบน
      const sectionLabelH = 20.0;       // ความสูง label "Individual"/"Moving Range"
      const gapV = 8.0;                 // ช่องว่างระหว่างส่วนต่าง ๆ
      // ความสูงที่เหลือสำหรับกราฟจริง (สองใบ)
      final chartsAreaH = (totalH
          - outerPadTop - outerPadBottom
          - titleH
          - gapV // ระหว่าง title กับการ์ด
          - 8.0 // padding ในการ์ดเหนือ "Individual"
          - sectionLabelH
          - gapV
          - sectionLabelH
          - 8.0 // padding ใต้การ์ด
      ).clamp(0.0, double.infinity);

      final eachChartH = (chartsAreaH / 2).clamp(0.0, double.infinity);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.fromLTRB(0,0,0,8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [ Text(title, style: AppTypography.textBody2BBold) ],
            ),
          ),

          // Card ครอบสองกราฟ
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.colorBrandTp.withValues(alpha: 0.15),
                border: Border.all(
                  color: AppColors.colorBrandTp.withValues(alpha: 0.35),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Column(
                  children: [
                    // Label
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.0),
                      child: Text("Individual", style: AppTypography.textBody3BBold),
                    ),
                    // ✅ กราฟบน: ล็อกความสูง
                    _buildSingleChart(
                      searchState: searchState,
                      isMovingRange: false,
                      height: eachChartH,
                    ),

                    const SizedBox(height: 8),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.0),
                      child: Text("Moving Range", style: AppTypography.textBody3BBold),
                    ),
                    // ✅ กราฟล่าง: ล็อกความสูง
                    _buildMrChart(
                      searchState: searchState,
                      isMovingRange: true,
                      height: eachChartH,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}


Widget _buildSingleChart({
  required SearchState searchState,
  required bool isMovingRange,
  required double height,        // ← เพิ่ม
}) {
  return SizedBox(
    width: double.infinity,
    height: height,              // ← ล็อกความสูงจริง
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: _buildChartContent(
        searchState: searchState,
        isMovingRange: isMovingRange,
        forcedHeight: height,     // ← ส่ง Height ลงไปถึง Template
      ),
    ),
  );
}

Widget _buildMrChart({
  required SearchState searchState,
  required bool isMovingRange,
  required double height,        // ← เพิ่ม
}) {
  return SizedBox(
    width: double.infinity,
    height: height,              // ← ล็อกความสูงจริง
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: _buildMrChartContent(
        searchState: searchState,
        isMovingRange: true,
        forcedHeight: height,     // ← ส่ง Height ลงไปถึง Template
      ),
    ),
  );
}


Widget _buildChartContent({
  required SearchState searchState,
  // required ChartType chartType,
  required bool isMovingRange,
  double? forcedHeight, 
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
      height: forcedHeight, 
      isMovingRange: false,
    ),
  );
}

Widget _buildMrChartContent({
  required SearchState searchState,
  // required ChartType chartType,
  required bool isMovingRange,
  double? forcedHeight, 
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
      height: forcedHeight, 
      isMovingRange: true,
    ),
  );
}