import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/domain/models/chart_data_point.dart';
import 'package:control_chart/domain/models/control_chart_stats.dart';
import 'package:intl/intl.dart';

import '../../../../ui/core/shared/fg_last_four_chars.dart';

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
        // fgNo: fgNoLast4(chartDetail.fgNo),
        fgNo: chartDetail.fgNo,
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
/// - เลือกชุดค่า (value/mr) ตามชนิดที่เลือก
/// - เติม flag รายจุด: R3, R1 Beyond LCL/UCL/LSL/USL (ใช้สำหรับจุดสี/tooltip)
List<ChartDataPointCdeCdt> get chartDataPointsCdeCdt {
  final stats = controlChartStats;
  if (stats == null) return const <ChartDataPointCdeCdt>[];

  // helper: เลือกค่า/อาร์เรย์ตามชนิดที่เลือก (CDE/CDT/Compound)
  T? _sel<T>(T? cde, T? cdt, T? comp) {
    switch (stats.secondChartSelected) {
      case SecondChartSelected.cde:
        return cde;
      case SecondChartSelected.cdt:
        return cdt;
      case SecondChartSelected.compoundLayer:
        return comp;
      case SecondChartSelected.na:
      default:
        return null;
    }
  }

  // -------- values / MR ตามชนิดที่เลือก --------
  final List<double> values = _sel<List<double>>(
        stats.cdeChartSpots,
        stats.cdtChartSpots,
        stats.compoundLayerChartSpots,
      ) ??
      const <double>[];

  final List<double> mrValues = _sel<List<double>>(
        stats.cdeMrChartSpots,
        stats.cdtMrChartSpots,
        stats.compoundLayerMrChartSpots,
      ) ??
      const <double>[];

  // -------- per-point nelson flags ตามชนิดที่เลือก --------
  // NOTE: ปรับชื่อฟิลด์ด้านล่างให้ตรงกับโมเดลจริงของคุณ
  // ตัวอย่างนี้สมมติว่ามี stats.controlChartSpots?.cde / .cdt / .compoundLayer
  final List<dynamic> pointFlags = _sel<List<dynamic>>(
        stats.controlChartSpots?.cde,
        stats.controlChartSpots?.cdt,
        stats.controlChartSpots?.compoundLayer,
      ) ??
      const <dynamic>[];

  // ไม่มีการเลือก (หรือเลือก NA) -> ไม่โชว์
  if (stats.secondChartSelected == SecondChartSelected.na) {
    return const <ChartDataPointCdeCdt>[];
  }

  // -------- map chartDetails -> ChartDataPointCdeCdt --------
  return chartDetails.asMap().entries.map((entry) {
    final i = entry.key;
    final d = entry.value;

    final dt = d.chartGeneralDetail.collectedDate;

    // ปลอดภัยเรื่อง length ทุกอาร์เรย์
    final double v   = (i < values.length)   ? values[i]   : 0.0;
    final double mv  = (i < mrValues.length) ? mrValues[i] : 0.0;

    // flags ต่อจุด (fall back เป็น false ถ้าไม่มี/เกินช่วง)
    bool isR3   = false;
    bool r1LCL  = false;
    bool r1UCL  = false;
    bool r1LSL  = false;
    bool r1USL  = false;

    if (i < pointFlags.length && pointFlags[i] != null) {
      // ปรับ field name ให้ตรงกับของจริงใน controlChartSpots ของคุณ
      final pf = pointFlags[i];
      // ตัวอย่างฟิลด์ที่ใช้กับ Surface:
      //   .isViolatedR3, .isViolatedR1BeyondLCL, .isViolatedR1BeyondUCL,
      //   .isViolatedR1BeyondLSL, .isViolatedR1BeyondUSL
      isR3  = (pf.isViolatedR3               == true);
      r1LCL = (pf.isViolatedR1BeyondLCL      == true);
      r1UCL = (pf.isViolatedR1BeyondUCL      == true);
      r1LSL = (pf.isViolatedR1BeyondLSL      == true);
      r1USL = (pf.isViolatedR1BeyondUSL      == true);
    }

    return ChartDataPointCdeCdt(
      collectDate: dt,
      // fgNo: fgNoLast4(d.fgNo),
      fgNo: d.fgNo,
      label: DateFormat('dd/MM').format(dt),
      fullLabel:
          "${dt.day.toString().padLeft(2, '0')}/"
          "${dt.month.toString().padLeft(2, '0')}/"
          "${dt.year.toString().padLeft(4, '0')}",
      furnaceNo: d.chartGeneralDetail.furnaceNo.toString(),
      matNo: d.cpNo,
      value: v,
      mrValue: mv,
      isViolatedR3: isR3,
      // ✅ เติม R1 flags ให้ครบ เพื่อให้จุดเปลี่ยนสี/tooltip ถูกต้อง
      isViolatedR1BeyondLCL: r1LCL,
      isViolatedR1BeyondUCL: r1UCL,
      isViolatedR1BeyondLSL: r1LSL,
      isViolatedR1BeyondUSL: r1USL,
    );
  }).toList();
}
}