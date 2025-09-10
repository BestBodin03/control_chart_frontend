import 'package:flutter/material.dart';

class Toast {
  static OverlayEntry? _entry;

  static Future<void> showOnWidget(
    BuildContext context,
    GlobalKey key, {
    required String text,
    Duration duration = const Duration(seconds: 1),
  }) async {
    // หา RenderBox ของ widget จาก GlobalKey
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _entry?.remove();

    _entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: offset.dx,
          top: offset.dy,
          width: size.width,
          height: size.height,
          child: Center( // toast อยู่กึ่งกลาง widget เลย
            child: Material(
              color: Colors.black.withOpacity(0.75),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                  text,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_entry!);

    // ลบออกหลังครบเวลา
    await Future.delayed(duration);
    _entry?.remove();
    _entry = null;
  }
}
