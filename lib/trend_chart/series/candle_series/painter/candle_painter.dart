import 'package:flutter/material.dart';

import '../../../../utils/utils.dart';
import '../../../chart_coordinator.dart';
import '../candle_entry.dart';
import '../candle_series_style.dart';
import 'fill_candle_painter.dart';
import 'ohlc_candle_painter.dart';
import 'outline_candle_painter.dart';

/// Painter interface of candle that has no side-effect.
/// [CandlePainter] been designed only used to paint single candle entry.
/// [paintBody] and [paintWick] are template methods,
/// any concrete implementations should override them.
abstract class CandlePainter {
  final CandleSeriesStyle style;
  final HasCoordinator coordinator;

  CandlePainter({
    required this.style,
    required this.coordinator,
  });

  factory CandlePainter.fromType({
    required CandleSeriesStyle style,
    required HasCoordinator coordinator,
  }) {
    switch (style.type ?? CandleType.fill) {
      case CandleType.fill:
        return FillCandlePainter(style: style, coordinator: coordinator);
      case CandleType.outline:
        return OutlineCandlePainter(style: style, coordinator: coordinator);
      case CandleType.ohlc:
        return OHLCandlePainter(style: style, coordinator: coordinator);
    }
  }

  void paint(
    Canvas canvas, {
    required CandleEntry candle,
    required int position,
  }) {
    /// Swap default value
    final high = candle.high ?? candle.lower;
    final lower = candle.lower ?? candle.high;
    final open = candle.open ?? candle.close;
    final close = candle.close ?? candle.open;
    final color = _colorForCandle(candle);

    Rect? body;
    bool isBodyPainted = false;

    /// 最高价，最低价至少一个有值才绘制烛体
    if (open != null && close != null) {
      final distance = style.distance;

      final gridBody =
          Rect.fromLTRB(position - 0.5, open, position + 0.5, close);
      body = coordinator.convertRectFromGrid(gridBody);
      if (distance != null) {
        final delta = distance.apply(body.width) / 2;
        body = Rect.fromLTRB(
          body.left + delta,
          body.top,
          body.right - delta,
          body.bottom,
        );
      }

      final lineStyle = style.lineStyle;

      /// 蜡体宽度不高于线宽时，跳过绘制
      if (body.width > (lineStyle?.size ?? 1)) {
        paintBody(
          canvas,
          rect: body,
          color: color,
        );
        isBodyPainted = true;
      }
    }

    if (high != null && lower != null) {
      final line = Rect.fromPoints(
        Offset(position.toDouble(), high),
        Offset(position.toDouble(), lower),
      );

      paintWick(
        canvas,
        line: coordinator.convertRectFromGrid(line),
        body: when(isBodyPainted, body),
        color: color,
      );
    }
  }

  /// Paint body of candle.
  void paintBody(
    Canvas canvas, {
    required Rect rect,
    required Color color,
  });

  /// Paint wick of candle.
  void paintWick(
    Canvas canvas, {
    required Rect line,
    Rect? body,
    required Color color,
  });

  Color _colorForCandle(CandleEntry candle) {
    switch (candle.direction) {
      case CandleDirection.rise:
        return style.riseColor ?? Colors.red;
      case CandleDirection.fall:
        return style.fallColor ?? Colors.green;
      case CandleDirection.undefined:
        return style.riseColor ?? Colors.red;
    }
  }
}
