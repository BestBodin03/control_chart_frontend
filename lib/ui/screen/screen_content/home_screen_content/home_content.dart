import 'package:control_chart/domain/models/chart_data_point.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/shared/control_chart_template.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/component/setting_form.dart';
import 'package:flutter/material.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  HomeContentState createState() => HomeContentState();
}

class HomeContentState extends State<HomeContent> {
  @override
  Widget build(BuildContext context) {
    final sampleData = [
      ChartDataPoint(label: '330', value: 16),
      ChartDataPoint(label: '401', value: 25),
      ChartDataPoint(label: '430', value: 15),
      ChartDataPoint(label: '405', value: 26),
      ChartDataPoint(label: '411', value: 10),
      ChartDataPoint(label: '430', value: 21),
      ChartDataPoint(label: '506', value: 12),
      ChartDataPoint(label: '517', value: 28),
      ChartDataPoint(label: '524', value: 12),
      ChartDataPoint(label: '630', value: 16),
      ChartDataPoint(label: '901', value: 25),
      ChartDataPoint(label: 'A30', value: 15),
      ChartDataPoint(label: 'A05', value: 26),
      ChartDataPoint(label: 'A11', value: 10),
      ChartDataPoint(label: 'B30', value: 21),
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
    
    return 
    SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          const SettingForm(),

          const SizedBox(width: 16.0),

          Column(
            children: [
              SizedBox(
                width: 300,
                height: 200,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.colorBrandTp
                  ),
                  ),
              ),
              ControlChartTemplate(
                dataPoints: sampleData,
                controlLimits: controlLimits,
                dataLineColor: AppColors.colorBrand,
                width: 300*21/9,
              ),
            ],
          ),
        ], 
      ),
    );
  }
}