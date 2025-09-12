import 'package:control_chart/domain/models/control_chart_stats.dart';
import 'package:intl/intl.dart';

import '../../../../domain/models/chart_data_point.dart';
import '../search_bloc.dart';

extension SearchStateExtension on SearchState {
  /// Surface Hardness points (unchanged)
  List<ChartDataPoint> get chartDataPoints {
    final mrValues = controlChartStats?.mrChartSpots ?? const <double>[];

    return chartDetails.asMap().entries.map((entry) {
      final index       = entry.key;
      final chartDetail = entry.value;

      final dt = chartDetail.chartGeneralDetail.collectedDate;
      final mrValue = (index < mrValues.length) ? mrValues[index] : 0.0;

      return ChartDataPoint(
        // label: DateFormat('MM/dd/yy').format(dt),
        // label: DateFormat('dd/MM/yy').format(dt),
        collectDate: dt,
        label: DateFormat('dd/MM').format(dt),
        fullLabel:
            "${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}/${dt.year.toString().padLeft(4, '0')}",
        furnaceNo: chartDetail.chartGeneralDetail.furnaceNo.toString(),
        matNo: chartDetail.cpNo,
        value: chartDetail.machanicDetail.surfaceHardnessMean,
        mrValue: mrValue,
      );
    }).toList();
  }

  /// CDE/CDT/Compound Layer points, driven by `secondChartSelected`
  List<ChartDataPointCdeCdt> get chartDataPointsCdeCdt {
    final stats = controlChartStats;
    if (stats == null) return const <ChartDataPointCdeCdt>[];

    // Choose value & MR lists strictly by selection
    late final List<double> values;
    late final List<double> mrValues;

    switch (stats.secondChartSelected) {
      case SecondChartSelected.cde:
        values   = stats.cdeChartSpots ?? const <double>[];
        mrValues = stats.cdeMrChartSpots ?? const <double>[];
        break;
      case SecondChartSelected.cdt:
        values   = stats.cdtChartSpots ?? const <double>[];
        mrValues = stats.cdtMrChartSpots ?? const <double>[];
        break;
      case SecondChartSelected.compoundLayer:
        values   = stats.compoundLayerChartSpots ?? const <double>[];
        mrValues = stats.compoundLayerMrChartSpots ?? const <double>[];
        break;
      case SecondChartSelected.na:
      default:
        return const <ChartDataPointCdeCdt>[]; // not shown
    }

    // Map chartDetails to points; guard out-of-range indexes
    return chartDetails.asMap().entries.map((entry) {
      final index       = entry.key;
      final chartDetail = entry.value;

      final dt = chartDetail.chartGeneralDetail.collectedDate;
      final value   = (index < values.length)   ? values[index]   : 0.0;
      final mrValue = (index < mrValues.length) ? mrValues[index] : 0.0;

      return ChartDataPointCdeCdt(
        // label: DateFormat('MM/dd/yy').format(dt),
        // label: DateFormat('dd/MM/yy').format(dt),
        collecDate: dt,
        label: DateFormat('dd/MM').format(dt),
        fullLabel: "${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}/${dt.year.toString().padLeft(4, '0')}",
        furnaceNo: chartDetail.chartGeneralDetail.furnaceNo.toString(),
        matNo: chartDetail.cpNo,
        value: value,
        mrValue: mrValue,
      );

    }).toList();
  }
}
