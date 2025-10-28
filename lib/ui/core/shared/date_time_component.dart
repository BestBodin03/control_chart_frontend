import 'dart:async';
import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:flutter/material.dart';

class DateTimeComponent extends StatefulWidget {
  final String? timeZone;
  final TextStyle? timeStyle;
  final TextStyle? dateStyle;
  final EdgeInsets? padding;

  const DateTimeComponent({
    super.key,
    this.timeZone,
    this.timeStyle,
    this.dateStyle,
    this.padding,
  });

  @override
  State<DateTimeComponent> createState() => _DateTimeComponentState();
}

class _DateTimeComponentState extends State<DateTimeComponent> {
  late Timer _timer;
  late DateTime _currentDateTime;
  String _timeZoneName = '';

  @override
  void initState() {
    super.initState();
    _updateDateTime();
    _getTimeZoneName();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateDateTime());
  }

  void _updateDateTime() => setState(() => _currentDateTime = DateTime.now());

  void _getTimeZoneName() => _timeZoneName = _currentDateTime.timeZoneName;

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDate(DateTime dateTime) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '| ${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // scale smoothly between 1280 → 20 and 1920 → 32
    final scaledFont = (20 + (width - 1280) / (1920 - 1280) * (32 - 20))
        .clamp(20, 32)
        .toDouble();

    return Padding(
      padding: widget.padding ?? const EdgeInsets.only(left: 32.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatTime(_currentDateTime),
            style: widget.timeStyle ??
                TextStyle(
                  fontSize: scaledFont,
                  color: AppColors.colorBrand,
                ),
          ),
          const SizedBox(width: 4),
          Text(
            _formatDate(_currentDateTime),
            style: widget.dateStyle ??
                TextStyle(
                  fontSize: scaledFont,
                  color: AppColors.colorBrand,
                ),
          ),
        ],
      ),
    );
  }
}
