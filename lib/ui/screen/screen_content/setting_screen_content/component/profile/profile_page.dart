// profiles_page.dart (เฉพาะส่วนสำคัญ)
import 'package:control_chart/apis/settings/setting_apis.dart';
import 'package:control_chart/data/bloc/setting_profile/setting_profile_bloc.dart';
import 'package:control_chart/data/cubit/setting_cubit.dart';
import 'package:control_chart/data/cubit/setting_cubit_state.dart';
import 'package:control_chart/data/cubit/setting_form/setting_form_cubit.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/shared/pill_button.dart';
import 'package:control_chart/ui/core/shared/setting_form.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/component/profile/profile.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/component/profile/profile_card.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/component/profile/profile_detail_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfilesPage extends StatelessWidget {
  const ProfilesPage({
    super.key,
    required this.items,
    required this.onToggleActive,
    required this.onAddProfile,
  });

  final List<Profile> items;
  final void Function(String id, bool v) onToggleActive;
  final VoidCallback onAddProfile;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DeleteProfilesCubit(apis: SettingApis()),
      child: _ProfilesBody(
        items: items,
        onToggleActive: onToggleActive,
        onAddProfile: onAddProfile,
      ),
    );
  }
}

class _ProfilesBody extends StatelessWidget {
  const _ProfilesBody({
    required this.items,
    required this.onToggleActive,
    required this.onAddProfile,
  });

  final List<Profile> items;
  final void Function(String id, bool v) onToggleActive;
  final VoidCallback onAddProfile;

  @override
  Widget build(BuildContext context) {
    return BlocListener<DeleteProfilesCubit, DeleteProfilesState>(
      listenWhen: (p, c) => p.status != c.status || p.deleteMode != c.deleteMode,
      listener: (context, state) {
        if (state.status == SubmitStatus.success) {
          context.read<SettingProfileBloc>().add(const RefreshSettingProfiles());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ลบโปรไฟล์สำเร็จ')),
          );
        } else if (state.status == SubmitStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error ?? 'ลบโปรไฟล์ไม่สำเร็จ')),
          );
        }
      },
      child: LayoutBuilder(builder: (ctx, c) {
        const double minCardWidth = 280.0;
        const double maxCardWidth = 360.0;
        const double gap = 16.0;
        const int maxCols = 6;
        const int minCols = 1;

        int cols = ((c.maxWidth + gap) / (minCardWidth + gap)).floor().clamp(minCols, maxCols);
        double widthFor(int candidateCols) {
          final totalGap = gap * (candidateCols - 1);
          return (c.maxWidth - (totalGap + 16)) / candidateCols;
        }
        double cardWidth = widthFor(cols);
        while (cardWidth > maxCardWidth && cols < maxCols) {
          cols++; cardWidth = widthFor(cols);
        }
        while (cardWidth < minCardWidth && cols > minCols) {
          cols--; cardWidth = widthFor(cols);
        }

        final deleteCubit = context.watch<DeleteProfilesCubit>();
        final deleteState = deleteCubit.state;

        return Column(
          children: [
            Row(
              spacing: 16,
              children: [
                // เพิ่มโปรไฟล์ (เหมือนเดิม)
                PillButton(
                  label: 'เพิ่มโปรไฟล์',
                  labelSize: 14,
                  leading: Icons.add,
                  selected: true,
                  solid: true,
                  onTap: () async {
                    final formCubit = context.read<SettingFormCubit>();
                    formCubit.resetForm();

                    final saved = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => BlocProvider.value(
                        value: formCubit,
                        child: Dialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.colorBgGrey,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(color: AppColors.colorBrandTp.withValues(alpha: 0.4), blurRadius: 15, offset: const Offset(5, 5)),
                              ],
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: SettingForm(),
                            ),
                          ),
                        ),
                      ),
                    );
                    if (saved == true) {
                      context.read<SettingProfileBloc>().add(const RefreshSettingProfiles());
                    }
                  },
                ),

                // ลบโปรไฟล์: ครั้งที่ 1 → เข้าโหมดลบ, ครั้งที่ 2 → ยืนยันลบ
                PillButton(
                  label: deleteState.deleteMode
                      ? 'ยืนยันการลบ (${deleteState.selected.length})'
                      : 'ลบโปรไฟล์',
                  labelSize: 14,
                  leading: deleteState.deleteMode ? Icons.check_circle : Icons.remove_circle_rounded,
                  selected: true,
                  solid: true,
                  bg: AppColors.colorAlert1,
                  onTap: () async {
                    final cubit = context.read<DeleteProfilesCubit>();
                    if (!deleteState.deleteMode) {
                      cubit.toggleDeleteMode(); // เข้าโหมดลบ
                      return;
                    }

                    // โหมดลบอยู่แล้ว → เปิด confirm
                    if (deleteState.selected.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('โปรดเลือกโปรไฟล์อย่างน้อย 1 รายการ')),
                      );
                      return;
                    }

                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('ยืนยันการลบ'),
                        content: Text('ต้องการลบ ${deleteState.selected.length} โปรไฟล์หรือไม่?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ยกเลิก')),
                          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('ยืนยัน')),
                        ],
                      ),
                    );

                    if (ok == true) {
                      final success = await cubit.removeSelected();
                      if (success && context.mounted) {
                        // รีเฟรชใน Listener แล้ว
                      }
                    }
                  },
                ),

                if (deleteState.deleteMode)
                  // ปุ่มยกเลิกโหมดลบ
                  PillButton(
                    label: 'ยกเลิก',
                    labelSize: 14,
                    leading: Icons.close,
                    selected: true,
                    solid: true,
                    onTap: () => context.read<DeleteProfilesCubit>().toggleDeleteMode(),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(0, 0, 16, 16),
                child: Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: items.map((p) {
                    bool hasAnotherActive() => items.any((x) => x.active && x.profileId != p.profileId);
                    final selected = deleteState.selected.contains(p.profileId);
                    return SizedBox(
                      width: cardWidth,
                      child: ProfileCard(
                        profile: p,
                        onToggle: (v) => onToggleActive(p.profileId, v),
                        hasAnotherActive: hasAnotherActive,
                        onTap: () => _showProfileDetails(context, p),
                        onEdit: () => _showEditProfile(context, p),
                        // 👇 ใหม่
                        deleteMode: deleteState.deleteMode,
                        selected: selected,
                        onSelectedChanged: (v) {
                          context.read<DeleteProfilesCubit>().toggleSelected(p.profileId);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ========== helpers เดิม ==========
void _showProfileDetails(BuildContext context, Profile profile) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ProfileDetailSheet(profile: profile),
  );
}

void _showEditProfile(BuildContext context, Profile profile) async {
  final formCubit = context.read<SettingFormCubit>();
  formCubit
    ..updateSettingProfileId(profile.profileId)
    ..updateSettingProfileName(profile.name)
    ..updateDisplayType(profile.profileDisplayType!)
    ..updateChartChangeInterval(profile.chartChangeInterval!)
    ..updateRuleSelected(profile.ruleSelected!)
    ..updateSpecifics(profile.specifics!)
    ..updateIsUsed(profile.active);

  final saved = await showDialog<bool>(
    context: context,
    builder: (ctx) => BlocProvider.value(
      value: formCubit,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: SingleChildScrollView(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.colorBgGrey,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: AppColors.colorBrandTp.withValues(alpha: 0.4), blurRadius: 15, offset: const Offset(5, 5))],
            ),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: SettingForm(),
            ),
          ),
        ),
      ),
    ),
  );

  if (saved == true && context.mounted) {
    context.read<SettingProfileBloc>().add(const RefreshSettingProfiles());
  }
}
