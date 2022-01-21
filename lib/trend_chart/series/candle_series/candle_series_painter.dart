import 'package:artv_chart/trend_chart/chart_coordinator.dart';
import 'package:artv_chart/trend_chart/common/painter/padding_painter.dart';
import 'package:artv_chart/trend_chart/common/render_params.dart';
import 'package:artv_chart/trend_chart/grid/grid.dart';
import 'package:artv_chart/trend_chart/series/candle_series/candle_entry.dart';
import 'package:artv_chart/trend_chart/series/candle_series/candle_series.dart';
import 'package:artv_chart/trend_chart/series/candle_series/candle_series_style.dart';
import 'package:flutter/material.dart';

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
        clip: true, routine: (Canvas canvas, Size size) {
      coordinator = createCoordinator(size);
      switch (series.style.style ?? CandleStyle.fill) {
        case CandleStyle.fill:
          _paintFillCandles(canvas, size);
          break;
        case CandleStyle.outlet:
          _paintOutletCandles(canvas, size);
          break;
        case CandleStyle.ohlc:
          _paintOHLC(canvas, size);
          break;
      }
    });
  }

  /// 实心K线
  _paintFillCandles(Canvas canvas, Size size) {
    final valueRange = coordinator.xRange.intersection(renderParams.xRange);
    valueRange
        .toIterable()
        .where((idx) => idx > 0 && idx < series.datas.length)
        .forEach((index) {
      final candle = series.datas[index];

      final high = candle.high ?? candle.lower;
      final lower = candle.lower ?? candle.high;
      final open = candle.open ?? candle.close;
      final close = candle.close ?? candle.open;

      if (high != null) {
        /// 最高价，最低价至少有一个才绘制烛体
        final body = Rect.fromLTWH(index - 0.5, high, 1, high - lower!);
        canvas.drawRect(
          convertRectFromGrid(body),
          Paint()..color = _colorForCandle(candle),
        );
      }
    });
  }

  /// 空心K线
  _paintOutletCandles(Canvas canvas, Size size) {}

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
