import 'package:flutter/material.dart';

import '../enum.dart';
import '../style.dart';

class LinePainter {
  LinePainter._();

  factory LinePainter() => LinePainter._();

  void paint(
    Canvas canvas, {
    required Offset start,
    required Offset end,
    required LineStyle style,
  }) {
    switch (style.type ?? LineType.solid) {
      case LineType.solid:
        canvas.drawLine(
          start,
          end,
          Paint()
            ..style = PaintingStyle.stroke
            ..color = style.color ?? Colors.black
            ..strokeWidth = style.size ?? 1,
        );
        break;
      case LineType.dash:
        // TODO implement
        break;
      case LineType.dot:
        // TODO implement
        break;
    }
  }
}
