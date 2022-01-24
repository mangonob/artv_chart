import 'dart:math';
import 'dart:ui';

import 'package:artv_chart/trend_chart/common/painter/padding_painter.dart';
import 'package:flutter/material.dart';

import '../../chart_coordinator.dart';
import '../../common/render_params.dart';
import '../../grid/grid.dart';
import 'line_series.dart';

class LineSeriesPainter extends CustomPainter
    with HasCoordinator, CoordinatorProvider {
  final LineSeries series;
  final RenderParams renderParams;
  final Grid grid;

  LineSeriesPainter({
    required this.series,
    required this.renderParams,
    required this.grid,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (series.datas.isEmpty) return;
    canvas.save();
    _paintLineChart(canvas, size);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) =>
      oldDelegate != this;

  @override
  operator ==(Object other) =>
      other is LineSeriesPainter &&
      series == other.series &&
      renderParams == other.renderParams;

  @override
  int get hashCode => hashValues(
        series,
        renderParams,
      );

  final List<Offset> _offsetList = [];

  bool get _isDrawLine => _offsetList.length > 1;

  void _paintLineChart(Canvas canvas, Size size) {
    _paintLine(canvas, size);
    if (series.style.paintingStyle == PaintingStyle.fill) {
      _paintFill(canvas, size);
    }
  }

  void _paintLine(Canvas canvas, Size size) {
    PaddingPainter().paint(canvas, size,
        padding: grid.style.margin?.copyWith(left: 0, right: 0),
        routine: (Canvas canvas, Size size) {
      coordinator = createCoordinator(size);
      _offsetList.clear();
      final valueRange = coordinator.xRange.intersection(renderParams.xRange);
      if (valueRange.lower.toInt() < 0) return;
      valueRange
          .toIterable()
          .where((idx) => idx >= 0 && idx < series.datas.length)
          .forEach(
        (index) {
          _offsetList.add(
            convertPointFromGrid(
              Offset(
                series.datas[max(0, index - 1)].dx,
                series.datas[max(0, index - 1)].dy,
              ),
            ),
          );
          if (index == valueRange.upper.toInt() &&
              index < series.datas.length - 1) {
            _offsetList.add(
              convertPointFromGrid(
                Offset(
                  series.datas[index].dx,
                  series.datas[index].dy,
                ),
              ),
            );
            _offsetList.add(
              convertPointFromGrid(
                Offset(
                  series.datas[index + 1].dx,
                  series.datas[index + 1].dy,
                ),
              ),
            );
          }
        },
      );

      canvas.drawPoints(
        _isDrawLine ? PointMode.polygon : PointMode.points,
        _offsetList,
        Paint()
          ..strokeCap = _isDrawLine ? StrokeCap.butt : StrokeCap.round
          ..color = series.style.lineStyle!.color!
          ..strokeWidth = _isDrawLine
              ? series.style.lineStyle!.size!
              : series.style.singlePointSize!,
      );
    });
  }

  _paintFill(Canvas canvas, Size size) {
    Path linePath = Path();

    PaddingPainter().paint(canvas, size,
        padding: grid.style.margin?.copyWith(left: 0, right: 0),
        routine: (Canvas canvas, Size size) {
      coordinator = createCoordinator(size);
      final valueRange = coordinator.xRange.intersection(renderParams.xRange);
      if (valueRange.lower.toInt() < 0) return;
      Offset lowerOffset = convertPointFromGrid(
        Offset(
          series.datas[valueRange.lower.toInt()].dx,
          series.datas[valueRange.lower.toInt()].dy,
        ),
      );
      linePath.moveTo(lowerOffset.dx, lowerOffset.dy);
      valueRange
          .toIterable()
          .where((idx) => idx >= 0 && idx < series.datas.length)
          .forEach((index) {
        if (index == valueRange.lower.toInt()) {}
        Offset currentOffset = convertPointFromGrid(
          Offset(
            series.datas[index].dx,
            series.datas[index].dy,
          ),
        );
        linePath.lineTo(currentOffset.dx, currentOffset.dy);
      });

      ///往右边多画一个点
      Offset upperOffset = convertPointFromGrid(Offset(
          series
              .datas[min(valueRange.upper.toInt() + 1, series.datas.length - 1)]
              .dx,
          series
              .datas[min(valueRange.upper.toInt() + 1, series.datas.length - 1)]
              .dy));
      linePath.lineTo(upperOffset.dx, upperOffset.dy);
      linePath.lineTo(upperOffset.dx, size.height);
      linePath.lineTo(
          convertPointFromGrid(Offset(series.datas[valueRange.lower.toInt()].dx,
                  series.datas[valueRange.lower.toInt()].dy))
              .dx,
          size.height);

      canvas.drawPath(
          linePath,
          Paint()
            ..isAntiAlias = true
            ..strokeWidth = 1.0
            ..style = PaintingStyle.fill
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              tileMode: TileMode.clamp,
              colors: series.style.gradientColors!,
            ).createShader(Offset.zero & size));
    });
  }

  @override
  ChartCoordinator createCoordinator(Size size) => ChartCoordinator(
        grid: grid,
        size: size,
        renderParams: renderParams,
      );
}
