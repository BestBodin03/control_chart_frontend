class ChartDataPoint {
  final String label;
  final double value;

  ChartDataPoint({
    required this.label,
    required this.value,
  });
}

class ControlLimits {
  final double usl; // Upper Specification Limit
  final double ucl; // Upper Control Limit
  final double average; // Average/Center Line
  final double lcl; // Lower Control Limit
  final double lsl; // Lower Specification Limit

  ControlLimits({
    required this.usl,
    required this.ucl,
    required this.average,
    required this.lcl,
    required this.lsl,
  });
}