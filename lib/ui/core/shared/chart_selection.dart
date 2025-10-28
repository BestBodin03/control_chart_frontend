import '../../../domain/models/control_chart_stats.dart';

extension ChartSelection on ControlChartStats? {
  SecondChartSelected? get selType => this?.secondChartSelected;

  T? sel<T>(T? cde, T? cdt, T? comp) {
    switch (this?.secondChartSelected) {
      case SecondChartSelected.cde:
        return cde;
      case SecondChartSelected.cdt:
        return cdt;
      case SecondChartSelected.compoundLayer:
        return comp;
      default:
        return null;
    }
  }
}