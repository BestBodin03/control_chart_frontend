

import 'package:intl/intl.dart';

import '../../../../domain/models/chart_data_point.dart';
import '../search_bloc.dart';

extension SearchStateExtension on SearchState {
  List<ChartDataPoint> get chartDataPoints {
    final mrValues = controlChartStats?.mrChartSpots ?? [];
    
    return chartDetails.asMap().entries.map((entry) {
      final index = entry.key;
      final chartDetail = entry.value;
      
      final mrValue = index < mrValues.length ? mrValues[index] : 0.0;
      
      return ChartDataPoint(
        label: DateFormat('MM/dd/yy').format(chartDetail.chartGeneralDetail.collectedDate),
        fullLabel: "${chartDetail.chartGeneralDetail.collectedDate.month.toString().padLeft(2, '0')}/${chartDetail.chartGeneralDetail.collectedDate.day.toString().padLeft(2, '0')}/${chartDetail.chartGeneralDetail.collectedDate.year.toString().padLeft(4, '0')}",
        furnaceNo: chartDetail.chartGeneralDetail.furnaceNo.toString(),
        matNo: chartDetail.cpNo,
        value: chartDetail.machanicDetail.surfaceHardnessMean,
        mrValue: mrValue,
      );
    }).toList();
  }

  List<ChartDataPointCdeCdt> get chartDataPointsCdeCdt {
    // Fallbacks
    const fallbackVals = <double>[];
    final fallbackMr   = controlChartStats?.mrChartSpots ?? const <double>[];

    return chartDetails.asMap().entries.map((entry) {
      final index       = entry.key;
      final chartDetail = entry.value;

      // Decide whether to use CDT or CDE
      // final bool useCdt = (controlChartStats?.cdeAverage ?? 0) < (controlChartStats?.cdtAverage ?? 0);
      final bool useCdt = (controlChartStats?.cdeAverage ?? 0) < (controlChartStats?.cdtAverage ?? 0);

      // Pick value LIST by the same rule; then take the item at `index`
      final List<double> valueList = useCdt
          ? (controlChartStats?.cdtChartSpots ?? fallbackVals)
          : (controlChartStats?.cdeChartSpots ?? fallbackVals);

      final double value = index < valueList.length
          ? (valueList[index])
          : 0.0;

      // Pick MR list by the same rule; fall back to generic MR if missing
      final List<double> mrList = useCdt
          ? (controlChartStats?.cdtMrChartSpots ?? fallbackMr)
          : (controlChartStats?.cdeMrChartSpots ?? fallbackMr);

      final double mrValue = index < mrList.length ? mrList[index] : 0.0;

      return ChartDataPointCdeCdt(
        label: "${chartDetail.chartGeneralDetail.collectedDate.month.toString().padLeft(2, '0')}/${chartDetail.chartGeneralDetail.collectedDate.day.toString().padLeft(2, '0')}",
        fullLabel:
            "${chartDetail.chartGeneralDetail.collectedDate.month.toString().padLeft(2, '0')}/${chartDetail.chartGeneralDetail.collectedDate.day.toString().padLeft(2, '0')}/${chartDetail.chartGeneralDetail.collectedDate.year.toString().padLeft(4, '0')}",
        furnaceNo: chartDetail.chartGeneralDetail.furnaceNo.toString(),
        matNo: chartDetail.cpNo,
        value: value,
        mrValue: mrValue,
      );
    }).toList();
  }

}
