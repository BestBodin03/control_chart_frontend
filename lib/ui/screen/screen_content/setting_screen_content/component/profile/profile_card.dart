import 'package:control_chart/data/bloc/setting_profile/setting_profile_bloc.dart';
import 'package:control_chart/data/cubit/setting_form/setting_form_cubit.dart';
import 'package:control_chart/data/cubit/setting_form/setting_form_state.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/component/profile/profile.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/component/temp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key, required this.profile, required this.onToggle});

  final Profile profile;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
                        Text(
                          profile.name,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Icon(
                          Icons.edit,
                          color: AppColors.colorBrand,
                          size: 20,
                        ),
                ],
              ),

              const SizedBox(height: 8),

              // ---------- Summary ----------
              Text(
                profile.summary,
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
                    'สร้างเมื่อ ${fmtDate(profile.createdAt)}',
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: const Color(0xFF64748B)),
                  ),
                  const Spacer(),
                  BlocBuilder<SettingFormCubit, SettingFormState>(
                    builder: (context, state) {  
                    return Switch(
                      value: profile.active,
                      activeColor: AppColors.colorBg,
                      activeTrackColor: AppColors.colorSuccess1,
                      inactiveThumbColor: AppColors.colorBg,
                      inactiveTrackColor: const Color.fromARGB(255, 185, 191, 199),
                      onChanged: (v) async {
                        final cubit = context.read<SettingFormCubit>();
                        cubit.loadSettings(SettingFormState()); // ต้องแมพข้อมูลมาก่อน

                        cubit.updateIsUsed(v);
                        await cubit.saveForm(id: profile.id); // ตอนนี้ state ครบจบ validation
                      }

                    );

                    }
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
