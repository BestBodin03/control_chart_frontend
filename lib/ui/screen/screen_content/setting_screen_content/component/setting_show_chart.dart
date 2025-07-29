import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/screen/screen_content/setting_screen_content/component/furnace_report_layout.dart';
import 'package:flutter/material.dart';

class SettingShowChart extends StatelessWidget {
  const SettingShowChart({super.key});
  
  @override
  Widget build(BuildContext context) {
    return 
      Expanded(
        child: SizedBox(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.colorBg,
              borderRadius: BorderRadius.circular(16.0),
              border:Border.all(
                color: Colors.black12
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.6),
                  blurRadius: 10,
                  offset: Offset(-5, -5),
                ),
                BoxShadow(
                  color: AppColors.colorBrandTp.withValues(alpha: 0.4),
                  blurRadius: 15,
                  offset: Offset(5, 5),
                ),
              ],
            ),
            
            // child: FurnaceReportLayout(),
            
          ),
        ),
    );
  }

}
