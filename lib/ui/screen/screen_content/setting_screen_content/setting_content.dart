import 'package:control_chart/apis/settings/setting_apis.dart';
import 'package:control_chart/data/bloc/setting_profile/setting_profile_bloc.dart';
import 'package:control_chart/data/cubit/setting_form/setting_form_cubit.dart';
import 'package:control_chart/data/cubit/setting_form/setting_form_state.dart';
import 'package:control_chart/domain/models/setting.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/shared/setting_form.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/component/import_data/import_page.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/component/profile/profile.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/component/profile/profile_page.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/setting_var.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'component/import_data/import_screen.dart';

enum StatusFilter { all, active, inactive }
enum SortBy { name, date }
enum TabKey { profiles, importData }

class SettingContent extends StatefulWidget {
  const SettingContent({super.key});

  @override
  State<SettingContent> createState() => _SettingContentState();

  
}


class _SettingContentState extends State<SettingContent> {
  TabKey _tab = TabKey.profiles;

  String? _fileName;
  final String _dropdown1 = '';
  final String _dropdown2 = '';

  Profile _toProfile(Setting s) {
    const displayTypeMap = {
      'FURNACE': 'เตา',
      'FURNACE_CP': 'เตา/เลขแมต',
      'CP': 'เลขแมต',
    };

    return Profile(
      profileId: s.id,
      name: s.settingProfileName,
      displayType: displayTypeMap[s.displayType.name] ?? s.displayType.name,
      active: s.isUsed,
      createdAt: s.createdAt,
      profileDisplayType: s.displayType,
      chartChangeInterval: s.generalSetting.chartChangeInterval,
      ruleSelected: s.generalSetting.nelsonRule.map(RuleSelected.fromNelson).toList(),
      specifics: s.specificSetting.map(SpecificSettingState.fromModel).toList(),
      status: SubmitStatus.idle, // ✅ แทน null ถ้า field เป็น non-nullable
      error: null,
    );

  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.colorBg),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TopBar(
              tab: _tab,
              onSelect: (t) => setState(() => _tab = t),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 32, 32),
              child: switch (_tab) {
                TabKey.profiles => BlocBuilder<SettingProfileBloc, SettingProfileState>(
                  builder: (context, state) {
                    if (state.isLoading || state.isInitial) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.isFailed) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(state.errorMessage ?? 'เกิดข้อผิดพลาด'),
                            const SizedBox(height: 8),
                            FilledButton(
                              onPressed: () => context
                                  .read<SettingProfileBloc>()
                                  .add(const LoadAllSettingProfiles()),
                              child: const Text('ลองใหม่'),
                            ),
                          ],
                        ),
                      );
                    }

                    final items = state.profiles.map(_toProfile).toList();
                    return ProfilesPage(
                      items: items,
                      onToggleActive: (id, v) {
                        // context.read<SettingProfileBloc>().add(ToggleSettingActive(id, v));
                      },
                      onAddProfile: () {
                        final formCubit = context.read<SettingFormCubit>(); // instance from ancestor
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: formCubit,           // pass the SAME instance
                              child: const SettingForm(), // <-- your form widget
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                TabKey.importData => const Align(
                  alignment: Alignment.centerLeft,
                  child: ImportScreen(),   // <<< ใช้ตัวนี้
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}
