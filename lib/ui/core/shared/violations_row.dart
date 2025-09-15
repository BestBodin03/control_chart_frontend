// import 'package:control_chart/domain/models/control_chart_stats.dart';
// import 'package:control_chart/ui/core/design_system/app_typography.dart';
// import 'package:flutter/material.dart';

// class ViolationsRow extends StatelessWidget {
//   const ViolationsRow({super.key, required this.dataPoints});
//   final List<DataPoint>? dataPoints;

//   @override
//   Widget build(BuildContext context) {
//     final v = _computeViolations(dataPoints ?? const <DataPoint>[]);

//     return Wrap(
//       spacing: 12,
//       runSpacing: 6,
//       crossAxisAlignment: WrapCrossAlignment.center,
//       children: [
//         _ViolationBadge(
//           label: 'Beyond Control Limit',
//           violated: v.beyondCL,
//           // ถ้าอยากโชว์จำนวน ให้เติม subtitle: '(${v.r1clCount})'
//         ),
//         _ViolationBadge(
//           label: 'Beyond Spec',
//           violated: v.beyondSpec,
//           // subtitle: '(${v.r1specCount})',
//         ),
//         _ViolationBadge(
//           label: 'Trend',
//           violated: v.trend,
//           // subtitle: '(${v.r3Count})',
//         ),
//       ],
//     );
//   }

//   _ViolationSummary _computeViolations(List<DataPoint> points) {
//     int r1cl = 0;     // LCL/UCL
//     int r1spec = 0;   // LSL/USL
//     int r3 = 0;       // Trend

//     for (final p in points) {
//       if (p.isViolatedR1BeyondLCL || p.isViolatedR1BeyondUCL) r1cl++;
//       if (p.isViolatedR1BeyondLSL || p.isViolatedR1BeyondUSL) r1spec++;
//       if (p.isViolatedR3) r3++;
//     }

//     return _ViolationSummary(
//       beyondCL: r1cl > 0,
//       beyondSpec: r1spec > 0,
//       trend: r3 > 0,
//       r1clCount: r1cl,
//       r1specCount: r1spec,
//       r3Count: r3,
//     );
//   }
// }

// class _ViolationSummary {
//   final bool beyondCL;
//   final bool beyondSpec;
//   final bool trend;
//   final int r1clCount;
//   final int r1specCount;
//   final int r3Count;
//   const _ViolationSummary({
//     required this.beyondCL,
//     required this.beyondSpec,
//     required this.trend,
//     required this.r1clCount,
//     required this.r1specCount,
//     required this.r3Count,
//   });
// }

// class _ViolationBadge extends StatelessWidget {
//   const _ViolationBadge({
//     super.key,
//     required this.label,
//     required this.violated,
//     this.subtitle,
//     this.okColor = const Color(0xFF16A34A),   // green-600
//     this.badColor = const Color(0xFFDC2626),  // red-600
//   });

//   final String label;
//   final bool violated;
//   final String? subtitle;
//   final Color okColor;
//   final Color badColor;

//   @override
//   Widget build(BuildContext context) {
//     final Color fill = violated ? badColor : okColor;
//     final IconData icon = violated ? Icons.close : Icons.check;

//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         // วงกลม + ไอคอน
//         Container(
//           width: 18,
//           height: 18,
//           decoration: BoxDecoration(
//             color: fill,
//             shape: BoxShape.circle,
//             boxShadow: [
//               BoxShadow(
//                 color: fill.withOpacity(0.25),
//                 blurRadius: 4,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Icon(icon, size: 12, color: Colors.white),
//         ),
//         const SizedBox(width: 6),

//         // ข้อความ
//         Text(
//           subtitle == null ? label : '$label $subtitle',
//           style: AppTypography.textBody3B, // ใช้สไตล์ของคุณ
//         ),
//       ],
//     );
//   }
// }
