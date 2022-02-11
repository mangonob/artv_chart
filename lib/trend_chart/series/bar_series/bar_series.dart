import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../common/range.dart';
import '../../common/render_params.dart';
import '../../grid/grid.dart';
import '../series.dart';
import 'bar_series_painter.dart';
import 'bar_series_style.dart';

class BarSeries extends Series<double> {
  final BarSeriesStyle _style;
  final bool isAlwaysPositive;

  BarSeriesStyle get style => _style;

  BarSeries(
    List<double> datas, {
    ValueConvertor<double>? yValue,
    BarSeriesStyle? style,
    this.isAlwaysPositive = false,
  })  : _style = BarSeriesStyle().merge(style),
        super(
          datas: datas,
          yValue: yValue ??
              _DefaultBarSeriesYValueConvertor._defaultBarSeriesYValue,
        );

  @override
  CustomPainter createPainter(
    RenderParams renderParams, {
    required Grid grid,
  }) =>
      BarSeriesPainter(
        series: this,
        grid: grid,
        renderParams: renderParams,
      );

  @override
  operator ==(Object other) =>
      identical(this, other) ||
      other is BarSeries &&
          _style == other._style &&
          isAlwaysPositive == other.isAlwaysPositive &&
          super == other;

  @override
  int get hashCode => hashValues(
        super.hashCode,
        _style,
        isAlwaysPositive,
      );

  @override
  Range yRange(Range xRange) {
    if (!isAlwaysPositive) {
      return super.yRange(xRange);
    } else {
      if (yValue == null) {
        return const Range.empty();
      } else {
        final yValues = this.yValues(xRange);

        return yValues.foldIndexed(
          const Range.empty(),
          (index, range, value) => range.extend(value.abs()),
        );
      }
    }
  }
}

class _DefaultBarSeriesYValueConvertor {
  static double _defaultBarSeriesYValue(
    double dy,
    int index,
    Series<double> series,
  ) {
    return dy;
  }
}
