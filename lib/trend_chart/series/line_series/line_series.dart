import 'package:flutter/material.dart';

import '../../common/render_params.dart';
import '../../grid/grid.dart';
import '../series.dart';
import 'line_series_painter.dart';
import 'line_series_style.dart';

class LineSeries extends Series<Offset> {
  final LineSeriesStyle _style;

  LineSeries(
    List<Offset> datas, {
    LineSeriesStyle? lineSeriesStyle,
    ValueConvertor<Offset>? yValue,
  })  : _style =
            LineSeriesStyle(lineColor: Colors.green).merge(lineSeriesStyle),
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
    Offset offset,
    int index,
    Series<Offset> series,
  ) {
    return offset.dy;
  }
}
