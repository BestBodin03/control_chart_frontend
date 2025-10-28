import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:flutter/material.dart';

class CollapsedAppDrawer extends StatelessWidget {
  const CollapsedAppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Icon Button Section
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
            child: IconButton(
              iconSize: 80.0, 
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              icon: DecoratedBox(
                decoration: BoxDecoration(
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
                    width: 40,
                    height: 40,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
        ),
      ],
    );
  }
}