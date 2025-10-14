// ✅ Profile Detail Sheet Component
import 'package:control_chart/data/cubit/setting_form/setting_form_state.dart';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/component/profile/profile.dart';
import 'package:flutter/material.dart';
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Profile Details',
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
            _buildDetailRow(context, 'Profile Name', profile.name),
            _buildDetailRow(context, 'Display type', profile.displayType),
            if (profile.specifics != null && profile.specifics!.isNotEmpty)
              _buildDetailRow(context, 'Period', _formatDate(profile.specifics!)),

            _buildDetailRow(context, 'Status', profile.active ? 'Used' : 'Not Use'),
            
            if (profile.chartChangeInterval != null)
              _buildDetailRow(context, 'Page Duration (second)', '${profile.chartChangeInterval} seconds'),
            
            if (profile.ruleSelected != null && profile.ruleSelected!.isNotEmpty)
              _buildDetailRow(context, 'Rule', _formatSelectedRules(profile.ruleSelected!)),
        
            if (profile.specifics != null && profile.specifics!.isNotEmpty)
              _buildDetailRow(context, 'Page Details', _formatSettingSpecificDetails(profile.specifics!)),
            
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
                    child: const Text('close'),
                  ),
                ),
              ],
            ),
          ],
        ),
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

  String _formatDate(List<SpecificSettingState> specifics) {
    if (specifics.isEmpty) return "ไม่พบข้อมูล";

    final first = specifics.first;

    final start = first.startDate != null
        ? DateFormat('dd/MM/yyyy').format(first.startDate!)
        : "-";
    final end = first.endDate != null
        ? DateFormat('dd/MM/yyyy').format(first.endDate!)
        : "-";

    return '$start To $end';
  }


  String _formatSettingSpecificDetails(List<SpecificSettingState> specifics) {
    if (specifics.isEmpty) return "ไม่พบข้อมูล";

    return specifics.indexed.map((entry) {
      final (i, s) = entry;
      final page = i + 1;

      return 'Page $page'
            ' - Furnace No. ${s.furnaceNo ?? "-"}'
            ' - Material No. ${s.cpNo ?? "-"}';
    }).join("\n");
  }
}