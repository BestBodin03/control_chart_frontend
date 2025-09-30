import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';

class SearchControl {
  static void run({
    required BlocContext ctx,
    required DateTime? start,
    required DateTime? end,
    int? furnaceInt,
    String? materialStr,
  }) {
    if (start == null || end == null) return;
    ctx.read<SearchBloc>().add(LoadFilteredChartData(
      startDate: start,
      endDate: end,
      // if your event expects int?, change to furnaceNo: furnaceInt
      furnaceNo: furnaceInt?.toString(),
      materialNo: materialStr,
    ));
  }
}

/// Tiny typedef so it's easy to mock in tests
typedef BlocContext = dynamic;
