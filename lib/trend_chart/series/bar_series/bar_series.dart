import 'package:artv_chart/trend_chart/series/bar_series/bar_series_style.dart';
import 'package:flutter/material.dart';

import '../../common/render_params.dart';
import '../../grid/grid.dart';
import '../series.dart';
import 'bar_series_painter.dart';

class BarSeries extends Series<Offset> {
  final BarSeriesStyle _style;

  BarSeriesStyle get style => _style;

  BarSeries(
    List<Offset> datas, {
    ValueConvertor<Offset>? yValue,
    BarSeriesStyle? style,
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
      other is BarSeries && _style == other._style && super == other;

  @override
  int get hashCode => hashValues(
        super.hashCode,
        _style,
      );
}

class _DefaultBarSeriesYValueConvertor {
  static double _defaultBarSeriesYValue(
    Offset offset,
    int index,
    Series<Offset> series,
  ) {
    return offset.dy;
  }
}
