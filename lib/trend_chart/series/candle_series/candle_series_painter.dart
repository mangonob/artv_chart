import 'package:artv_chart/trend_chart/common/painter/line_painter.dart';
import 'package:artv_chart/trend_chart/common/style.dart';
import 'package:flutter/material.dart';

import '../../chart_coordinator.dart';
import '../../common/painter/padding_painter.dart';
import '../../common/render_params.dart';
import '../../grid/grid.dart';
import 'candle_entry.dart';
import 'candle_series.dart';
import 'candle_series_style.dart';

class CandleSeriesPainter extends CustomPainter
    with HasCoordinator, CoordinatorProvider {
  final Grid grid;
  final CandleSeries series;
  final RenderParams renderParams;

  CandleSeriesPainter({
    required this.series,
    required this.grid,
    required this.renderParams,
  });

  @override
  ChartCoordinator createCoordinator(Size size) => ChartCoordinator(
        grid: grid,
        size: size,
        renderParams: renderParams,
      );

  @override
  bool shouldRepaint(covariant CandleSeriesPainter oldDelegate) => true;

  @override
  void paint(Canvas canvas, Size size) {
    PaddingPainter().paint(canvas, size,
        padding: grid.style.margin?.copyWith(left: 0, right: 0),
        routine: (Canvas canvas, Size size) {
      coordinator = createCoordinator(size);
      switch (series.style.type ?? CandleType.fill) {
        case CandleType.fill:
          _paintFillCandles(canvas, size);
          break;
        case CandleType.outline:
          _paintOutletCandles(canvas, size);
          break;
        case CandleType.ohlc:
          _paintOHLC(canvas, size);
          break;
      }
    });
  }

  /// 实心K线
  _paintFillCandles(Canvas canvas, Size size) {
    final valueRange = coordinator.xRange.intersection(renderParams.xRange);
    final lineStyle = series.style.lineStyle;
    final distance = series.style.distance;

    valueRange
        .toIterable()
        .where((idx) => idx >= 0 && idx < series.datas.length)
        .forEach((index) {
      final candle = series.datas[index];

      /// Swap default value
      final high = candle.high ?? candle.lower;
      final lower = candle.lower ?? candle.high;
      final open = candle.open ?? candle.close;
      final close = candle.close ?? candle.open;

      /// 最高价，最低价至少一个有值才绘制烛体
      if (open != null && close != null) {
        final gridBody = Rect.fromLTRB(index - 0.5, open, index + 0.5, close);
        var body = convertRectFromGrid(gridBody);
        if (distance != null) {
          final delta = distance.apply(body.width) / 2;
          body = Rect.fromLTRB(
            body.left + delta,
            body.top,
            body.right - delta,
            body.bottom,
          );
        }

        /// 蜡体宽度低于线宽时，跳过绘制
        if (body.width >= (lineStyle?.size ?? 1)) {
          canvas.drawRect(
            body,
            Paint()..color = _colorForCandle(candle),
          );
        }
      }

      if (high != null && lower != null) {
        final line = Rect.fromPoints(
          Offset(index.toDouble(), high),
          Offset(index.toDouble(), lower),
        );

        LinePainter().paint(
          canvas,
          start: convertPointFromGrid(line.topLeft),
          end: convertPointFromGrid(line.bottomLeft),
          style: const LineStyle(
            size: 1,
          ).merge(lineStyle).copyWith(color: _colorForCandle(candle)),
        );
      }
    });
  }

  /// 空心K线
  _paintOutletCandles(Canvas canvas, Size size) {
    final valueRange = coordinator.xRange.intersection(renderParams.xRange);
    final lineStyle = const LineStyle(size: 1).merge(series.style.lineStyle);
    final distance = series.style.distance;

    valueRange
        .toIterable()
        .where((idx) => idx >= 0 && idx < series.datas.length)
        .forEach((index) {
      final candle = series.datas[index];

      /// Swap default value
      final high = candle.high ?? candle.lower;
      final lower = candle.lower ?? candle.high;
      final open = candle.open ?? candle.close;
      final close = candle.close ?? candle.open;

      /// 最高价，最低价至少一个有值才绘制烛体
      if (open != null && close != null) {
        final gridBody = Rect.fromLTRB(index - 0.5, open, index + 0.5, close);
        var body = convertRectFromGrid(gridBody);
        if (distance != null) {
          final delta = distance.apply(body.width) / 2;
          body = Rect.fromLTRB(
            body.left + delta,
            body.top,
            body.right - delta,
            body.bottom,
          );
        }

        /// 蜡体宽度低于线宽时，跳过绘制
        if (body.width >= (lineStyle.size ?? 1)) {
          canvas.drawRect(
            body.deflate((lineStyle.size ?? 1) / 2),
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = lineStyle.size ?? 1
              ..color = _colorForCandle(candle),
          );
        }
      }

      if (high != null && lower != null) {
        final line = Rect.fromPoints(
          Offset(index.toDouble(), high),
          Offset(index.toDouble(), lower),
        );

        LinePainter().paint(
          canvas,
          start: convertPointFromGrid(line.topLeft),
          end: convertPointFromGrid(line.bottomLeft),
          style: const LineStyle(
            size: 1,
          ).merge(lineStyle).copyWith(color: _colorForCandle(candle)),
        );
      }
    });
  }

  /// 美国线
  _paintOHLC(Canvas canvas, Size size) {}

  Color _colorForCandle(CandleEntry candle) {
    switch (candle.direction) {
      case CandleDirection.rise:
        return series.style.riseColor ?? Colors.red;
      case CandleDirection.fall:
        return series.style.fallColor ?? Colors.green;
      case CandleDirection.undefined:
        return series.style.riseColor ?? Colors.red;
    }
  }
}
