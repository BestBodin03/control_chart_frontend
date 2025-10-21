// import_page.dart
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';
import 'package:control_chart/ui/core/shared/form_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../data/bloc/data_importing/import_bloc.dart';

class ImportPage extends StatelessWidget {
  const ImportPage({
    super.key,
    this.nameValue = '',
    required this.onNameChanged,
    required this.onConfirm,
    this.isAdding = false, // only for the Confirm button
  });

  final String nameValue;
  final ValueChanged<String> onNameChanged;
  final VoidCallback onConfirm;
  final bool isAdding;

  @override
  Widget build(BuildContext context) {
    // Centralized messages via SnackBar only
    return BlocListener<ImportBloc, ImportState>(
      listenWhen: (prev, next) =>
          prev.snackId != next.snackId && (next.snackMsg?.isNotEmpty ?? false),
      listener: (context, st) {
        final theme = Theme.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  st.snackIsError ? Icons.error_outline : Icons.check_circle_outline,
                  size: 24,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(
                  st.snackMsg!,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold
                  ))),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: st.snackIsError ? AppColors.colorAlert1 : AppColors.colorSuccess1,
            duration: const Duration(seconds: 3),
          ),
        );
      },
      child: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    final st = context.watch<ImportBloc>().state;

    final bool importBusy = st.isWaiting || st.isPolling;
    final bool showProgress = importBusy;
    final bool hasPercent = st.isPolling && st.importData != null;
    final int percent = (st.importData?.percent ?? 0).clamp(0, 100);

    return LayoutBuilder(
      builder: (context, c) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Import block ───────────────────────────────
            SizedBox(
              width: 360,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.6),
                      blurRadius: 2,
                      offset: const Offset(-5, -5),
                    ),
                    BoxShadow(
                      color: AppColors.colorBrandTp.withValues(alpha: 0.4),
                      blurRadius: 4,
                      offset: const Offset(5, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ⬇️ Title + status chip
                      Row(
                        children: [
                          buildSectionTitle('Getting Data'),
                          const Spacer(),
                          _buildImportStatusChip(st, percent: percent),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (showProgress) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            minHeight: 16,
                            value: hasPercent ? (percent / 100.0) : null, // null = indeterminate
                            backgroundColor: Colors.grey.shade100,
                            color: AppColors.colorBrand,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          hasPercent
                              ? 'Getting Current Data... $percent%'
                              : 'Getting Current Data...',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                      ],

                      SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: importBusy
                              ? null
                              : () {
                                  context.read<ImportBloc>().add(const ImportStartPressed());
                                },
                          icon: importBusy
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(Icons.replay_rounded, size: 20),
                          label: Text(
                            importBusy ? 'Getting Current Data...' : 'Get Current Data',
                            style: AppTypography.textBody2WBold,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.colorBrand,
                            foregroundColor: Colors.white,
                            elevation: 8,
                            shadowColor: const Color.fromARGB(255, 54, 48, 141)
                                .withValues(alpha: 0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ── Add material form ──────────────────────────
            SizedBox(
              width: 360,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.6),
                      blurRadius: 2,
                      offset: const Offset(-5, -5),
                    ),
                    BoxShadow(
                      color: AppColors.colorBrandTp.withValues(alpha: 0.4),
                      blurRadius: 4,
                      offset: const Offset(5, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildSectionTitle('Add New Material No.'),
                      const SizedBox(height: 16),
                      buildTextField(
                        value: nameValue,
                        hintText: 'Material No. | Example: 24001234',
                        onChanged: onNameChanged,
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: 360,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: isAdding ? null : onConfirm,
                            icon: isAdding
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.check_rounded, size: 20),
                            label: Text(
                              isAdding ? 'Importing...' : 'Import',
                              style: AppTypography.textBody2WBold,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.colorSuccess1,
                              foregroundColor: Colors.white,
                              elevation: 8,
                              shadowColor:
                                  AppColors.colorSuccess1.withValues(alpha: 0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ---------- Helpers ----------

  Widget _buildImportStatusChip(ImportState st, {required int percent}) {
    final d = st.importData;
    final bool running = st.isWaiting || st.isPolling;
    final bool done = d?.isDone == true || d?.finishedAt != null;
    final bool hasError = (st.error?.isNotEmpty ?? false) || (d?.hasError ?? false);

    String text;
    Color bg;
    const Color fg = Colors.white;

if (running) {
    // ✅ โชว์ % เฉพาะช่วงโพลล์ และต้อง > 0
    final bool showPct = st.isPolling && percent > 0;
    text = showPct ? 'Getting… $percent%' : 'Getting…';
    bg = AppColors.colorBrand;

  } else if (d != null && (d.isDone || d.finishedAt != null)) {
    if (hasError) {
      final msg = (st.error?.isNotEmpty ?? false)
          ? st.error!
          : ((d.errors.isNotEmpty) ? d.errors.first : 'Failed');
      text = _truncate(msg, 24);
      bg = AppColors.colorAlert1;
    } else {
      text = 'Success';
      bg = AppColors.colorSuccess1;
    }

  } else {
    text = 'Ready';
    bg = Colors.grey.shade500;
  }


    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  String _truncate(String s, int max) {
    if (s.length <= max) return s;
    return '${s.substring(0, max - 1)}…';
  }
}
