import 'package:flutter/material.dart';

import '../../../chart_coordinator.dart';
import '../../../common/painter/line_painter.dart';
import '../../../common/style.dart';
import '../candle_series_style.dart';
import 'candle_painter.dart';

class FillCandlePainter extends CandlePainter {
  FillCandlePainter({
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
    required bool isRise,
  }) {
    final lineStyle = const LineStyle(
      size: 1,
    ).merge(style.lineStyle).copyWith(color: color);

    if (rect.height < lineStyle.size!) {
      LinePainter().paint(
        canvas,
        start: rect.centerLeft,
        end: rect.centerRight,
        style: lineStyle,
      );
    } else {
      canvas.drawRect(
        rect,
        Paint()..color = color,
      );
    }
  }

  @override
  void paintWick(
    Canvas canvas, {
    required Rect line,
    Rect? body,
    required Color color,
  }) {
    LinePainter().paint(
      canvas,
      start: line.topLeft,
      end: line.bottomLeft,
      style: const LineStyle(
        size: 1,
      ).merge(style.lineStyle).copyWith(color: color),
    );
  }
}
