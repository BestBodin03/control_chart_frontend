import 'package:control_chart/domain/models/control_chart_stats.dart';
import 'package:control_chart/domain/models/chart_data_point.dart';

class SelectSecondChartAttribute {
  /// จุดข้อมูลเต็มชุด (label, fullLabel, furnaceNo, matNo, value, mrValue)
  final List<ChartDataPointCdeCdt> points;

  /// ตัวเลขสถิติตาม attribute ที่เลือก
  final double average;
  final ControlLimitIChart? iChartLimit;
  final ControlLimitMRChart? mrChartLimit;

  const SelectSecondChartAttribute({
    required this.points,
    required this.average,
    required this.iChartLimit,
    required this.mrChartLimit,
  });
}

/// เลือกเซ็ตสถิติ (Avg/Limit) ตาม secondChartSelected
/// และส่งกลับพร้อมกับ `points` ที่มาจากแหล่งเดียวกับ Surface Hardness
SelectSecondChartAttribute? pickBundle(
  ControlChartStats stats,
  List<ChartDataPointCdeCdt> points,
) {
  switch (stats.secondChartSelected) {
    case SecondChartSelected.compoundLayer:
      return SelectSecondChartAttribute(
        points: points,
        average: stats.compoundLayerAverage ?? 0,
        iChartLimit: stats.compoundLayerControlLimitIChart,
        mrChartLimit: stats.compoundLayerControlLimitMRChart,
      );

    case SecondChartSelected.cde:
      return SelectSecondChartAttribute(
        points: points,
        average: stats.cdeAverage ?? 0,
        iChartLimit: stats.cdeControlLimitIChart,
        mrChartLimit: stats.cdeControlLimitMRChart,
      );

    case SecondChartSelected.cdt:
      return SelectSecondChartAttribute(
        points: points,
        average: stats.cdtAverage ?? 0,
        iChartLimit: stats.cdtControlLimitIChart,
        mrChartLimit: stats.cdtControlLimitMRChart,
      );

    case SecondChartSelected.na:
    default:
      return null; // ไม่ต้องแสดง
  }
}
