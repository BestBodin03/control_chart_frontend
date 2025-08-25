import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/component/profile/profile.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/component/temp.dart';
import 'package:flutter/material.dart';

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
            BoxShadow(color: Colors.white.withValues(alpha: 0.6), blurRadius: 2, offset: const Offset(-5, -5)),
            BoxShadow(color: AppColors.colorBrandTp.withValues(alpha: 0.4), blurRadius: 4, offset: const Offset(5, 5)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------- Header: ชื่อ + pill ไอคอน ----------
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      profile.name,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.colorBrand,),
                      ),
                      child: Row(
                        children: const [
                          // ใส่ IconButton ภายหลังได้
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // SizedBox(
              //   height: 22, // 🔧 กำหนดความสูงตายตัว
              //   child: AspectRatio(
              //     aspectRatio: 21 / 9, // ✅ สัดส่วน 21:9
              //     child: DecoratedBox(
              //       decoration: BoxDecoration(
              //         color: profile.active
              //             ? AppColors.colorSuccess1.withValues(alpha: 0.1)
              //             : const Color(0xFF64748B).withValues(alpha: 0.1),
              //         borderRadius: BorderRadius.circular(20),
              //         border: Border.all(
              //           color: profile.active
              //               ? AppColors.colorSuccess1
              //               : const Color(0xFF64748B),
              //           width: 1,
              //         ),
              //       ),
              //       child: Center(
              //         child: Text(
              //           profile.active ? 'ใช้' : 'ไม่ใช้',
              //           style: Theme.of(context).textTheme.labelMedium?.copyWith(
              //                 color: profile.active
              //                     ? AppColors.colorSuccess1
              //                     : const Color(0xFF64748B),
              //                 fontSize: 14,
              //               ),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),



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

              const SizedBox(height: 12),

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
                  Switch(
                    value: profile.active,
                    activeColor: AppColors.colorBg,
                    activeTrackColor: AppColors.colorSuccess1,
                    inactiveThumbColor: AppColors.colorBg,
                    inactiveTrackColor: const Color.fromARGB(255, 185, 191, 199),
                    onChanged: onToggle,
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
