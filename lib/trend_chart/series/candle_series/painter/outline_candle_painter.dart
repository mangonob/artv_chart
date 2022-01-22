import 'package:flutter/material.dart';

import '../../../chart_coordinator.dart';
import '../../../common/painter/line_painter.dart';
import '../../../common/style.dart';
import '../candle_series_style.dart';
import 'candle_painter.dart';
import 'fill_candle_painter.dart';

class OutlineCandlePainter extends CandlePainter {
  OutlineCandlePainter({
    required CandleSeriesStyle style,
    required HasCoordinator coordinator,
  }) : super(
          style: style,
          coordinator: coordinator,
        );

  @override
  void paintBody(
    Canvas canvas, {
    required Rect rect,
    required Color color,
  }) {
    final lineStyle = const LineStyle(size: 1).merge(style.lineStyle);

    canvas.drawRect(
      rect.deflate((lineStyle.size ?? 1) / 2),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = lineStyle.size ?? 1
        ..color = color,
    );
  }

  @override
  void paintWick(
    Canvas canvas, {
    required Rect line,
    Rect? body,
    required Color color,
  }) {
    if (body == null) {
      FillCandlePainter(style: style, coordinator: coordinator).paintWick(
        canvas,
        line: line,
        color: color,
      );
    } else {
      final lineStyle = const LineStyle(
        size: 1,
      ).merge(style.lineStyle).copyWith(color: color);

      LinePainter().paint(
        canvas,
        start: line.topLeft,
        end: Offset(line.topLeft.dx, body.top),
        style: lineStyle,
      );

      LinePainter().paint(
        canvas,
        start: Offset(line.bottomLeft.dx, body.bottom),
        end: line.bottomLeft,
        style: lineStyle,
      );
    }
  }
}
