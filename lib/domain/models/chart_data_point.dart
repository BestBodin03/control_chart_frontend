class ChartDataPoint {
  final DateTime collectDate;
  final String label;
  final String fullLabel;
  final String? furnaceNo;
  final String? matNo;
  final double value;
  final double mrValue;

  ChartDataPoint({
    required this.collectDate,
    required this.label,
    required this.fullLabel,
    this.furnaceNo,
    this.matNo,
    required this.value,
    required this.mrValue
  });
}

class ChartDataPointCdeCdt {
  final DateTime collecDate;
  final String label;
  final String fullLabel;
  final String? furnaceNo;
  final String? matNo;
  final double value;
  final double mrValue;

  ChartDataPointCdeCdt({
    required this.collecDate,
    required this.label,
    required this.fullLabel,
    this.furnaceNo,
    this.matNo,
    this.value = 0.0,
    this.mrValue = 0.0
  });
}
