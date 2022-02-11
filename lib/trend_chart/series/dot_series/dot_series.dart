import 'package:flutter/material.dart';

import '../../common/render_params.dart';
import '../../grid/grid.dart';
import '../series.dart';
import 'dot_series_painter.dart';
import 'dot_series_style.dart';

typedef ColorConvertor<T> = Color Function(T);

class DotSeries extends Series<double> {
  final DotSeriesStyle _style;
  final ColorConvertor<int>? _colorFn;

  DotSeries(
    List<double> datas, {
    DotSeriesStyle? style,
    ValueConvertor<double>? yValue,
    ColorConvertor<int>? color,
  })  : _style = DotSeriesStyle().merge(style),
        _colorFn = color,
        super(
          datas: datas,
          yValue: yValue ??
              _DefaultDotSeriesYValueConvertor._defaultDotSeriesYValue,
        );

  DotSeriesStyle get style => _style;

  ColorConvertor<int>? get colorFn => _colorFn;

  // @override
  // CustomPainter createPainter(RenderParams renderParams, ) =>
  @override
  CustomPainter createPainter(
    RenderParams renderParams, {
    required Grid grid,
  }) =>
      DotSeriesPainter(
        series: this,
        renderParams: renderParams,
        grid: grid,
      );

  @override
  operator ==(Object other) =>
      identical(this, other) ||
      other is DotSeries &&
          _style == other._style &&
          _colorFn == other._colorFn &&
          super == other;

  @override
  int get hashCode => hashValues(
        super.hashCode,
        _style,
        _colorFn,
      );
}

class _DefaultDotSeriesYValueConvertor {
  static double _defaultDotSeriesYValue(
    double dy,
    int index,
    Series<double> series,
  ) {
    return dy;
  }
}
