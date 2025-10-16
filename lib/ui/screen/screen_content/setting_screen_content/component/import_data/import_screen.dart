import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../data/bloc/data_importing/import_bloc.dart';
import '../../../../../core/design_system/app_color.dart';
import 'import_page.dart';

class ImportScreen extends StatelessWidget {
  const ImportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ⬇️ reuse the global ImportBloc provided higher up (e.g., in MyApp)
    final importBloc = context.read<ImportBloc>();

    return BlocProvider.value(
      value: importBloc,
      child: BlocConsumer<ImportBloc, ImportState>(
        listenWhen: (prev, curr) => prev.error != curr.error,
        listener: (context, state) {
          if (state.error != null && state.error!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: AppColors.colorAlert1,
                duration: Duration(seconds: 3),
                behavior: SnackBarBehavior.floating
                ),
                
            );
          }
        },
        builder: (context, state) {
          final bloc = context.read<ImportBloc>();

          return ImportPage(
            nameValue: state.nameValue,
            onNameChanged: (v) => bloc.add(ImportNameChanged(v)),
            onConfirm: () => bloc.add(const ImportSubmitPressed()),
            isAdding: state.isAdding, // separate from import flow flags
          );
        },
      ),
    );
  }
}
