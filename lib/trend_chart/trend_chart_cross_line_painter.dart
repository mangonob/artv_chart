import 'package:flutter/material.dart';

import 'common/painter/line_painter.dart';
import 'common/render_params.dart';
import 'trend_chart.dart';

class TrendChartCrossLinePainter extends CustomPainter {
  TrendChart chart;
  RenderParams renderParams;
  Offset? focusLocation;

  TrendChartCrossLinePainter({
    required this.chart,
    required this.renderParams,
    this.focusLocation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (focusLocation == null) return;

    canvas.clipRect(
      Rect.fromLTWH(
        0,
        _padding().top,
        size.width,
        size.height - _padding().vertical,
      ),
    );

    LinePainter().paint(
      canvas,
      start: Offset(focusLocation!.dx, 0),
      end: Offset(focusLocation!.dx, size.height),
      style: chart.crossLineStyle,
    );

    if (focusLocation!.dy.isFinite && !focusLocation!.dy.isNaN) {
      LinePainter().paint(
        canvas,
        start: Offset(0, focusLocation!.dy),
        end: Offset(size.width, focusLocation!.dy),
        style: chart.crossLineStyle,
      );
    }
  }

  @override
  bool shouldRepaint(covariant TrendChartCrossLinePainter oldDelegate) {
    return _padding() != oldDelegate._padding() ||
        focusLocation != oldDelegate.focusLocation ||
        renderParams != oldDelegate.renderParams;
  }

  EdgeInsets _padding() {
    if (chart.grids.isEmpty) return EdgeInsets.zero;
    final top = (chart.grids.first.style.margin ?? EdgeInsets.zero).top;
    final bottom = (chart.grids.last.style.margin ?? EdgeInsets.zero).bottom;
    return EdgeInsets.only(top: top, bottom: bottom);
  }
}
