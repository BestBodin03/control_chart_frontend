// lib/ui/screen/screen_content/setting_screen_content/component/profile/profile_card.dart
import 'package:control_chart/data/bloc/setting_profile/setting_profile_bloc.dart';
import 'package:control_chart/data/cubit/setting_form/extension/setting_form_cubit_global_period.dart';
import 'package:control_chart/data/cubit/setting_form/setting_form_cubit.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/component/profile/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileCard extends StatefulWidget {
  const ProfileCard({
    super.key,
    required this.profile,
    required this.onToggle,
    required this.hasAnotherActive,
    this.onTap,
    this.onEdit,
    // โหมดลบ + การเลือกหลายรายการ
    required this.deleteMode,
    required this.selected,
    required this.onSelectedChanged,
  });

  final Profile profile;
  final ValueChanged<bool> onToggle;
  final bool Function() hasAnotherActive;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  // โหมดลบ
  final bool deleteMode;
  final bool selected;
  final ValueChanged<bool> onSelectedChanged;

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  late bool _isOn;

  @override
  void initState() {
    super.initState();
    _isOn = widget.profile.active;
  }

  @override
  void didUpdateWidget(covariant ProfileCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile.active != widget.profile.active) {
      _isOn = widget.profile.active;
    }
  }

  @override
  Widget build(BuildContext context) {
    // read เพื่อใช้งาน form cubit ตอนเซฟ
    context.read<SettingFormCubit>();

    return GestureDetector(
      onTap: widget.deleteMode
          ? () => widget.onSelectedChanged(!widget.selected) // โหมดลบ → toggle เลือก
          : widget.onTap,                                      // ปกติ → เปิดรายละเอียด
      child: MouseRegion(
        cursor: widget.deleteMode
            ? SystemMouseCursors.click
            : (widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            color: widget.selected ? AppColors.colorAlert1.withValues(alpha: 0.15) : AppColors.colorBgGrey,
            boxShadow: widget.selected
                ? [
                    BoxShadow(color: Colors.white.withValues(alpha: 0.6), blurRadius: 2, offset: const Offset(-5, -5)),
                    BoxShadow(color: AppColors.colorAlert2.withValues(alpha: 0.4), blurRadius: 4, offset: const Offset(5, 5)),
                  ]
                : [
                    BoxShadow(color: Colors.white.withValues(alpha: 0.6), blurRadius: 2, offset: const Offset(-5, -5)),
                    BoxShadow(color: AppColors.colorBrandTp.withValues(alpha: 0.4), blurRadius: 4, offset: const Offset(5, 5)),
                  ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------- Header: ชื่อ + icon/checkbox ----------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.profile.name,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.deleteMode)
                      // โหมดลบ: แสดง Checkbox
                      InkWell(
                        onTap: () => widget.onSelectedChanged(!widget.selected),
                        child: Checkbox(
                          value: widget.selected,
                          onChanged: (v) => widget.onSelectedChanged(v ?? false),
                        ),
                      )
                    else
                      // โหมดปกติ: แสดงปุ่มแก้ไข
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: IconButton(
                        tooltip: 'Edit',
                        padding: const EdgeInsets.all(8), // ← padding 8
                        iconSize: 20,
                        splashRadius: 18, // optional: smaller ripple
                        icon: const Icon(Icons.edit, color: AppColors.colorBrand),
                        onPressed: widget.onEdit,
                      ),
                    )

                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  'Display Type: ${widget.profile.displayType}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: const Color(0xFF475569),
                        height: 1.45,
                      ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Text(
                      'Show ${widget.profile.specifics?.length ?? 0} Page',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(color: const Color(0xFF64748B)),
                    ),
                    const Spacer(),

                    // ปิด switch ขณะอยู่ในโหมดลบ
                    IgnorePointer(
                      ignoring: widget.deleteMode,
                      child: Opacity(
                        opacity: widget.deleteMode ? 0.4 : 1,
                        child: Switch(
                          value: _isOn,
                          activeColor: AppColors.colorBg,
                          activeTrackColor: AppColors.colorSuccess1,
                          inactiveThumbColor: AppColors.colorBg,
                          inactiveTrackColor: const Color.fromARGB(255, 193, 194, 194),
                          onChanged: (v) async {
                            // guard: ถ้าจะเปิด และมีตัวอื่นเปิดอยู่แล้ว → ปัดตก
                            if (v && widget.hasAnotherActive()) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  duration: Duration(seconds: 1),
                                  content: Text('Can use only one profile.',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold
                                    ),),
                                  backgroundColor: Colors.orange,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }

                            final prev = _isOn;
                            setState(() => _isOn = v);

                            final formCubit = context.read<SettingFormCubit>();
                            formCubit
                            ..updateSettingProfileId(widget.profile.profileId)
                            ..updateSettingProfileName(widget.profile.name)
                            ..updateDisplayType(widget.profile.profileDisplayType ?? formCubit.state.displayType)
                            ..updateChartChangeInterval(widget.profile.chartChangeInterval ?? formCubit.state.chartChangeInterval)
                            ..updateRuleSelected()
                            // ..updateGlobalPeriodType(formCubit.)
                            ..updateSpecifics(widget.profile.specifics ?? [])
                            ..updateIsUsed(v);
                            // ..updateGlobalStartDate(widget.profile.specifics.first.startDate)

                            final success = await formCubit.saveForm(id: widget.profile.profileId);
                            // debugPrint(success.toString());
                            if (!context.mounted) return;

                            if (success) {
                              context.read<SettingProfileBloc>().add(const RefreshSettingProfiles());
                              // แจ้ง parent หลังเซฟสำเร็จเท่านั้น
                              widget.onToggle(v);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Profile saved',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold
                                    )),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            } else {
                              // rollback
                              setState(() => _isOn = prev);
                              // debugPrint('HII');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  duration: Duration(seconds: 1),
                                  content: Text(
                                    'Can use only one profile.',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold
                                    ),),
                                  backgroundColor: Colors.orange,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
