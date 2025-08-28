
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/domain/models/chart_data_point.dart';
import 'package:control_chart/ui/core/shared/medium_control_chart/cde_cdt/help.dart';
import 'package:control_chart/ui/core/shared/medium_control_chart/surface_hardness/control_chart_template.dart';
import 'package:control_chart/ui/core/shared/medium_control_chart/surface_hardness/help.dart';
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
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // 📊 Charts area fills the remaining height
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, searchState) {
                  if (searchState.status == SearchStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
      
                  if (searchState.status == SearchStatus.failure) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Error: ${searchState.errorMessage}'),
                          ElevatedButton(
                            onPressed: () {
                              context.read<SearchBloc>().add(
                                    LoadFilteredChartData(
                                      startDate: DateTime.now()
                                          .subtract(const Duration(days: 30)),
                                      endDate: DateTime.now(),
                                    ),
                                  );
                            },
                            child: const Text('ลองใหม่'),
                          ),
                        ],
                      ),
                    );
                  }
      
                  if (searchState.controlChartStats == null) {
                    return const Center(child: Text('No control chart data'));
                  }
      
                  final q = searchState.currentQuery;
                  final uniqueKey = '${q.startDate?.day}-'
                      '${q.endDate?.millisecondsSinceEpoch}-'
                      '${q.furnaceNo}-'
                      '${q.materialNo}-';
      
                  return Row(
                    key: ValueKey(uniqueKey),
                    children: [
                      Expanded(
                        child: SizedBox.expand(
                          child: buildChartsSectionSurfaceHardness(searchState),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox.expand(
                          child: buildChartsSectionCdeCdt(searchState),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
      
            const SizedBox(height: 16),
      
            // // 🔎 Form placed BELOW the charts
            // const SearchingForm(),
          ],
        ),
      );
    // );
  }
}
