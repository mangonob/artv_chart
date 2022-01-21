import 'package:flutter/material.dart';

typedef PainterRoutine = void Function(Canvas canvas, Size size);

class PaddingPainter {
  void paint(
    Canvas canvas,
    Size size, {
    EdgeInsets? padding,
    PainterRoutine? routine,
    bool clip = false,
  }) {
    canvas.save();

    final mustPadding = padding ?? EdgeInsets.zero;

    canvas.translate(mustPadding.left, mustPadding.top);
    final canvasSize = Size(
      size.width - mustPadding.horizontal,
      size.height - mustPadding.vertical,
    );

    if (clip) {
      canvas.clipRect(Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height));
    }

    routine?.call(canvas, canvasSize);

    canvas.restore();
  }
}
