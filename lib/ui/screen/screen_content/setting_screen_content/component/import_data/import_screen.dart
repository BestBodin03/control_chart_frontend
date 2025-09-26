import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../data/bloc/data_importing/import_bloc.dart';
import 'import_page.dart';

class ImportScreen extends StatelessWidget {
  const ImportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ImportBloc(),
      child: BlocConsumer<ImportBloc, ImportState>(
        listenWhen: (prev, curr) => prev.error != curr.error,
        listener: (context, state) {
          if (state.error != null && state.error!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
        },
        builder: (context, state) {
          final bloc = context.read<ImportBloc>();

          return ImportPage(
            // ถ้ายังไม่ใช้พาร์ตเลือกไฟล์จริง ใส่ null/{} ไว้ก่อนได้
            nameValue: state.nameValue,
            onNameChanged: (v) => bloc.add(ImportNameChanged(v)),

            // ปุ่ม “ยืนยัน” (ล่าง) — ถ้ายังไม่มีอีเวนต์แยก ใช้เริ่ม import เหมือนปุ่มบนไปก่อน
            onConfirm: () => bloc.add(const ImportSubmitPressed()),

            // ปิดปุ่มตอนกำลังดำเนินการ/กำลังโพลล์
            isSubmitting: state.isBusy,
          );
        },
      ),
    );
  }
}
