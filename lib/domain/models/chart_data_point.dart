class ChartDataPoint {
  final DateTime collectDate;
  final String label;
  final String fullLabel;
  final String? furnaceNo;
  final String? matNo;
  final double value;
  final double mrValue;
  final bool isViolatedR3;
  final bool isViolatedR1BeyondLCL;
  final bool isViolatedR1BeyondUCL;
  final bool isViolatedR1BeyondLSL;
  final bool isViolatedR1BeyondUSL;

  ChartDataPoint({
    required this.collectDate,
    required this.label,
    required this.fullLabel,
    this.furnaceNo,
    this.matNo,
    required this.value,
    required this.mrValue,
    required this.isViolatedR3,
    required this.isViolatedR1BeyondLCL,
    required this.isViolatedR1BeyondUCL,
    required this.isViolatedR1BeyondLSL,
    required this.isViolatedR1BeyondUSL

  });
}

class ChartDataPointCdeCdt {
  final DateTime collectDate;
  final String label;
  final String fullLabel;
  final String? furnaceNo;
  final String? matNo;
  final double value;
  final double mrValue;
  final bool isViolatedR3;

  ChartDataPointCdeCdt({
    required this.collectDate,
    required this.label,
    required this.fullLabel,
    this.furnaceNo,
    this.matNo,
    this.value = 0.0,
    this.mrValue = 0.0,
    required this.isViolatedR3
  });
}
