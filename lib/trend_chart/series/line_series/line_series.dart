import 'package:artv_chart/trend_chart/series/line_series/line_series_painter.dart';
import 'package:flutter/material.dart';

import '../series.dart';

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
  CustomPainter createPainter() => LineSeriesPainter(
        series: this,
      );
}
