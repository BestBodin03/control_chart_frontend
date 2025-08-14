// import 'package:control_chart/data/bloc/chart_details/chart_details_bloc.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/domain/models/chart_data_point.dart';
// import 'package:control_chart/domain/models/control_chart_stats.dart';
// import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/shared/control_chart_template.dart';
// import 'package:control_chart/ui/core/shared/table_component.dart';
import 'package:control_chart/ui/core/shared/searching_form.dart';
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          const SearchingForm(),
          const SizedBox(width: 16.0),
          Column(
            children: [
              BlocBuilder<SearchBloc, SearchState>(
                builder: (context, searchState) {
                  if (searchState.status == SearchStatus.loading) {
                    // DON'T create new SearchBloc instance here!
                    // Just show loading indicator
                    return const CircularProgressIndicator();
                  }
                  
                  if (searchState.status == SearchStatus.failure) {
                    return Column(
                      children: [
                        Text('Error: ${searchState.errorMessage}'),
                        ElevatedButton(
                          onPressed: () {
                            // Retry using existing SearchBloc from context
                            context.read<SearchBloc>().add(LoadFilteredChartData(
                              startDate: DateTime.now().subtract(const Duration(days: 30)),
                              endDate: DateTime.now(),
                            ));
                          },
                          child: const Text('ลองใหม่'),
                        ),
                      ],
                    );
                  }
                  
                  if (searchState.controlChartStats == null) {
                    return const Text('No control chart data');
                  }

                  final query = searchState.currentQuery;
                  final uniqueKey = '${query.startDate?.day}-'
                      '${query.endDate?.millisecondsSinceEpoch}-'
                      '${query.furnaceNo}-'
                      '${query.materialNo}-';
                      
                  return ControlChartTemplate(
                    key: ValueKey(uniqueKey.hashCode.toString()),
                    dataPoints: searchState.chartDetails.map((chartDetail) => ChartDataPoint(
                      label: "${chartDetail.chartGeneralDetail.collectedDate.month.toString().padLeft(2, '0')}/${chartDetail.chartGeneralDetail.collectedDate.day.toString().padLeft(2, '0')}",
                      fullLabel: "${chartDetail.chartGeneralDetail.collectedDate.month.toString().padLeft(2, '0')}/${chartDetail.chartGeneralDetail.collectedDate.day.toString().padLeft(2, '0')}/${chartDetail.chartGeneralDetail.collectedDate.year.toString().padLeft(4)}",
                      furnaceNo: chartDetail.chartGeneralDetail.furnaceNo.toString(),
                      matNo: chartDetail.cpNo,
                      value: chartDetail.machanicDetail.surfaceHardnessMean,
                    )).toList(),
                    controlChartStats: searchState.controlChartStats!,
                    dataLineColor: const Color.fromARGB(255, 167, 163, 228),
                    width: 300 * 21 / 9,
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