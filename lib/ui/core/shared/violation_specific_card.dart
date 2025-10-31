import 'dart:async';
import 'package:flutter/material.dart';

class ViolationItem {
  final String? fgNo;
  final double value;
  final String type; // เช่น "OverSpec (L)"
  final Color color;

  ViolationItem({
    this.fgNo,
    required this.value,
    required this.type,
    required this.color,
  });
}

class ViolationSpecificQueueCard extends StatefulWidget {
  const ViolationSpecificQueueCard({
    super.key,
    required this.violations,
    this.duration = const Duration(seconds: 8),
  });

  final List<ViolationItem> violations;
  final Duration duration;

  @override
  State<ViolationSpecificQueueCard> createState() =>
      _ViolationSpecificQueueCardState();
}

class _ViolationSpecificQueueCardState
    extends State<ViolationSpecificQueueCard> with SingleTickerProviderStateMixin {
  late AnimationController _blinkController;
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // เดิม 600 -> ช้าลง 2 เท่า
    )..repeat(reverse: true);

    // start timer loop
    _timer = Timer.periodic(widget.duration, (t) {
      if (mounted) {
        setState(() {
          _currentIndex =
              (_currentIndex + 1) % widget.violations.length; // next violation
        });
      }
    });
  }

  @override
  void dispose() {
    _blinkController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.violations.isEmpty) return const SizedBox.shrink();

    final current = widget.violations[_currentIndex];

    return FadeTransition(
      opacity: Tween<double>(begin: 0.5, end: 2).animate(_blinkController),
      child: Card(
        elevation: 6,
        color: current.color.withValues(alpha: 0.85),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    current.type,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    "Lot No.: ${current.fgNo}",
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  Text(
                    "Value: ${current.value.toStringAsFixed(2)}",
                    style: const TextStyle(color: Colors.white, fontSize: 14),
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
