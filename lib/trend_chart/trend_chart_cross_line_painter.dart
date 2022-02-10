import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

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
      if (info != null && info!.visibleGridEntries.isNotEmpty) {
        final entry = info!.visibleGridEntries.first;
        _coordinator = entry.createCoordinator(renderParams: renderParams);
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
                  .convertPointToGrid(renderParams.focusLocation)
                  .dx
                  .roundToDouble(),
              0,
            ),
          )
          .dx,
      renderParams.focusLocation.dy,
    );

    if (renderParams.focusLocation == kNullLocation) return;

    // Paint vertical line
    if (focusLocation.dx.isValid) {
      LinePainter().paint(
        canvas,
        start: Offset(focusLocation.dx, _padding().top),
        end: Offset(focusLocation.dx, size.height - _padding().bottom),
        style: chart.crossLineStyle,
      );
    }

    if (info != null) {
      final maybeFocusEntry = info!.visibleGridEntries
          .where((e) => e.gridRect.contains(focusLocation))
          .firstOrNull;

      final crossLocation = maybeFocusEntry?.getCrossLineLocation(
            focusLocation,
            renderParams: renderParams,
          ) ??
          focusLocation;

      for (final entry in info!.visibleGridEntries) {
        final grid = entry.grid;
        final contentRect = entry.contentRect;

        /// Paint horizontal line if needed
        if (contentRect.contains(crossLocation) && crossLocation.dy.isValid) {
          LinePainter().paint(
            canvas,
            start: Offset(0, crossLocation.dy),
            end: Offset(size.width, crossLocation.dy),
            style: chart.crossLineStyle,
          );
        }

        for (final attch in grid.attachments) {
          canvas.save();
          canvas.translate(contentRect.left, contentRect.top);
          attch.createPainter(renderParams: renderParams).paint(
                canvas,
                contentRect.size,
                crossLineLocation: crossLocation.translate(
                  -contentRect.left,
                  -contentRect.top,
                ),
              );
          canvas.restore();
        }
      }
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
