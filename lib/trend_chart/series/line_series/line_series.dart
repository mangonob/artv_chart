import 'package:flutter/material.dart';

import '../../common/render_params.dart';
import '../../grid/grid.dart';
import '../series.dart';
import 'line_series_painter.dart';
import 'line_series_style.dart';

class LineSeries extends Series<double> {
  final LineSeriesStyle _style;

  LineSeries(
    List<double> datas, {
    LineSeriesStyle? lineSeriesStyle,
    ValueConvertor<double>? yValue,
  })  : _style = LineSeriesStyle().merge(lineSeriesStyle),
        super(
          datas: datas,
          yValue: yValue ??
              _DefaultLineSeriesYValueConvertor._defaultLineSeriesYValue,
        );

  LineSeriesStyle get style => _style;

  // @override
  // CustomPainter createPainter(RenderParams renderParams, ) =>
  @override
  CustomPainter createPainter(
    RenderParams renderParams, {
    required Grid grid,
  }) =>
      LineSeriesPainter(
        series: this,
        renderParams: renderParams,
        grid: grid,
      );
}

class _DefaultLineSeriesYValueConvertor {
  static double _defaultLineSeriesYValue(
    double yValue,
    int index,
    Series<double> series,
  ) {
    return yValue;
  }
}
