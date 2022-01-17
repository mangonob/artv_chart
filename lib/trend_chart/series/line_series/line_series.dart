import 'package:flutter/material.dart';

import '../../common/render_params.dart';
import '../series.dart';
import 'line_series_painter.dart';

class LineSeries extends Series<Offset> {
  LineSeries(
    List<Offset> datas, {
    int gridIndex = 0,
    required ValueConvertor<Offset> xValue,
    required ValueConvertor<Offset> yValue,
  }) : super(
          datas: datas,
          gridIndex: gridIndex,
          xValue: xValue,
          yValue: yValue,
        );

  @override
  CustomPainter createPainter(RenderParams renderParams) => LineSeriesPainter(
        series: this,
        renderParams: renderParams,
      );
}
