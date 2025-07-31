import 'package:control_chart/data/bloc/chart_details/chart_details_bloc.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/domain/models/chart_data_point.dart';
import 'package:control_chart/domain/models/control_chart_stats.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/shared/control_chart_template.dart';
import 'package:control_chart/ui/core/shared/table_component.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/component/setting_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  HomeContentState createState() => HomeContentState();
}

class HomeContentState extends State<HomeContent> {
  @override
  Widget build(BuildContext context) {
    final sampleData = [
      ChartDataPoint(label: '330', value: 300),
      ChartDataPoint(label: '430', value: 500),
      ChartDataPoint(label: '530', value: 600),
      ChartDataPoint(label: '630', value: 700),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          const SettingForm(),
          const SizedBox(width: 16.0),
          Column(
            children: [
              // ✅ ใช้ SearchBloc ตรงๆ แทน ChartDetailsBloc
              BlocBuilder<SearchBloc, SearchState>(
                builder: (context, searchState) {
                  if (searchState.status == SearchStatus.loading) {
                    return const CircularProgressIndicator();
                  }
                  
                  if (searchState.status == SearchStatus.failure) {
                    return Text('Error: ${searchState.errorMessage}');
                  }
                  
                  if (searchState.controlChartStats == null) {
                    return const Text('No control chart data');
                  }
                  
                  return 
                    BlocBuilder<SearchBloc, SearchState>(
                      builder: (context, searchState) {
                        return ControlChartTemplate(
                          key: ValueKey('${searchState.currentQuery.startDate}-${searchState.currentQuery.endDate}-${searchState.currentQuery.furnaceNo}'),
                          dataPoints: sampleData,
                          controlChartStats: searchState.controlChartStats!,
                          dataLineColor: AppColors.colorBrand,
                          width: 300 * 21 / 9,
                        );
                      },
                    );
                },
              ),
            ],
          ),
        ], 
      ),
    );
  }
}