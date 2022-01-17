import 'package:flutter/material.dart';

import '../../common/render_params.dart';
import 'line_series.dart';

class LineSeriesPainter extends CustomPainter {
  final LineSeries series;
  final RenderParams renderParams;

  LineSeriesPainter({
    required this.series,
    required this.renderParams,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: Draw line code
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) =>
      oldDelegate != this;

  @override
  operator ==(Object other) =>
      other is LineSeriesPainter &&
      series == other.series &&
      renderParams == other.renderParams;

  @override
  int get hashCode => hashValues(
        series,
        renderParams,
      );
}
