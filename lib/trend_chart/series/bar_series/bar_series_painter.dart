import 'dart:math';

import 'package:artv_chart/trend_chart/common/painter/padding_painter.dart';
import 'package:artv_chart/trend_chart/common/range.dart';
import 'package:artv_chart/trend_chart/common/render_params.dart';
import 'package:artv_chart/trend_chart/grid/grid.dart';
import 'package:flutter/material.dart';

import '../../chart_coordinator.dart';
import 'bar_series.dart';

class BarSeriesPainter extends CustomPainter
    with CoordinatorProvider, HasCoordinator {
  final BarSeries series;
  final RenderParams renderParams;
  final Grid grid;

  BarSeriesPainter({
    required this.series,
    required this.renderParams,
    required this.grid,
  });

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) =>
      oldDelegate != this;

  @override
  operator ==(Object other) =>
      other is BarSeriesPainter &&
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

  @override
  void paint(Canvas canvas, Size size) {
    if (series.datas.isEmpty) return;
    if (series.style.width != null) {
      _paintWidthBody(canvas, size);
    } else {
      _paintBody(canvas, size);
    }
  }

  ///宽度不固定，宽度和间距会缩放
  void _paintBody(Canvas canvas, Size size) {
    PaddingPainter().paint(canvas, size,
        padding: grid.style.margin?.copyWith(left: 0, right: 0),
        routine: (Canvas canvas, Size size) {
      coordinator = createCoordinator(size);
      final valueRange = coordinator.xRange.intersection(renderParams.xRange);
      valueRange
          .toIterable()
          .where((idx) => idx >= 0 && idx < series.datas.length)
          .forEach(
        (index) {
          final gridBody = Rect.fromLTRB(
            index - 0.5,
            _getTop(series.datas[index], coordinator.yRange),
            index + 0.5,
            _getBottom(series.datas[index], coordinator.yRange),
          );
          Rect? body = coordinator.convertRectFromGrid(gridBody);
          if (series.style.distance != null) {
            final delta = series.style.distance!.apply(body.width) / 2;
            body = Rect.fromLTRB(
              body.left + delta,
              body.top,
              body.right - delta,
              body.bottom,
            );
          }
          canvas.drawRect(
            body,
            Paint()
              ..color = series.datas[index] > 0
                  ? series.style.riseColor!
                  : series.style.fallColor!,
          );
        },
      );
    });
  }

  ///宽度固定，间距会缩放
  void _paintWidthBody(Canvas canvas, Size size) {
    PaddingPainter().paint(canvas, size,
        padding: grid.style.margin?.copyWith(left: 0, right: 0),
        routine: (Canvas canvas, Size size) {
      coordinator = createCoordinator(size);
      final valueRange = coordinator.xRange.intersection(renderParams.xRange);
      valueRange
          .toIterable()
          .where((idx) => idx >= 0 && idx < series.datas.length)
          .forEach(
        (index) {
          final gridBody = coordinator.convertRectFromGrid(Rect.fromLTRB(
            index.toDouble(),
            _getTop(series.datas[index], coordinator.yRange),
            index + 1.0,
            _getBottom(series.datas[index], coordinator.yRange),
          ));
          final body = Rect.fromPoints(
            Offset(
                gridBody.bottomLeft.dx -
                    min((series.style.width ?? 0), renderParams.unit) / 2,
                gridBody.bottomLeft.dy),
            Offset(
                gridBody.bottomLeft.dx +
                    min((series.style.width ?? 0), renderParams.unit) / 2,
                gridBody.topRight.dy),
          );
          canvas.drawRect(
            body,
            Paint()
              ..color = series.datas[index] > 0
                  ? series.style.riseColor!
                  : series.style.fallColor!,
          );
        },
      );
    });
  }

  ///如果上涨，那最高点就是Y的值
  ///否则如果range包含0 就从0开始，不然就从upper开始
  double _getTop(double dy, Range range) {
    double result = 0;
    if (dy > 0) {
      result = dy;
    } else {
      result = range.contains(0) ? 0 : range.upper;
    }
    return result;
  }

  ///如果上涨，range包含0 就从0开始，不然就从lower开始
  ///否则最低点就是dy的值
  double _getBottom(double dy, Range range) {
    double result = 0;
    if (dy > 0) {
      result = range.contains(0) ? 0 : range.lower;
    } else {
      result = dy;
    }
    return result;
  }
}
