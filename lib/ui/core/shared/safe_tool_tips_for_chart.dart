import 'dart:math' as math;
import 'package:control_chart/ui/core/design_system/app_typography.dart';
import 'package:flutter/material.dart';

class SafeChartTooltip {
  SafeChartTooltip._();
  static final SafeChartTooltip instance = SafeChartTooltip._();

  OverlayEntry? _entry;

  // last state
  Rect _chartRect = Rect.zero;
  Offset _localDot = Offset.zero;
  String _text = '';
  Color _bg = const Color(0xFF000000);
  double _dotR = 6;
  double _gap = 10;
  double _maxW = 340;

  void showOrUpdate(
    BuildContext context, {
    required Rect chartRectGlobal,
    required Offset localDotPx,
    required String text,
    required Color background,
    double dotRadius = 6,
    double gap = 8,
    double maxWidth = 340,
  }) {
    _chartRect = chartRectGlobal;
    _localDot = localDotPx;
    _text = text;
    _bg = background;
    _dotR = dotRadius;
    _gap = gap;
    _maxW = maxWidth;

    if (_entry == null) {
      _entry = OverlayEntry(builder: (_) => _build());
      Overlay.of(context, rootOverlay: true).insert(_entry!);
    } else {
      _entry!.markNeedsBuild();
    }
  }

  void hide() {
    _entry?.remove();
    _entry = null;
  }

  Widget _build() {
    // --- estimate bubble size (fast & good-enough) ---
    final lines = _text.split('\n');
    final estW = (lines.fold<int>(0, (m, l) => math.max(m, l.length)) * 8.0)
        .clamp(80.0, _maxW) + 16.0; // + padding
    final estH = lines.length * 16.0 + 16.0;

    // local dot -> global
    final globalDot = _chartRect.topLeft + _localDot;

    // try above
    Offset candidate = Offset(
      globalDot.dx - estW / 2,
      globalDot.dy - _dotR - _gap - estH,
    );
    // if not enough space above -> below
    if (candidate.dy < _chartRect.top) {
      candidate = Offset(
        globalDot.dx - estW / 2,
        globalDot.dy + _dotR + _gap,
      );
    }

    // clamp inside chart rect
    double x = candidate.dx.clamp(_chartRect.left, _chartRect.right - estW);
    double y = candidate.dy.clamp(_chartRect.top, _chartRect.bottom - estH);

    // left corner -> place to the right of dot
    if (x == _chartRect.left && (globalDot.dx - estW / 2) < _chartRect.left + _dotR + _gap) {
      x = (globalDot.dx + _dotR + _gap).clamp(_chartRect.left, _chartRect.right - estW);
      y = (globalDot.dy - estH / 2).clamp(_chartRect.top, _chartRect.bottom - estH);
    }
    // right corner -> place to the left of dot
    if (x == _chartRect.right - estW &&
        (globalDot.dx + estW / 2) > _chartRect.right - (_dotR + _gap)) {
      x = (globalDot.dx - _dotR - _gap - estW).clamp(_chartRect.left, _chartRect.right - estW);
      y = (globalDot.dy - estH / 2).clamp(_chartRect.top, _chartRect.bottom - estH);
    }

    return Positioned(
      left: x,
      top: y,
      width: estW,
      height: estH,
      child: IgnorePointer(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _text,
            style: AppTypography.textBody3WBold,
          ),
        ),
      ),
    );
  }
}
