import 'dart:async';

import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:flutter/material.dart';

class DateTimeComponent extends StatefulWidget {
  final String? timeZone;
  final TextStyle? timeStyle;
  final TextStyle? dateStyle;
  final EdgeInsets? padding;
  
  const DateTimeComponent ({
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
    
    // Update every second
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _updateDateTime();
    });
  }

  void _updateDateTime() {
    setState(() {
      _currentDateTime = DateTime.now();
    });
  }

  void _getTimeZoneName() {
    _timeZoneName = _currentDateTime.timeZoneName;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(DateTime dateTime) {
    String hour = dateTime.hour.toString().padLeft(2, '0');
    String minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDate(DateTime dateTime) {
    List<String> months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    return '| ${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Padding(
        padding: EdgeInsets.only(left: 32.0),
        child: Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Time Display
              Text(
                _formatTime(_currentDateTime),
                style: widget.timeStyle ?? TextStyle(
                  fontSize: 14.0,
                  color: AppColors.colorBrand,
                ),
              ),
              
              SizedBox(width: 4),
              
              // Date Display
              Text(
                _formatDate(_currentDateTime),
                style: widget.dateStyle ?? TextStyle(
                  fontSize: 14.0,
                  color: AppColors.colorBrand,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}