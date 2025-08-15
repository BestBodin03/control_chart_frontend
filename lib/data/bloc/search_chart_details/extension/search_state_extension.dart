

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
        label: "${chartDetail.chartGeneralDetail.collectedDate.month.toString().padLeft(2, '0')}/${chartDetail.chartGeneralDetail.collectedDate.day.toString().padLeft(2, '0')}",
        fullLabel: "${chartDetail.chartGeneralDetail.collectedDate.month.toString().padLeft(2, '0')}/${chartDetail.chartGeneralDetail.collectedDate.day.toString().padLeft(2, '0')}/${chartDetail.chartGeneralDetail.collectedDate.year.toString().padLeft(4, '0')}",
        furnaceNo: chartDetail.chartGeneralDetail.furnaceNo.toString(),
        matNo: chartDetail.cpNo,
        value: chartDetail.machanicDetail.surfaceHardnessMean,
        mrValue: mrValue,
      );
    }).toList();
  }

  List<ChartDataPoint> get chartDataPointsCdeCdt {
    final mrValues = controlChartStats?.mrChartSpots ?? [];
    
    return chartDetails.asMap().entries.map((entry) {
      final index = entry.key;
      final chartDetail = entry.value;
      
      final mrValue = index < mrValues.length ? mrValues[index] : 0.0;
      
      return ChartDataPoint(
        label: "${chartDetail.chartGeneralDetail.collectedDate.month.toString().padLeft(2, '0')}/${chartDetail.chartGeneralDetail.collectedDate.day.toString().padLeft(2, '0')}",
        fullLabel: "${chartDetail.chartGeneralDetail.collectedDate.month.toString().padLeft(2, '0')}/${chartDetail.chartGeneralDetail.collectedDate.day.toString().padLeft(2, '0')}/${chartDetail.chartGeneralDetail.collectedDate.year.toString().padLeft(4, '0')}",
        furnaceNo: chartDetail.chartGeneralDetail.furnaceNo.toString(),
        matNo: chartDetail.cpNo,
        value: chartDetail.machanicDetail.surfaceHardnessMean,
        mrValue: mrValue,
      );
    }).toList();
  }
}