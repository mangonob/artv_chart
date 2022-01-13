import 'package:artv_chart/trend_chart/layout_info.dart';
import 'package:artv_chart/trend_chart/series/line_series/line_series.dart';
import 'package:flutter/material.dart';

class LineSeriesPainter extends CustomPainter {
  final LayoutDetails layoutDetails;
  final LineSeries series;

  LineSeriesPainter({
    required this.layoutDetails,
    required this.series,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) =>
      oldDelegate != this;

  @override
  operator ==(Object other) =>
      other is LineSeriesPainter &&
      layoutDetails == other.layoutDetails &&
      series == other.series;

  @override
  int get hashCode => hashValues(
        layoutDetails,
        series,
      );
}
