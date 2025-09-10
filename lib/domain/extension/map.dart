// somewhere shared (เช่น ข้างๆ model)
import 'package:control_chart/domain/models/control_chart_stats.dart';

extension SecondChartSelectedLabel on SecondChartSelected {
  String get label {
    switch (this) {
      case SecondChartSelected.cde:
        return 'CDE';
      case SecondChartSelected.cdt:
        return 'CDT';
      case SecondChartSelected.compoundLayer:
        return 'COMPOUND LAYER';
      case SecondChartSelected.na:
        return 'NA';
    }
  }
}
