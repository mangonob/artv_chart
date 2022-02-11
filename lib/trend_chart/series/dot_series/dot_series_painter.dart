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
      if (coordinator.yRange.contains(double.nan) ||
          coordinator.xRange.upper < 0) return;
      final valueRange = coordinator.xRange.intersection(renderParams.xRange);

      ///往左边多画一个点
      _drawCircle(
        canvas,
        Offset(
          valueRange.lower.floorToDouble(),
          series.datas[max(0, valueRange.lower.floor())],
        ),
        valueRange.lower.floor(),
      );
      valueRange
          .toIterable()
          .where((idx) => idx >= 0 && idx < series.datas.length)
          .forEach(
        (index) {
          _drawCircle(
            canvas,
            Offset(
              index * 1.0,
              series.datas[index],
            ),
            index,
          );

          ///往右边多画一个点
          if (index == valueRange.upper.floor() &&
              index < series.datas.length - 1) {
            _drawCircle(
              canvas,
              Offset(
                index + 1,
                series.datas[index + 1],
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
      convertPointFromGrid(offset),
      series.style.circleRadius!,
      Paint()
        ..strokeWidth = series.style.lineStyle!.size!
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
