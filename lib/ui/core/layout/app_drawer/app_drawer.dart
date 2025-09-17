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
                              child: const Icon(
                                Icons.chevron_left, // or Icons.menu_open_rounded
                                size: 24,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ),
      
            _buildTile(context, Icons.tv,            'Home',         0),
            _buildTile(context, Icons.search_rounded,'Search',       1),
            _buildTile(context, Icons.settings_rounded,'Setting',    2),
            _buildTile(context, Icons.show_chart,    'Chart Detail', 3),

          ],
        ),
      );
    }

  Widget _buildTile(BuildContext context, IconData icon, String title, int index) {
    final bool isSelected = selectedIndex == index;
    final Color fg = isSelected ? const Color.fromARGB(255, 15, 1, 201) : AppColors.colorBrand;

    return ListTile(
      leading: Icon(icon, size: 24, color: fg),
      title: Text(
        title,
        style: AppTypography.textBody2BBold.copyWith(color: fg),
      ),
      selected: isSelected,
      selectedTileColor: AppColors.colorBrandTp,
      onTap: () {
        if (!isSelected) onItemTapped(index);
      },
    );
  }
}
