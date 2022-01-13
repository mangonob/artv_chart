import 'package:artv_chart/trend_chart/layout_info.dart';
import 'package:artv_chart/trend_chart/series/line_series/line_series_painter.dart';
import 'package:flutter/material.dart';

import '../series.dart';

class LineSeries extends Series<double> {
  LineSeries(List<double> datas) : super(datas: datas);

  @override
  CustomPainter createPainter({
    required LayoutDetails details,
  }) =>
      LineSeriesPainter(
        layoutDetails: details,
        series: this,
      );
}
