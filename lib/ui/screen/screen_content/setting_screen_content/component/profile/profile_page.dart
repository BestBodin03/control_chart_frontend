import 'package:control_chart/data/bloc/setting_profile/setting_profile_bloc.dart';
import 'package:control_chart/data/cubit/setting_form/setting_form_cubit.dart';
import 'package:control_chart/data/cubit/setting_form/setting_form_state.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/shared/pill_button.dart';
import 'package:control_chart/ui/core/shared/setting_form.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/component/profile/profile.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/component/profile/profile_card.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/component/profile/profile_detail_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfilesPage extends StatefulWidget {
  const ProfilesPage({
    super.key,
    required this.items,
    required this.onToggleActive,
    required this.onAddProfile,
  });

  final List<Profile> items;
  final void Function(String id, bool v) onToggleActive;

  // Left button
  final VoidCallback onAddProfile;

  @override
  State<ProfilesPage> createState() => _ProfilesPageState();
}

class _ProfilesPageState extends State<ProfilesPage> {
  bool _deleteMode = false;
  final Set<String> _selectedIds = <String>{};

  void _toggleDeleteMode() {
    setState(() {
      _deleteMode = !_deleteMode;
      if (!_deleteMode) _selectedIds.clear();
    });
  }

  void _toggleSelected(String id, bool selected) {
    setState(() {
      if (selected) {
        _selectedIds.add(id);
      } else {
        _selectedIds.remove(id);
      }
    });
  }

  bool _hasAnotherActiveExcept(String id) {
    return widget.items.any((x) => x.active && x.profileId != id);
  }

  // Future<bool?> _confirmDelete(BuildContext context, int count) {
  //   return showDialog<bool>(
  //     context: context,
  //     builder: (ctx) => AlertDialog(
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //       title: const Text('ยืนยันการลบ'),
  //       content: Text('คุณแน่ใจหรือไม่ว่าต้องการลบ $count โปรไฟล์?\nการลบไม่สามารถย้อนกลับได้'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(ctx, false),
  //           child: const Text('ยกเลิก'),
  //         ),
  //         ElevatedButton(
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: AppColors.colorAlert1,
  //             foregroundColor: Colors.white,
  //           ),
  //           onPressed: () => Navigator.pop(ctx, true),
  //           child: const Text('ยืนยันการลบ'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingFormCubit, SettingFormState>(
      builder: (context, formState) {
        final bool isSubmitting = formState.status == SubmitStatus.submitting;

        return LayoutBuilder(builder: (ctx, c) {
          // ปรับได้ตามดีไซน์
          const double minCardWidth = 280.0;
          const double maxCardWidth = 360.0;
          const double gap = 16.0;
          const int maxCols = 6;
          const int minCols = 1;

          int cols = ((c.maxWidth + gap) / (minCardWidth + gap)).floor().clamp(minCols, maxCols);

          double widthFor(int candidateCols) {
            final totalGap = gap * (candidateCols - 1);
            // +16 เพื่อเผื่อ padding ขวาเวลาใส่ Scrollbar/edge space
            return (c.maxWidth - (totalGap + 16)) / candidateCols;
          }

          double cardWidth = widthFor(cols);
          while (cardWidth > maxCardWidth && cols < maxCols) {
            cols++;
            cardWidth = widthFor(cols);
          }
          while (cardWidth < minCardWidth && cols > minCols) {
            cols--;
            cardWidth = widthFor(cols);
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header actions
              Row(
                children: [
                  // เพิ่มโปรไฟล์
                  PillButton(
                    label: 'เพิ่มโปรไฟล์',
                    labelSize: 14,
                    leading: Icons.add,
                    selected: true,
                    solid: true,
                    onTap: isSubmitting ? null : () async {
                      final formCubit = context.read<SettingFormCubit>();
                      formCubit.resetForm();

                      final saved = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => BlocProvider.value(
                          value: formCubit,
                          child: AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            backgroundColor: AppColors.colorBgGrey,
                            contentPadding: const EdgeInsets.all(8),
                            title: const Text('เพิ่มโปรไฟล์'),
                            content: const SizedBox(width: 360, child: SettingForm()),
                          ),
                        ),
                      );

                      if (!context.mounted) return;
                      if (saved == true) {
                        context.read<SettingProfileBloc>().add(const RefreshSettingProfiles());
                      }

                      // ❌ อย่าเรียก widget.onAddProfile(); อีก — จะไป push หน้าเปล่า ๆ ที่ไม่มี Material แล้ว error
                    },

                  ),

                  const SizedBox(width: 16),

                  // ลบโปรไฟล์ / ยกเลิกโหมดลบ (กดแล้วถามยืนยันถ้ามีเลือก)
                  Visibility(
                    visible: !_deleteMode,
                    child: PillButton(
                      label: _deleteMode ? 'ยกเลิก' : 'ลบโปรไฟล์',
                      labelSize: 14,
                      leading: _deleteMode ? Icons.close_rounded : Icons.remove_circle_rounded,
                      selected: true,
                      solid: true,
                      bg: _deleteMode ? Colors.black54 : AppColors.colorAlert1,
                      onTap: isSubmitting
                          ? null
                          : () async {
                              if (_deleteMode && _selectedIds.isNotEmpty) {
                                // final confirm = await _confirmDelete(context, _selectedIds.length);
                                // if (confirm == true) {
                                  final formCubit = context.read<SettingFormCubit>();
                                  final ok = await formCubit.removeSettingProfile(
                                    profileIds: _selectedIds.toList(),
                                  );
                                  if (!context.mounted) return;
                    
                                  if (ok) {
                                    context.read<SettingProfileBloc>().add(const RefreshSettingProfiles());
                                    setState(() {
                                      _selectedIds.clear();
                                      _deleteMode = false;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('ลบโปรไฟล์เรียบร้อยแล้ว'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } else {
                                    final err = formCubit.state.error ?? 'ลบโปรไฟล์ไม่สำเร็จ';
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(err), backgroundColor: Colors.red),
                                    );
                                  }
                                // }
                              } else {
                                _toggleDeleteMode();
                              }
                            },
                    ),
                  ),

                  if (_deleteMode) ...[
                    // const SizedBox(width: 8),
                    // PillButton(
                    //   label: 'เลือกทั้งหมด',
                    //   labelSize: 14,
                    //   leading: Icons.select_all_rounded,
                    //   selected: true,
                    //   solid: false,
                    //   onTap: isSubmitting
                    //       ? null
                    //       : () {
                    //           setState(() {
                    //             if (_selectedIds.length == widget.items.length) {
                    //               _selectedIds.clear();
                    //             } else {
                    //               _selectedIds
                    //                 ..clear()
                    //                 ..addAll(widget.items.map((e) => e.profileId));
                    //             }
                    //           });
                    //         },
                    // ),
                    // const SizedBox(width: 8),
                    PillButton(
                      label: 'ยกเลิก',
                      labelSize: 14,
                      leading: Icons.change_circle_rounded,
                      selected: true,
                      solid: true,
                      bg: Colors.black38,

                      onTap: isSubmitting
                          ? null
                          : () {
                              setState(() {
                                _deleteMode = false;
                                _selectedIds.clear();
                              });
                            },
                    ),

                    const SizedBox(width: 8),

                    // ปุ่มลบที่เลือกโดยตรง (สำรองอีกทาง)
                    PillButton(
                      label: 'ลบรายการ (${_selectedIds.length})',
                      labelSize: 14,
                      leading: Icons.delete_forever_rounded,
                      selected: true,
                      solid: true,
                      bg: AppColors.colorAlert1,
                      onTap: (isSubmitting || _selectedIds.isEmpty)
                          ? null
                          : () async {
                              // final confirm = await _confirmDelete(context, _selectedIds.length);
                              // if (confirm == true) {
                                final formCubit = context.read<SettingFormCubit>();
                                final ok = await formCubit.removeSettingProfile(
                                  profileIds: _selectedIds.toList(),
                                );
                                if (!context.mounted) return;

                                if (ok) {
                                  context.read<SettingProfileBloc>().add(const RefreshSettingProfiles());
                                  setState(() {
                                    _selectedIds.clear();
                                    _deleteMode = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('ลบโปรไฟล์เรียบร้อยแล้ว'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } else {
                                  final err = formCubit.state.error ?? 'ลบโปรไฟล์ไม่สำเร็จ';
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(err), backgroundColor: Colors.red),
                                  );
                                }
                              // }
                            },
                    ),
                  ],

                  // แสดงตัวบอกสถานะขณะลบ
                  if (isSubmitting) ...[
                    const SizedBox(width: 12),
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 16),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(0, 0, 16, 16), // กัน Scrollbar ทับขอบ
                  child: Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: widget.items.map((p) {
                      return SizedBox(
                        width: cardWidth,
                        child: ProfileCard(
                          profile: p,
                          onToggle: (v) => widget.onToggleActive(p.profileId, v),
                          hasAnotherActive: () => _hasAnotherActiveExcept(p.profileId),
                          onTap: () => _showProfileDetails(context, p),
                          onEdit: () => _showEditProfile(context, p),
                          deleteMode: _deleteMode,
                          selected: _selectedIds.contains(p.profileId),
                          onSelectedChanged: (sel) => _toggleSelected(p.profileId, sel),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          );
        });
      },
    );
  }

  void _showProfileDetails(BuildContext context, Profile profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProfileDetailSheet(profile: profile),
    );
  }

  Future<void> _showEditProfile(BuildContext context, Profile profile) async {
    final formCubit = context.read<SettingFormCubit>();
    
    formCubit
      ..updateSettingProfileId(profile.profileId)
      ..updateSettingProfileName(profile.name)
      ..updateDisplayType(profile.profileDisplayType!)
      ..updateChartChangeInterval(profile.chartChangeInterval!)
      ..updateRuleSelected()
      ..updateSpecifics(profile.specifics!)
      ..updateIsUsed(profile.active);

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: formCubit,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: AppColors.colorBgGrey,
          contentPadding: const EdgeInsets.all(8),
          title: Text(
            'แก้ไขโปรไฟล์: ${profile.name}',
            style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          content: const SizedBox( // 👈 ให้ฟอร์มมีความกว้างที่พอดี
            width: 360,
            child: SettingForm(),
          ),
        ),
      ),
    );

    if (saved == true && context.mounted) {
      context.read<SettingProfileBloc>().add(const RefreshSettingProfiles());
    }
  }
}
