
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/domain/models/chart_data_point.dart';
import 'package:control_chart/ui/core/shared/medium_control_chart/cde_cdt/help.dart';
import 'package:control_chart/ui/core/shared/medium_control_chart/surface_hardness/control_chart_template.dart';
import 'package:control_chart/ui/core/shared/medium_control_chart/surface_hardness/help.dart';
import 'package:control_chart/ui/core/shared/searching_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  HomeContentState createState() => HomeContentState();
}

class HomeContentState extends State<HomeContent> {

  @override
  Widget build(BuildContext context) {
    return Padding(
  padding: const EdgeInsets.fromLTRB(24,0,24,8),
  child: Column(
    children: [
      // โซนกราฟกินพื้นที่ที่เหลือทั้งหมด
      Expanded(
        child: BlocBuilder<SearchBloc, SearchState>(
          builder: (context, searchState) {
            if (searchState.status == SearchStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (searchState.status == SearchStatus.failure) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Error: ${searchState.errorMessage}'),
                    ElevatedButton(
                      onPressed: () {
                        context.read<SearchBloc>().add(
                              LoadFilteredChartData(
                                startDate: DateTime.now()
                                    .subtract(const Duration(days: 30)),
                                endDate: DateTime.now(),
                              ),
                            );
                      },
                      child: const Text('ลองใหม่'),
                    ),
                  ],
                ),
              );
            }
            if (searchState.controlChartStats == null) {
              return const Center(child: Text('No control chart data'));
            }

            final q = searchState.currentQuery;
            final uniqueKey = '${q.startDate?.day}-'
                '${q.endDate?.millisecondsSinceEpoch}-'
                '${q.furnaceNo}-'
                '${q.materialNo}-';

            // ✅ ใช้ LayoutBuilder เพื่อได้ขนาดจริงของพื้นที่วาด
            return LayoutBuilder(
              key: ValueKey(uniqueKey),
              builder: (context, constraints) {
                // เว้นช่องว่างระหว่างกราฟ 16px
                final gap = 16.0;
                final halfW = (constraints.maxWidth - gap) / 2;
                final h = constraints.maxHeight; // สูงเท่าพื้นที่ Expanded ให้มา

                return Row(
                  children: [
                    // กราฟซ้าย ล็อก width/height ให้พอดีพื้นที่
                    SizedBox(
                      width: halfW,
                      height: h,
                      child: _ChartFillBox(
                        child: buildChartsSectionSurfaceHardness(searchState),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // กราฟขวา ล็อก width/height ให้พอดีพื้นที่
                    SizedBox(
                      width: halfW,
                      height: h,
                      child: _ChartFillBox(
                        child: buildChartsSectionCdeCdt(searchState),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),

      const SizedBox(height: 16),
      // ถ้ามีฟอร์มค่อยใส่ด้านล่าง
      // const SearchingForm(),
    ],
  ),
);

    // );
  }
}

/// บังคับให้ลูกกินพื้นที่เต็มและตัดส่วนเกิน (กันกรณีลูกมี ScrollView ภายใน)
class _ChartFillBox extends StatelessWidget {
  const _ChartFillBox({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: SizedBox.expand(
        child: child,
      ),
    );
  }
}

