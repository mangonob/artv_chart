import 'package:flutter/material.dart';

import '../../chart_coordinator.dart';
import '../../common/painter/padding_painter.dart';
import '../../common/render_params.dart';
import '../../grid/grid.dart';
import 'candle_series.dart';
import 'painter/candle_painter.dart';

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
      _paintCandles(canvas, size);
    });
  }

  _paintCandles(Canvas canvas, Size size) {
    final valueRange = coordinator.xRange.intersection(renderParams.xRange);

    valueRange
        .toIterable()
        .where((idx) => idx >= 0 && idx < series.datas.length)
        .forEach(
      (index) {
        final candle = series.datas[index];

        CandlePainter.fromType(style: series.style, coordinator: this).paint(
          canvas,
          candle: candle,
          position: index,
        );
      },
    );
  }
}
