import 'package:flutter/material.dart';

import '../utils/extensions/geometry_extensions.dart';
import 'chart_coordinator.dart';
import 'common/render_params.dart';
import 'grid/grid.dart';

class CrossLineEntry {
  /// Current focused grid
  final Grid grid;

  /// Rect of current focused grid in chart coordinate
  final Rect gridRect;

  CrossLineEntry({
    required this.grid,
    required this.gridRect,
  });

  Rect get contentRect => gridRect.inset(grid.style.margin ?? EdgeInsets.zero);

  ChartCoordinator createCoordinator({required RenderParams renderParams}) =>
      ChartCoordinator(
        grid: grid,
        size: contentRect.size,
        renderParams: renderParams,
      );

  Offset getCrossLineLocation(
    Offset focusLocation, {
    required RenderParams renderParams,
  }) {
    final yValueFn = grid.yValueForCrossLine;
    if (yValueFn != null && renderParams.focusPosition != null) {
      final focusY = yValueFn.call(grid, renderParams.focusPosition!);
      final coordinator = createCoordinator(renderParams: renderParams);
      return Offset(
        focusLocation.dx + contentRect.left,
        coordinator.convertPointFromGrid(Offset(0, focusY)).dy +
            contentRect.top,
      );
    } else {
      return focusLocation;
    }
  }
}

class CrossLineInfo {
  final List<CrossLineEntry> visibleGridEntries;

  CrossLineInfo({
    required this.visibleGridEntries,
  });
}
