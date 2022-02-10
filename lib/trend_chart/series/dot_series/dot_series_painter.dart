import 'dart:math';

import 'package:flutter/material.dart';

import '../../chart_coordinator.dart';
import '../../common/painter/padding_painter.dart';
import '../../common/render_params.dart';
import '../../grid/grid.dart';
import 'dot_series.dart';

class DotSeriesPainter extends CustomPainter
    with CoordinatorProvider, HasCoordinator {
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
    _paintCircle(canvas, size);
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
          ///往左边多画一个点
          _drawCircle(
            canvas,
            convertPointFromGrid(
              Offset(
                max(0, index - 1),
                series.datas[max(0, index - 1)],
              ),
            ),
            index,
          );

          ///往右边多画一个点
          if (index == valueRange.upper.toInt() &&
              index < series.datas.length - 1) {
            _drawCircle(
              canvas,
              convertPointFromGrid(
                Offset(
                  index * 1.0,
                  series.datas[index],
                ),
              ),
              index,
            );
            _drawCircle(
              canvas,
              convertPointFromGrid(
                Offset(
                  index + 1,
                  series.datas[index + 1],
                ),
              ),
              index,
            );
          }
        },
      );
    });
  }

  void _drawCircle(Canvas canvas, Offset offset, int index) {
    canvas.drawCircle(
      offset,
      series.style.circleRadius!,
      Paint()
        ..isAntiAlias = series.style.isAntiAlias!
        ..strokeWidth = series.style.strokeWidth!
        ..style = series.style.fillColor != null
            ? PaintingStyle.fill
            : PaintingStyle.stroke
        ..color = series.colorFn?.call(index) ??
            (series.style.fillColor ?? series.style.lineStyle!.color!),
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
