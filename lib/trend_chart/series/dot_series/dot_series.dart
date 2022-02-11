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
    DotSeriesStyle? dotSeriesStyle,
    ValueConvertor<double>? yValue,
    ColorConvertor<int>? color,
  })  : _style = DotSeriesStyle().merge(dotSeriesStyle),
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
