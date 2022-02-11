import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../chart_coordinator.dart';
import '../../common/painter/padding_painter.dart';
import '../../common/render_params.dart';
import '../../grid/grid.dart';
import 'line_series.dart';

class LineSeriesPainter extends CustomPainter
    with CoordinatorProvider, HasCoordinator {
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
    _paintLineChart(canvas, size);
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
    if (series.style.gradientColors?.isNotEmpty ?? false) {
      _paintFill(canvas, size);
    }
  }

  void _paintLine(Canvas canvas, Size size) {
    PaddingPainter().paint(canvas, size,
        padding: grid.style.margin?.copyWith(left: 0, right: 0),
        routine: (Canvas canvas, Size size) {
      coordinator = createCoordinator(size);
      prepareCoordnator(size);
      if (coordinator.yRange.contains(double.nan) ||
          coordinator.xRange.upper < 0) return;

      _offsetList.clear();
      final valueRange = coordinator.xRange.intersection(renderParams.xRange);

      ///往左边画一个点
      _offsetList.add(
        convertPointFromGrid(
          Offset(
            valueRange.lower.floorToDouble(),
            series.datas[max(0, valueRange.lower.floor())],
          ),
        ),
      );
      List<Offset> tempList = valueRange
          .toIterable()
          .where((idx) => idx >= 0 && idx < series.datas.length)
          .map((e) => convertPointFromGrid(
                Offset(
                  e * 1.0,
                  series.datas[e],
                ),
              ))
          .toList();

      ///往右边画一个点
      tempList.add(convertPointFromGrid(
        Offset(
          min(valueRange.upper.ceilToDouble(), series.datas.length - 1),
          series.datas[min(valueRange.upper.ceil(), series.datas.length - 1)],
        ),
      ));
      _offsetList.addAll(tempList);
      canvas.drawPoints(
        _isDrawLine ? PointMode.polygon : PointMode.points,
        _offsetList,
        Paint()
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
      if (coordinator.yRange.contains(double.nan) ||
          coordinator.xRange.upper < 0) return;
      final valueRange = coordinator.xRange.intersection(renderParams.xRange);

      ///往左边界多画一个点
      Offset lowerOffset = convertPointFromGrid(
        Offset(
          valueRange.lower.floorToDouble(),
          series.datas[valueRange.lower.toInt()],
        ),
      );
      linePath.moveTo(lowerOffset.dx, lowerOffset.dy);
      valueRange
          .toIterable()
          .where((idx) => idx >= 0 && idx < series.datas.length)
          .forEach((index) {
        Offset currentOffset = convertPointFromGrid(
          Offset(
            index * 1.0,
            series.datas[index],
          ),
        );
        linePath.lineTo(currentOffset.dx, currentOffset.dy);
      });

      ///往右边多画一个点
      final nextOffset =
          min(valueRange.upper.toInt() + 1, series.datas.length - 1);
      if (nextOffset > 0) {
        Offset upperOffset = convertPointFromGrid(Offset(
            min(valueRange.upper.toInt() + 1, series.datas.length - 1),
            series.datas[nextOffset]));
        linePath.lineTo(upperOffset.dx, upperOffset.dy);
        linePath.lineTo(upperOffset.dx, size.height);
      }
      linePath.lineTo(
          convertPointFromGrid(Offset(valueRange.lower.floorToDouble(),
                  series.datas[valueRange.lower.toInt()]))
              .dx,
          size.height);

      canvas.drawPath(
          linePath,
          Paint()
            ..strokeWidth = series.style.lineStyle!.size!
            ..style = PaintingStyle.fill
            ..strokeCap = _isDrawLine
                ? series.style.lineStyle!.strokeCap!
                : StrokeCap.round
            ..strokeJoin = series.style.lineStyle!.strokeJoin!
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
