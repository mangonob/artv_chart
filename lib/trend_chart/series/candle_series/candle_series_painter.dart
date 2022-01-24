import 'package:flutter/material.dart';

import '../../chart_coordinator.dart';
import '../../common/painter/padding_painter.dart';
import '../../common/render_params.dart';
import '../../grid/grid.dart';
import '../../grid/label/text_label.dart';
import 'candle_series.dart';
import 'painter/candle_painter.dart';
import 'painter/value_remark_painter.dart';

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
  bool shouldRepaint(covariant CandleSeriesPainter oldDelegate) {
    /// TODO Check if we need to repaint
    return oldDelegate.series != series ||
        oldDelegate.grid != grid ||
        oldDelegate.renderParams != renderParams;
  }

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
    final valueRange =
        coordinator.xRange.expand(1, 1).intersection(renderParams.xRange);

    double maxValue = double.negativeInfinity, minValue = double.infinity;
    int? maxIndex, minIndex;

    /// Draw candle entries
    valueRange
        .toIterable()
        .where((idx) => idx >= 0 && idx < series.datas.length)
        .forEach(
      (index) {
        final candle = series.datas[index];
        final range = candle.range;

        if (range.upper > maxValue &&
            coordinator.xRange.contains(index.toDouble())) {
          maxValue = candle.range.upper;
          maxIndex = index;
        }

        if (range.lower < minValue &&
            coordinator.xRange.contains(index.toDouble())) {
          minValue = candle.range.lower;
          minIndex = index;
        }

        CandlePainter.fromType(style: series.style, coordinator: this).paint(
          canvas,
          candle: candle,
          position: index,
        );
      },
    );

    /// Draw boundary label if needed
    if (maxIndex != null && grid.yLabel != null) {
      final label = grid.yLabel!(maxValue);
      if (label is TextLabel) {
        ValueRemarkPainter(coordinator: coordinator).paint(
          canvas,
          content: label.text,
          value: maxValue,
          position: maxIndex!,
          style: series.style.remarkStyle,
        );
      }
    }

    if (minIndex != null && grid.yLabel != null) {
      final label = grid.yLabel!(minValue);
      if (label is TextLabel) {
        ValueRemarkPainter(coordinator: coordinator).paint(
          canvas,
          content: label.text,
          value: minValue,
          position: minIndex!,
          style: series.style.remarkStyle,
        );
      }
    }
  }
}
