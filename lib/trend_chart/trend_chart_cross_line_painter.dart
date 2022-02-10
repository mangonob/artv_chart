import 'package:flutter/material.dart';

import '../utils/utils.dart';
import 'chart_coordinator.dart';
import 'common/painter/line_painter.dart';
import 'common/render_params.dart';
import 'constant.dart';
import 'cross_line_info.dart';
import 'trend_chart.dart';

class TrendChartCrossLinePainter extends CustomPainter {
  TrendChart chart;
  RenderParams renderParams;
  CrossLineInfo? info;

  TrendChartCrossLinePainter({
    required this.chart,
    required this.renderParams,
    this.info,
  });

  ChartCoordinator? _coordinator;
  ChartCoordinator get coordinator {
    if (_coordinator == null) {
      if (info != null) {
        _coordinator = ChartCoordinator(
          grid: info!.grid,
          size: info!.gridRect.size,
          renderParams: renderParams,
        );
      } else {
        _coordinator = ChartCoordinator(
          grid: chart.grids.first,
          size: Size(renderParams.chartWidth, 1),
          renderParams: renderParams,
        );
      }
    }

    return _coordinator!;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final focusLocation = Offset(
      coordinator
          .convertPointFromGrid(
            Offset(
                coordinator
                    .convertPointToGrid(
                        Offset(renderParams.focusLocation.dx, 0))
                    .dx
                    .roundToDouble(),
                0),
          )
          .dx,
      renderParams.focusLocation.dy,
    );

    if (renderParams.focusLocation == kNullLocation) return;

    canvas.clipRect(
      Rect.fromLTWH(
        0,
        _padding().top,
        size.width,
        size.height - _padding().vertical,
      ),
    );

    if (focusLocation.dx.isValid) {
      LinePainter().paint(
        canvas,
        start: Offset(focusLocation.dx, 0),
        end: Offset(focusLocation.dx, size.height),
        style: chart.crossLineStyle,
      );
    }

    if (focusLocation.dy.isValid) {
      LinePainter().paint(
        canvas,
        start: Offset(0, focusLocation.dy),
        end: Offset(size.width, focusLocation.dy),
        style: chart.crossLineStyle,
      );
    }
  }

  @override
  bool shouldRepaint(covariant TrendChartCrossLinePainter oldDelegate) {
    return _padding() != oldDelegate._padding() ||
        renderParams != oldDelegate.renderParams;
  }

  EdgeInsets _padding() {
    if (chart.grids.isEmpty) return EdgeInsets.zero;
    final top = (chart.grids.first.style.margin ?? EdgeInsets.zero).top;
    final bottom = (chart.grids.last.style.margin ?? EdgeInsets.zero).bottom;
    return EdgeInsets.only(top: top, bottom: bottom);
  }
}
