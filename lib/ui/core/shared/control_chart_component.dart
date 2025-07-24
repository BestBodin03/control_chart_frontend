import 'package:control_chart/domain/models/chart_data_point.dart';
import 'package:control_chart/ui/core/shared/dashed_line_painter.dart' show DashedLinePainter;
import 'package:control_chart/ui/core/shared/table_component.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
  
// final sampleData = [
//   ChartDataPoint(label: 'B06', value: 12),
//   ChartDataPoint(label: 'C17', value: 28),
//   ChartDataPoint(label: 'C24', value: 12),
//   ChartDataPoint(label: '630', value: 16),
//   ChartDataPoint(label: '901', value: 30),
//   ChartDataPoint(label: 'A30', value: 33),
//   ChartDataPoint(label: 'A05', value: 26),
//   ChartDataPoint(label: 'A11', value: 10),
//   ChartDataPoint(label: 'B30', value: 21),
//   ChartDataPoint(label: 'B06', value: 12),
//   ChartDataPoint(label: 'C17', value: 28),
//   ChartDataPoint(label: 'C24', value: 32),
// ];

// final controlLimits = ControlLimits(
//   usl: 32,  // Upper Specification Limit
//   ucl: 30,  // Upper Control Limit  
//   average: 19, // Average
//   lcl: 8,   // Lower Control Limit
//   lsl: 2,   // Lower Specification Limit
// );
  
class ControlChartComponent extends StatelessWidget {
  final List<ChartDataPoint>? dataPoints;
  final ControlLimits? controlLimits;
  final String xAxisLabel;
  final String yAxisLabel;
  final Color? dataLineColor;
  final Color? backgroundColor;
  final double? height;
  final double? width;

  const ControlChartComponent({
    super.key,
    this.dataPoints,
    this.controlLimits,
    this.xAxisLabel = 'Date',
    this.yAxisLabel = 'Attr.',
    this.dataLineColor = Colors.blue,
    this.backgroundColor = Colors.white,
    this.height = 300,
    this.width,
  });
  
  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
  
  FlGridData buildGridData() {
    return FlGridData(
      show: true,
      drawVerticalLine: true,
      drawHorizontalLine: true,
      horizontalInterval: (controlLimits!.usl - controlLimits!.lsl) / 6,
      verticalInterval: dataPoints!.length / 8,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: Colors.grey.shade300,
          strokeWidth: 0.5,
        );
      },
      getDrawingVerticalLine: (value) {
        return FlLine(
          color: Colors.grey.shade300,
          strokeWidth: 0.5,
        );
      },
    );
  }

  FlTitlesData buildTitlesData() {
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 24,
          interval: (controlLimits!.usl - controlLimits!.lsl) / 4,
          getTitlesWidget: (value, meta) {
            return Text(
              value.toStringAsFixed(1),
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 12,
              ),
            );
          },
        ),
        axisNameWidget: RotatedBox(
          quarterTurns: 3,
          child: Text(
            yAxisLabel,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          interval: dataPoints!.length > 10 ? dataPoints!.length / 8 : 1,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index >= 0 && index < dataPoints!.length) {
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  dataPoints![index].label,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 10,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        axisNameWidget: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            xAxisLabel,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  FlBorderData buildBorderData() {
    return FlBorderData(
      show: true,
      border: Border.all(
        color: Colors.black54,
        width: 1,
      ),
    );
  }

  List<LineChartBarData> buildLineBarsData() {
    return [
      LineChartBarData(
        spots: dataPoints!
            .asMap()
            .entries
            .map((entry) => FlSpot(entry.key.toDouble(), entry.value.value))
            .toList(),
        isCurved: false,
        color: dataLineColor,
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) {
            final value = dataPoints![index].value;
            Color dotColor = dataLineColor!;
            
            // Color dots based on control limits
            if (value > controlLimits!.usl || value < controlLimits!.lsl) {
              dotColor = Colors.red; // Out of control
            } else if (value > controlLimits!.ucl || value < controlLimits!.lcl) {
              dotColor = Colors.orange; // Warning zone
            }
            
            return FlDotCirclePainter(
              radius: 4,
              color: dotColor,
              strokeWidth: 2,
              strokeColor: Colors.white,
            );
          },
        ),
        belowBarData: BarAreaData(show: false),
      ),
    ];
  }

  ExtraLinesData buildControlLines() {
    return ExtraLinesData(
      horizontalLines: [
        // USL (Upper Specification Limit)
        HorizontalLine(
          y: controlLimits!.usl,
          color: Colors.red,
          strokeWidth: 2,
          dashArray: [5, 5],
          label: HorizontalLineLabel(
            show: true,
            alignment: Alignment.topRight,
            padding: const EdgeInsets.only(right: 8, top: 4),
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            labelResolver: (line) => 'USL = ${controlLimits!.usl.toStringAsFixed(2)}',
          ),
        ),
        
        // UCL (Upper Control Limit)
        HorizontalLine(
          y: controlLimits!.ucl,
          color: Colors.orange,
          strokeWidth: 1.5,
          dashArray: [3, 3],
          label: HorizontalLineLabel(
            show: true,
            alignment: Alignment.topRight,
            padding: const EdgeInsets.only(right: 8, top: 4),
            style: const TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            labelResolver: (line) => 'ULC = ${controlLimits!.ucl.toStringAsFixed(2)}',
          ),
        ),
        
        // Average Line
        HorizontalLine(
          y: controlLimits!.average,
          color: Colors.green,
          strokeWidth: 2,
          label: HorizontalLineLabel(
            show: true,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 8),
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            labelResolver: (line) => 'AVG = ${controlLimits!.average.toStringAsFixed(2)}',
          ),
        ),
        
        // LCL (Lower Control Limit)
        HorizontalLine(
          y: controlLimits!.lcl,
          color: Colors.orange,
          strokeWidth: 1.5,
          dashArray: [3, 3],
          label: HorizontalLineLabel(
            show: true,
            alignment: Alignment.bottomRight,
            padding: const EdgeInsets.only(right: 8, bottom: 4),
            style: const TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            labelResolver: (line) => 'LC = ${controlLimits!.lcl.toStringAsFixed(2)}',
          ),
        ),
        
        // LSL (Lower Specification Limit)
        HorizontalLine(
          y: controlLimits!.lsl,
          color: Colors.red,
          strokeWidth: 2,
          dashArray: [5, 5],
          label: HorizontalLineLabel(
            show: true,
            alignment: Alignment.bottomRight,
            padding: const EdgeInsets.only(right: 8, bottom: 4),
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            labelResolver: (line) => 'LSL = ${controlLimits!.lsl.toStringAsFixed(2)}',
          ),
        ),
      ],
    );
  }

  LineTouchData buildTouchData() {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        getTooltipColor: (touchedSpot) => Colors.black87,
        tooltipBorderRadius: BorderRadius.circular(8.0),
        getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
          return touchedBarSpots.map((barSpot) {
            final index = barSpot.x.toInt();
            if (index >= 0 && index < dataPoints!.length) {
              return LineTooltipItem(
                '${dataPoints![index].label}\n${dataPoints![index].value.toStringAsFixed(2)}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            }
            return null;
          }).whereType<LineTooltipItem>().toList();
        },
      ),
      handleBuiltInTouches: true,
    );
  }

  Widget buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        buildLegendItem('USL', Colors.red, true),
        buildLegendItem('ULC', Colors.orange, true),
        buildLegendItem('AVG', Colors.green, false),
        buildLegendItem('LC', Colors.orange, true),
        buildLegendItem('LSL', Colors.red, true),
        buildLegendItem('Data', dataLineColor!, false),
      ],
    );
  }

  Widget buildLegendItem(String label, Color color, bool isDashed) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 2,
          decoration: BoxDecoration(
            color: color,
            border: isDashed ? Border.all(color: color, width: 1) : null,
          ),
          child: isDashed
              ? CustomPaint(
                  painter: DashedLinePainter(color: color),
                )
              : null,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  double getMinY() {
    final dataMin = dataPoints!.map((e) => e.value).reduce((a, b) => a < b ? a : b);
    return [dataMin, controlLimits!.lsl].reduce((a, b) => a < b ? a : b) - 2;
  }

  double getMaxY() {
    final dataMax = dataPoints!.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    return [dataMax, controlLimits!.usl].reduce((a, b) => a > b ? a : b) + 2;
  }

}
