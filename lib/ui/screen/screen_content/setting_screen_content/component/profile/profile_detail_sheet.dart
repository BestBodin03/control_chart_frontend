// ✅ Profile Detail Sheet Component
import 'package:control_chart/data/cubit/setting_form/setting_form_cubit.dart';
import 'package:control_chart/data/cubit/setting_form/setting_form_state.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/shared/setting_form.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/component/profile/profile.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/component/temp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ProfileDetailSheet extends StatelessWidget {
  const ProfileDetailSheet({
    super.key,
    required this.profile,
    this.onEdit
  });

  final Profile profile;
  final VoidCallback? onEdit;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 60),
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'รายละเอียดโปรไฟล์',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Profile details
          _buildDetailRow(context, 'ชื่อโปรไฟล์', profile.name),
          _buildDetailRow(context, 'ประเภทการแสดงผล', profile.displayType),
          _buildDetailRow(
            context,
            'สร้างเมื่อ',
            profile.createdAt != null
                ? DateFormat('dd/MM').format(profile.createdAt!)
                : "-",
          ),
          _buildDetailRow(context, 'สถานะ', profile.active ? 'เปิดใช้งาน' : 'ปิดใช้งาน'),
          
          if (profile.chartChangeInterval != null)
            _buildDetailRow(context, 'ช่วงเวลาการเปลี่ยนแปลง', '${profile.chartChangeInterval} วินาที'),
          
          if (profile.ruleSelected != null && profile.ruleSelected!.isNotEmpty)
            _buildDetailRow(context, 'กฎที่เลือก', _formatSelectedRules(profile.ruleSelected!)),

          if (profile.specifics != null && profile.specifics!.isNotEmpty)
            _buildDetailRow(context, 'รายละเอียด \nการแสดงผล', _formatSettingSpecificDetails(profile.specifics!)),
          
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            children: [
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.colorBrand,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('ปิด'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }


  // ✅ Helper method to format selected rules
  String _formatSelectedRules(List<RuleSelected> rules) {
    final usedRules = rules.where((rule) => rule.isUsed == true).toList();
    
    if (usedRules.isEmpty) {
      return 'ไม่มีกฎที่เลือก';
    }
    
    return usedRules
        .map((rule) => 'Rule: ${rule.ruleId} - ${rule.ruleName}')
        .join(', ');
  }

  String _formatSettingSpecificDetails(List<SpecificSettingState> specifics) {
    if (specifics.isEmpty) return "ไม่พบข้อมูล";

  return specifics.map((s) {
    final start = s.startDate != null ? DateFormat('dd/MM').format(s.startDate!) : "-";
    final end   = s.endDate   != null ? DateFormat('dd/MM').format(s.endDate!)   : "-";

    return 'ระยะเวลา: $start ถึง $end'
          ' - เตาที่: ${s.furnaceNo ?? "-"}'
          ' - เลขแมต: ${s.cpNo ?? "-"}';
  }).join("\n");
  }

}