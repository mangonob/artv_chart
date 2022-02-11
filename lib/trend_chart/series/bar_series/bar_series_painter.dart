import 'dart:math';

import 'package:flutter/material.dart';

import '../../chart_coordinator.dart';
import '../../common/painter/padding_painter.dart';
import '../../common/range.dart';
import '../../common/render_params.dart';
import '../../grid/grid.dart';
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
      _paintRect(canvas, size);
    }
  }

  ///宽度不固定，宽度和间距会缩放
  void _paintRect(Canvas canvas, Size size) {
    PaddingPainter().paint(canvas, size,
        padding: grid.style.margin?.copyWith(left: 0, right: 0),
        routine: (Canvas canvas, Size size) {
      coordinator = createCoordinator(size);
      if (coordinator.yRange.contains(double.nan) ||
          coordinator.xRange.upper < 0) return;
      final valueRange = coordinator.xRange.intersection(renderParams.xRange);
      canvas.drawRect(
        _getBarRect(valueRange.lower.floor()),
        Paint()
          ..color = series.datas[max(0, valueRange.lower.floor())] > 0
              ? series.style.riseColor!
              : series.style.fallColor!,
      );
      valueRange
          .toIterable()
          .where((idx) => idx >= 0 && idx < series.datas.length)
          .forEach(
        (index) {
          canvas.drawRect(
            _getBarRect(index),
            Paint()
              ..color = series.datas[index] > 0
                  ? series.style.riseColor!
                  : series.style.fallColor!,
          );

          if (index == valueRange.upper.floor() &&
              index < series.datas.length - 1) {
            canvas.drawRect(
              _getBarRect(index + 1),
              Paint()
                ..color = series.datas[index + 1] > 0
                    ? series.style.riseColor!
                    : series.style.fallColor!,
            );
          }
        },
      );
    });
  }

  ///根据range的index获取宽度不固定的rect，此时rect的宽度根据distance缩放
  Rect _getBarRect(int index) {
    final gridBody = Rect.fromLTRB(
      index - 0.5,
      _getTop(
          series.isAlwaysPositive
              ? series.datas[index].abs()
              : series.datas[index],
          coordinator.yRange),
      index + 0.5,
      _getBottom(
          series.isAlwaysPositive
              ? series.datas[index].abs()
              : series.datas[index],
          coordinator.yRange),
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
    return body;
  }

  ///绘制宽度固定，间距会缩放的rect
  void _paintWidthBody(Canvas canvas, Size size) {
    PaddingPainter().paint(canvas, size,
        padding: grid.style.margin?.copyWith(left: 0, right: 0),
        routine: (Canvas canvas, Size size) {
      coordinator = createCoordinator(size);
      if (coordinator.yRange.contains(double.nan) ||
          coordinator.xRange.upper < 0) return;
      final valueRange = coordinator.xRange.intersection(renderParams.xRange);
      valueRange
          .toIterable()
          .where((idx) => idx >= 0 && idx < series.datas.length)
          .forEach(
        (index) {
          canvas.drawRect(
            _getWidthBarRect(index),
            Paint()
              ..color = series.datas[index] > 0
                  ? series.style.riseColor!
                  : series.style.fallColor!,
          );
        },
      );
    });
  }

  ///根据range的index获取宽度固定的rect，此时rect的最大宽度不能大于renderParams.unit
  Rect _getWidthBarRect(int index) {
    final gridBody = coordinator.convertRectFromGrid(Rect.fromLTRB(
      index.toDouble(),
      _getTop(
          series.isAlwaysPositive
              ? series.datas[index].abs()
              : series.datas[index],
          coordinator.yRange),
      index + 1.0,
      _getBottom(
          series.isAlwaysPositive
              ? series.datas[index].abs()
              : series.datas[index],
          coordinator.yRange),
    ));
    return Rect.fromPoints(
      Offset(
          gridBody.bottomLeft.dx -
              min((series.style.width ?? 0), renderParams.unit) / 2,
          gridBody.bottomLeft.dy),
      Offset(
          gridBody.bottomLeft.dx +
              min((series.style.width ?? 0), renderParams.unit) / 2,
          gridBody.topRight.dy),
    );
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
