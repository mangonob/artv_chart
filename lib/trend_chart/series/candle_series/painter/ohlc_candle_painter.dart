import 'package:flutter/material.dart';

import '../../../chart_coordinator.dart';
import '../../../common/painter/line_painter.dart';
import '../../../common/style.dart';
import '../candle_series_style.dart';
import 'candle_painter.dart';
import 'fill_candle_painter.dart';

class OHLCandlePainter extends CandlePainter {
  OHLCandlePainter({
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
    final lineStyle = const LineStyle(
      size: 1,
    ).merge(style.lineStyle).copyWith(color: color);

    LinePainter().paint(
      canvas,
      start: rect.topLeft,
      end: rect.topCenter,
      style: lineStyle,
    );

    LinePainter().paint(
      canvas,
      start: rect.bottomCenter,
      end: rect.bottomRight,
      style: lineStyle,
    );
  }

  @override
  void paintWick(
    Canvas canvas, {
    required Rect line,
    Rect? body,
    required Color color,
  }) {
    FillCandlePainter(style: style, coordinator: coordinator).paintWick(
      canvas,
      line: line,
      color: color,
    );
  }
}
