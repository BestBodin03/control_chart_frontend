import 'package:control_chart/domain/models/control_chart_stats.dart';

class SelectSecondChartAttribute {
  final List<double> values;
  final List<double> mrValues;
  final double average;
  final ControlLimitIChart? iChartLimit;
  final ControlLimitMRChart? mrChartLimit;

  SelectSecondChartAttribute({
    required this.values,
    required this.mrValues,
    required this.average,
    required this.iChartLimit,
    required this.mrChartLimit,
  });
}

SelectSecondChartAttribute? pickBundle(ControlChartStats stats) {
  switch (stats.secondChartSelected) {
    case SecondChartSelected.compoundLayer:
      return SelectSecondChartAttribute(
        values: stats.compoundLayerChartSpots ?? [],
        mrValues: stats.compoundLayerMrChartSpots ?? [],
        average: stats.compoundLayerAverage ?? 0,
        iChartLimit: stats.compoundLayerControlLimitIChart,
        mrChartLimit: stats.compoundLayerControlLimitMRChart,
      );
    case SecondChartSelected.cde:
      return SelectSecondChartAttribute(
        values: stats.cdeChartSpots ?? [],
        mrValues: stats.cdeMrChartSpots ?? [],
        average: stats.cdeAverage ?? 0,
        iChartLimit: stats.cdeControlLimitIChart,
        mrChartLimit: stats.cdeControlLimitMRChart,
      );
    case SecondChartSelected.cdt:
      return SelectSecondChartAttribute(
        values: stats.cdtChartSpots ?? [],
        mrValues: stats.cdtMrChartSpots ?? [],
        average: stats.cdtAverage ?? 0,
        iChartLimit: stats.cdtControlLimitIChart,
        mrChartLimit: stats.cdtControlLimitMRChart,
      );
    case SecondChartSelected.na:
    default:
      return null; // ไม่ต้องแสดง
  }
}
