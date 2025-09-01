import 'package:control_chart/data/bloc/setting_profile/setting_profile_bloc.dart';
import 'package:control_chart/data/cubit/setting_form/setting_form_cubit.dart';
import 'package:control_chart/data/cubit/setting_form/setting_form_state.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/component/profile/profile.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/component/temp.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileCard extends StatefulWidget {
  const ProfileCard({
    super.key,
    required this.profile,
    required this.onToggle,
    required this.hasAnotherActive,
    this.onTap, // ✅ Added callback for card tap
    this.onEdit, // ✅ Added callback for edit tap
  });

  final Profile profile;
  final ValueChanged<bool> onToggle;
  final bool Function() hasAnotherActive;
  final VoidCallback? onTap; // ✅ Optional callback when card is tapped
  final VoidCallback? onEdit; // ✅ Optional callback when edit is tapped

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  late bool _isOn;

  @override
  void initState() {
    super.initState();
    _isOn = widget.profile.active; // ค่าเริ่มจาก backend
  }

  @override
  void didUpdateWidget(covariant ProfileCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile.active != widget.profile.active) {
      _isOn = widget.profile.active; // sync ถ้า parent อัปเดต
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SettingFormCubit>();
    
    return GestureDetector(
      onTap: widget.onTap, // ✅ Handle card tap
      child: MouseRegion(
        cursor: widget.onTap != null 
            ? SystemMouseCursors.click 
            : SystemMouseCursors.basic, // ✅ Change cursor when clickable
        child: SizedBox(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              color: AppColors.colorBgGrey,
              boxShadow: [
                BoxShadow(color: Colors.white.withValues(alpha: 0.6),
                 blurRadius: 2, offset: const Offset(-5, -5)),
                BoxShadow(color: AppColors.colorBrandTp.withValues(alpha: 0.4),
                 blurRadius: 4, offset: const Offset(5, 5)),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------- Header: ชื่อ + pill ไอคอน ----------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded( // ✅ Allow text to take available space
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
                      GestureDetector(
                        onTap: widget.onEdit ?? () {
                          // ✅ Default edit behavior or use provided callback
                          print('Edit tapped for ${widget.profile.name}');
                        },
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Container(
                            padding: const EdgeInsets.all(4), // ✅ Increase tap area
                            child: const Icon(
                              Icons.edit,
                              color: AppColors.colorBrand,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // ---------- Summary ----------
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
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: const Color(0xFF64748B)),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {}, // ✅ Prevent parent tap when tapping switch area
                        child: Switch(
                          value: _isOn, // ✅ คุมด้วย local state
                          activeColor: AppColors.colorBg,
                          activeTrackColor: AppColors.colorSuccess1,
                          inactiveThumbColor: AppColors.colorBg,
                          inactiveTrackColor: const Color.fromARGB(255, 193, 194, 194),
                          onChanged: (v) async {
                            final prev = _isOn;
                            setState(() => _isOn = v);

                            cubit
                              ..updateSettingProfileName(widget.profile.name)
                              ..updateDisplayType(widget.profile.profileDisplayType!)
                              ..updateChartChangeInterval(widget.profile.chartChangeInterval!)
                              ..updateRuleSelected(widget.profile.ruleSelected!)
                              ..updateSpecifics(widget.profile.specifics!)
                              ..updateIsUsed(v);

                            // ✅ รอผลลัพธ์จาก saveForm
                            final success = await cubit.saveForm(id: widget.profile.id);

                            if (!mounted) return;

                            if (!success) {
                              // ❌ ล้มเหลว → revert กลับ
                              setState(() => _isOn = prev);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  duration: Duration(seconds: 1),
                                  content: Text('สามารถใช้งานได้เพียง 1 โปรไฟล์เท่านั้น'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }
                            widget.onToggle(v);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}