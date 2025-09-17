import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/domain/models/chart_data_point.dart';
import 'package:control_chart/domain/models/control_chart_stats.dart';
import 'package:intl/intl.dart';

extension SearchStateExtension on SearchState {
  /// Surface Hardness points (refactored to be like CdeCdt)
  List<ChartDataPoint> get chartDataPoints {
    final stats = controlChartStats;
    if (stats == null) return const <ChartDataPoint>[];

    final values   = stats.surfaceHardnessChartSpots ?? const <double>[];
    final mrValues = stats.mrChartSpots             ?? const <double>[];

    // Map chartDetails to points; guard out-of-range indexes
    return chartDetails.asMap().entries.map((entry) {
      final index       = entry.key;
      final chartDetail = entry.value;

      final dt = chartDetail.chartGeneralDetail.collectedDate;
      final value   = (index < values.length)   ? values[index]   : 0.0;
      final mrValue = (index < mrValues.length) ? mrValues[index] : 0.0;
      final isViolatedR3 = (index < stats.controlChartSpots!.surfaceHardness.length)
          ? stats.controlChartSpots!.surfaceHardness[index].isViolatedR3
          : false;
      final isViolatedR1BeyondLCL = (index < stats.controlChartSpots!.surfaceHardness.length)
          ? stats.controlChartSpots!.surfaceHardness[index].isViolatedR1BeyondLCL
          : false;
      final isViolatedR1BeyondUCL = (index < stats.controlChartSpots!.surfaceHardness.length)
          ? stats.controlChartSpots!.surfaceHardness[index].isViolatedR1BeyondUCL
          : false;
      final isViolatedR1BeyondLSL = (index < stats.controlChartSpots!.surfaceHardness.length)
          ? stats.controlChartSpots!.surfaceHardness[index].isViolatedR1BeyondLSL
          : false;
      final isViolatedR1BeyondUSL = (index < stats.controlChartSpots!.surfaceHardness.length)
          ? stats.controlChartSpots!.surfaceHardness[index].isViolatedR1BeyondUSL
          : false;

      return ChartDataPoint(
        collectDate: dt,
        label: DateFormat('dd/MM').format(dt),
        fullLabel:
            "${dt.day.toString().padLeft(2, '0')}/"
            "${dt.month.toString().padLeft(2, '0')}/"
            "${dt.year.toString().padLeft(4, '0')}",
        furnaceNo: chartDetail.chartGeneralDetail.furnaceNo.toString(),
        matNo: chartDetail.cpNo,
        value: value,
        mrValue: mrValue,
        isViolatedR3: isViolatedR3,
        isViolatedR1BeyondLCL: isViolatedR1BeyondLCL,
        isViolatedR1BeyondUCL: isViolatedR1BeyondUCL,
        isViolatedR1BeyondLSL: isViolatedR1BeyondLSL,
        isViolatedR1BeyondUSL: isViolatedR1BeyondUSL,
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

    // Map chartDetails to points
    return chartDetails.asMap().entries.map((entry) {
      final index       = entry.key;
      final chartDetail = entry.value;

      final dt = chartDetail.chartGeneralDetail.collectedDate;
      final value   = (index < values.length)   ? values[index]   : 0.0;
      final mrValue = (index < mrValues.length) ? mrValues[index] : 0.0;
      // final isViolatedR3 = (index < stats.controlChartSpots.)
      //     ? stats.surfaceHardnessNelsonRules[index].isViolatedR3
      //     : false;

      return ChartDataPointCdeCdt(
        collectDate: dt,
        label: DateFormat('dd/MM').format(dt),
        fullLabel:
            "${dt.day.toString().padLeft(2, '0')}/"
            "${dt.month.toString().padLeft(2, '0')}/"
            "${dt.year.toString().padLeft(4, '0')}",
        furnaceNo: chartDetail.chartGeneralDetail.furnaceNo.toString(),
        matNo: chartDetail.cpNo,
        value: value,
        mrValue: mrValue,
        isViolatedR3: false,
      );
    }).toList();
  }
}
