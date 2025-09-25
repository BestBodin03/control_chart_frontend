/// searching_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:control_chart/utils/app_route.dart';
import 'package:control_chart/ui/screen/screen_content/home_screen_content/home_content_var.dart';
import 'package:control_chart/data/bloc/search_chart_details/search_bloc.dart';
import 'package:control_chart/ui/screen/screen_content/searching_screen_content/searching_content.dart';

class SearchingScreen extends StatelessWidget {
  const SearchingScreen({super.key});
  @override
  Widget build(BuildContext context) => const _SearchingScreenBody();
}

class _SearchingScreenBody extends StatefulWidget {
  const _SearchingScreenBody({super.key});
  @override
  State<_SearchingScreenBody> createState() => _SearchingScreenBodyState();
}

class _SearchingScreenBodyState extends State<_SearchingScreenBody> {
  HomeContentVar? _frozen; // snapshot ที่รับมา "ครั้งเดียว"

  @override
  void initState() {
    super.initState();
    // รับถ้ามีค่าอยู่ก่อนแล้ว
    _consumeSnapshot();
    // เผื่อมีการคลิกใหม่ภายหลัง (แต่ละคลิกรับครั้งเดียว)
    AppRoute.instance.searchSnapshot.addListener(_consumeSnapshot);
  }

  @override
  void dispose() {
    AppRoute.instance.searchSnapshot.removeListener(_consumeSnapshot);
    super.dispose();
  }

  void _consumeSnapshot() {
    final v = AppRoute.instance.searchSnapshot.value;
    if (v == null) return;
    _frozen = v;                                // เก็บไว้ใช้ภายในหน้า Search เท่านั้น
    AppRoute.instance.searchSnapshot.value = null; // ตัดสาย one-shot

    // ยิงโหลดตาม snapshot
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SearchBloc>().add(LoadFilteredChartData(
        startDate:  v.startDate,
        endDate:    v.endDate,
        furnaceNo:  v.furnaceNo,
        materialNo: v.materialNo,
      ));
    });

    if (mounted) setState(() {}); // ให้ SearchingContent เห็นค่าเริ่ม (ถ้าจำเป็น)
  }

  @override
  Widget build(BuildContext context) {
    // ส่ง snapshot ให้ฟอร์ม (ถ้า SearchingForm ใช้ initialProfile ตั้งค่า UI)
    return SearchingContent(initialProfile: _frozen);
  }
}
