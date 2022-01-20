import 'package:flutter/material.dart';

import '../../common/render_params.dart';
import '../../grid/grid.dart';
import '../series.dart';
import 'line_series_painter.dart';

class LineSeries extends Series<Offset> {
  LineSeries(
    List<Offset> datas, {
    int gridIndex = 0,
    required ValueConvertor<Offset> yValue,
  }) : super(
          datas: datas,
          yValue: yValue,
        );

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
