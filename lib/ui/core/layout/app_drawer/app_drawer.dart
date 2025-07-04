import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:control_chart/ui/core/design_system/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AppDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const AppDrawer({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: 80.0,
              child:
                DrawerHeader(
                  curve: Curves.decelerate,
                  decoration: const BoxDecoration(color: AppColors.colorBrand),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Spread start to end
                    children: [
                      // Circle logo at the end
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: DecoratedBox(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.colorBlack,
                                blurRadius: 2,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/thaiparkLogo.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                
                                        MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => Navigator.pop(context),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SvgPicture.asset(
                                'assets/icons/collapse_sidebar.svg',
                                width: 24,
                                height: 24,
                                colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ),
      
            _buildTile(context, 'assets/icons/tv_monitoring.svg', 'Home', 0),
            _buildTile(context, 'assets/icons/searching.svg', 'Search', 1),
            _buildTile(context, 'assets/icons/setting.svg', 'Setting', 2),
            _buildTile(context, 'assets/icons/chart_detail.svg', 'Chart Detail', 3),
          ],
        ),
      );
    }

  Widget _buildTile(BuildContext context, String iconPath, String title, int index) {
    return ListTile(
      leading: SvgPicture.asset(iconPath),
      title: Text(title,
                  style: AppTypography.textBody2BBold),
      selected: selectedIndex == index,
      selectedTileColor: AppColors.colorBrandTp,
      onTap: () {
        if (selectedIndex != index) {
          onItemTapped(index);
        }
      },
    );
  }
}
