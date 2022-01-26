import 'dart:math';
import 'dart:ui';

import 'package:artv_chart/trend_chart/common/painter/padding_painter.dart';
import 'package:flutter/material.dart';

import '../../chart_coordinator.dart';
import '../../common/render_params.dart';
import '../../grid/grid.dart';
import 'dot_series.dart';

class DotSeriesPainter extends CustomPainter
    with HasCoordinator, CoordinatorProvider {
  final DotSeries series;
  final RenderParams renderParams;
  final Grid grid;

  DotSeriesPainter({
    required this.series,
    required this.renderParams,
    required this.grid,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (series.datas.isEmpty) return;
    canvas.save();
    _paintCircle(canvas, size);
    canvas.restore();
  }

  void _paintCircle(Canvas canvas, Size size) {
    PaddingPainter().paint(canvas, size,
        padding: grid.style.margin?.copyWith(left: 0, right: 0),
        routine: (Canvas canvas, Size size) {
      coordinator = createCoordinator(size);
      final valueRange = coordinator.xRange.intersection(renderParams.xRange);
      if (valueRange.lower.toInt() < 0) return;
      valueRange
          .toIterable()
          .where((idx) => idx >= 0 && idx < series.datas.length)
          .forEach(
        (index) {
          _drawCircle(
              canvas,
              convertPointFromGrid(
                Offset(
                  series.datas[max(0, index - 1)].dx,
                  series.datas[max(0, index - 1)].dy,
                ),
              ));
          if (index == valueRange.upper.toInt() &&
              index < series.datas.length - 1) {
            _drawCircle(
                canvas,
                convertPointFromGrid(
                  Offset(
                    series.datas[index].dx,
                    series.datas[index].dy,
                  ),
                ));
            _drawCircle(
                canvas,
                convertPointFromGrid(
                  Offset(
                    series.datas[index + 1].dx,
                    series.datas[index + 1].dy,
                  ),
                ));
          }
        },
      );
    });
  }

  void _drawCircle(Canvas canvas, Offset offset) {
    canvas.drawCircle(
      offset,
      3,
      Paint()
        ..isAntiAlias = true
        ..strokeWidth = series.style.circleSize!
        ..style = series.style.paintingStyle!
        ..color = series.color.call(offset),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) =>
      oldDelegate != this;

  @override
  operator ==(Object other) =>
      other is DotSeriesPainter &&
      series == other.series &&
      renderParams == other.renderParams;

  @override
  int get hashCode => hashValues(
        series,
        renderParams,
      );

  @override
  ChartCoordinator createCoordinator(Size size) => ChartCoordinator(
        grid: grid,
        size: size,
        renderParams: renderParams,
      );
}
