import 'package:flutter/material.dart';

import '../../common/render_params.dart';
import '../../grid/grid.dart';
import 'line_series.dart';

class LineSeriesPainter extends CustomPainter {
  final LineSeries series;
  final RenderParams renderParams;
  final Grid grid;

  LineSeriesPainter({
    required this.series,
    required this.renderParams,
    required this.grid,
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
