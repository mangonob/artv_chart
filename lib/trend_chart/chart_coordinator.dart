import 'package:flutter/material.dart';

import 'common/range.dart';
import 'common/render_params.dart';
import 'grid/grid.dart';

/// Someting in coordinate system.
mixin CoordinatorProvider {
  ChartCoordinator createCoordinator(Size size);
}

mixin HasCoordinator on CoordinatorProvider {
  late ChartCoordinator coordinator;
  bool isCoordinatorReady = false;

  /// Convert point from grid to screen coordinate.
  Offset convertPointFromGrid(
    Offset point,
  ) =>
      coordinator.convertPointFromGrid(point);

  /// Convert point from screen coordinate to grid .
  Offset convertPointToGrid(
    Offset point,
  ) =>
      coordinator.convertPointToGrid(point);

  /// Convert rect from grid to screen coordinate.
  Rect convertRectFromGrid(
    Rect rect,
  ) =>
      coordinator.convertRectFromGrid(rect);

  /// Convert rect from screen coordinate to grid .
  Rect convertRectToGrid(
    Rect rect,
  ) =>
      coordinator.convertRectToGrid(rect);

  void prepareCoordnator(Size size) {
    coordinator = createCoordinator(size);
    isCoordinatorReady = true;
  }
}

class ChartCoordinator {
  final Grid grid;
  final RenderParams renderParams;
  final Size size;
  late Range xRange;
  late Range yRange;

  ChartCoordinator({
    required this.grid,
    required this.size,
    required this.renderParams,
  }) {
    xRange = grid.xRange(params: renderParams, size: size);
    yRange = grid.yRange(params: renderParams, size: size);
  }

  /// Convert point from grid to screen coordinate.
  Offset convertPointFromGrid(
    Offset point,
  ) {
    final unit = renderParams.unit;
    return Offset(
      (point.dx - xRange.lower) * unit,
      yRange.isEmpty
          ? size.height / 2
          : size.height -
              (point.dy - yRange.lower) * size.height / yRange.length,
    );
  }

  /// Convert point from screen coordinate to grid .
  Offset convertPointToGrid(
    Offset point,
  ) {
    final unit = renderParams.unit;
    return Offset(
      point.dx / unit + xRange.lower,
      (size.height - point.dy) / size.height * yRange.length + yRange.lower,
    );
  }

  /// Convert rect from grid to screen coordinate.
  Rect convertRectFromGrid(
    Rect rect,
  ) {
    return Rect.fromPoints(
      convertPointFromGrid(rect.topLeft),
      convertPointFromGrid(rect.bottomRight),
    );
  }

  /// Convert rect from screen coordinate to grid .
  Rect convertRectToGrid(
    Rect rect,
  ) {
    return Rect.fromPoints(
      convertPointToGrid(rect.topLeft),
      convertPointToGrid(rect.bottomRight),
    );
  }
}
