import 'package:artv_chart/trend_chart/common/style.dart';
import 'package:flutter/material.dart';

import '../../common/render_params.dart';
import '../../common/style.dart';
import '../../grid/grid.dart';
import '../series.dart';
import 'line_series_painter.dart';

class LineSeries extends Series<Offset> {
  final LineStyle _style;

  LineSeries(
    List<Offset> datas, {
    LineStyle? lineStyle,
    ValueConvertor<Offset>? yValue,
  })  : _style = const LineStyle(color: Colors.green).merge(lineStyle),
        super(
          datas: datas,
          yValue: yValue ??
              _DefaultLineSeriesYValueConvertor._defaultLineSeriesYValue,
        );

  LineStyle get style => _style;

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
