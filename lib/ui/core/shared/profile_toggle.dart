import 'package:flutter/material.dart';

class ProfileToggle extends StatelessWidget {
  const ProfileToggle({super.key, 
    required this.text,
    required this.color,
    required this.textColor,
    required this.ringColor,
  });

  final String text;
  final Color color;
  final Color textColor;
  final Color ringColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: ringColor),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          text,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(fontWeight: FontWeight.bold, color: textColor),
        ),
      ),
    );
  }
}