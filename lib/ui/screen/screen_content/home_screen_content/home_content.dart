
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/data/shared_preference/tv_setting_profile_state.dart';
import 'package:control_chart/domain/models/chart_data_point.dart';
import 'package:control_chart/domain/types/chart_filter_query.dart';
import 'package:control_chart/ui/core/shared/medium_control_chart/cde_cdt/help.dart';
import 'package:control_chart/ui/core/shared/medium_control_chart/surface_hardness/control_chart_template.dart';
import 'package:control_chart/ui/core/shared/medium_control_chart/surface_hardness/help.dart';
import 'package:control_chart/ui/core/shared/searching_form.dart';
import 'package:control_chart/ui/screen/screen_content/home_screen_content/home_content_var.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeContent extends StatefulWidget {
  final HomeContentVar? settingProfile;
  const HomeContent({
    super.key,
    this.settingProfile});

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

            // final String uniqueKey =
            //     '${q.startDate?.millisecondsSinceEpoch ?? 0}-'
            //     '${q.endDate?.millisecondsSinceEpoch ?? 0}-'
            //     '${q.furnaceNo ?? ''}-'
            //     '${q.materialNo ?? ''}-';
            final queryParam = const HomeContentVar(); // ใช้ค่าที่ส่งมา
            final uniqueKey = '${queryParam.startDate?.millisecondsSinceEpoch ?? 0}-'
                '${queryParam.endDate?.millisecondsSinceEpoch ?? 0}-'
                '${queryParam.furnaceNo ?? ''}-${queryParam.materialNo ?? ''}-';

            print(uniqueKey);



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
                        child: buildChartsSectionSurfaceHardness(queryParam, searchState),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // กราฟขวา ล็อก width/height ให้พอดีพื้นที่
                    SizedBox(
                      width: halfW,
                      height: h,
                      child: _ChartFillBox(
                        child: buildChartsSectionCdeCdt(queryParam, searchState),
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

