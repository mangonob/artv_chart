
import 'package:artv_chart/trend_chart/common/painter/padding_painter.dart';
import 'package:artv_chart/trend_chart/common/range.dart';
import 'package:artv_chart/trend_chart/common/render_params.dart';
import 'package:artv_chart/trend_chart/grid/grid.dart';
import 'package:flutter/material.dart';

import '../../chart_coordinator.dart';
import 'bar_series.dart';

class BarSeriesPainter extends CustomPainter
    with HasCoordinator, CoordinatorProvider {
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
    canvas.save();
    _paintBody(canvas, size);
    canvas.restore();
  }

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
              ..color = series.datas[index].dy > 0
                  ? series.style.riseColor!
                  : series.style.fallColor!,
          );
        },
      );
    });
  }

  double _getTop(Offset offset, Range range) {
    double result = 0;
    if (offset.dy > 0) {
      result = offset.dy;
    } else {
      result = range.contains(0) ? 0 : range.upper;
    }
    return result;
  }

  double _getBottom(Offset offset, Range range) {
    double result = 0;
    if (offset.dy > 0) {
      result = range.contains(0) ? 0 : range.lower;
    } else {
      result = offset.dy;
    }
    return result;
  }
}
