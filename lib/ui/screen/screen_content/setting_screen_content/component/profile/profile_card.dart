import 'package:control_chart/data/bloc/setting_profile/setting_profile_bloc.dart';
import 'package:control_chart/data/cubit/setting_form/setting_form_cubit.dart';
import 'package:control_chart/data/cubit/setting_form/setting_form_state.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/shared/setting_form.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/component/profile/profile.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/component/temp.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// profile_card.dart (เฉพาะจุดสำคัญ)
class ProfileCard extends StatefulWidget {
  const ProfileCard({
    super.key,
    required this.profile,
    required this.onToggle,
    required this.hasAnotherActive,
    this.onTap,
    this.onEdit,
    // 👇 เพิ่ม
    required this.deleteMode,
    required this.selected,
    required this.onSelectedChanged,
  });

  final Profile profile;
  final ValueChanged<bool> onToggle;
  final bool Function() hasAnotherActive;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  // 👇 ใหม่
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
    final cubit = context.read<SettingFormCubit>();

    return GestureDetector(
      onTap: widget.deleteMode
          ? () => widget.onSelectedChanged(!widget.selected) // โหมดลบ → toggle เลือก
          : widget.onTap,                                      // ปกติ → เปิดรายละเอียด
      child: MouseRegion(
        cursor: widget.deleteMode ? SystemMouseCursors.click
                                  : (widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            color: widget.selected ? AppColors.colorAlert1.withValues(alpha: 0.15) : AppColors.colorBgGrey,
            boxShadow: widget.selected ? 
            [
              BoxShadow(color: Colors.white.withValues(alpha: 0.6), blurRadius: 2, offset: const Offset(-5, -5)),
              BoxShadow(color: AppColors.colorAlert2.withValues(alpha: 0.4), blurRadius: 4, offset: const Offset(5, 5)),
            ]:
            [
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
                      // ✅ โหมดลบ: แสดง Checkbox
                      InkWell(
                        onTap: () => widget.onSelectedChanged(!widget.selected),
                        child: Checkbox(
                          value: widget.selected,
                          onChanged: (v) => widget.onSelectedChanged(v ?? false),
                        ),
                      )
                    else
                      // ✅ โหมดปกติ: แสดงปุ่มแก้ไขเหมือนเดิม
                      GestureDetector(
                        onTap: widget.onEdit,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(Icons.edit, color: AppColors.colorBrand, size: 20),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  widget.profile.displayType,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                      'สร้างเมื่อ ${fmtDate(widget.profile.createdAt)}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: const Color(0xFF64748B)),
                    ),
                    const Spacer(),

                    // ✅ ปิด switch ขณะอยู่ในโหมดลบ
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
                            final prev = _isOn;
                            setState(() => _isOn = v);

                            final formCubit = context.read<SettingFormCubit>();
                            formCubit
                              ..updateSettingProfileName(widget.profile.name)
                              ..updateDisplayType(widget.profile.profileDisplayType!)
                              ..updateChartChangeInterval(widget.profile.chartChangeInterval!)
                              ..updateRuleSelected(widget.profile.ruleSelected!)
                              ..updateSpecifics(widget.profile.specifics!)
                              ..updateIsUsed(v);

                            final success = await formCubit.saveForm(id: widget.profile.profileId);
                            if (!mounted) return;

                            if (success) {
                              context.read<SettingProfileBloc>().add(const RefreshSettingProfiles());
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('บันทึกข้อมูลเรียบร้อยแล้ว'), backgroundColor: Colors.green),
                              );
                            } else {
                              setState(() => _isOn = prev);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  duration: Duration(seconds: 1),
                                  content: Text('สามารถใช้งานได้เพียง 1 โปรไฟล์เท่านั้น'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            }
                            widget.onToggle(v);
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
