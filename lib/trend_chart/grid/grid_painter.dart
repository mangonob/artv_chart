import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../utils/utils.dart';
import '../chart_coordinator.dart';
import '../common/painter/line_painter.dart';
import '../common/painter/padding_painter.dart';
import '../common/range.dart';
import '../common/render_params.dart';
import 'grid.dart';
import 'grid_cache.dart';
import 'label/text_label.dart';

class GridPainter extends CustomPainter
    with CoordinatorProvider, HasCoordinator {
  final Grid grid;
  final RenderParams renderParams;
  final GridCache? gridCache;

  /// Avoid hot reload error (late coordinator is not initialized)
  bool _isCoordinatorReady = false;

  GridPainter({
    required this.grid,
    required this.renderParams,
    this.gridCache,
  });

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) {
    final shouldRepaint =
        oldDelegate.grid != grid || oldDelegate.renderParams != renderParams;

    if (shouldRepaint) gridCache?.invlidate();

    if (!shouldRepaint && oldDelegate._isCoordinatorReady) {
      coordinator = oldDelegate.coordinator;
      _isCoordinatorReady = true;
    }

    return shouldRepaint;
  }

  @override
  ChartCoordinator createCoordinator(Size size) => ChartCoordinator(
        grid: grid,
        size: size,
        renderParams: renderParams,
      );

  @override
  void paint(Canvas canvas, Size size) {
    PaddingPainter().paint(
      canvas,
      size,
      padding: grid.style.margin?.copyWith(left: 0, right: 0),
      clip: false,
      routine: (Canvas canvas, Size size) {
        coordinator = createCoordinator(size);
        _isCoordinatorReady = true;

        _paintGrid(canvas, size);
        _paintYLines(canvas, size);
        _paintXLines(canvas, size);
      },
    );
  }

  void _paintGrid(Canvas canvas, Size size) {
    grid.style.decoration.flatMap(
      (decoration) {
        decoration.createBoxPainter().paint(
              canvas,
              Offset.zero,
              ImageConfiguration(size: size),
            );
      },
    );
  }

  void _paintYLines(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final labels = coordinator.yRange.split(grid.ySplitCount).map(
          (v) => grid.yLabel?.call(v) ?? TextLabel(v.toStringAsFixed(3)),
        );
    final offsets = Range(0, size.height)
        .split(grid.ySplitCount)
        .map((y) => Offset(0, y))
        .toList()
        .reversed;

    if (labels.isEmpty || offsets.isEmpty) return;

    assert(labels.length == offsets.length);

    zip(offsets, labels).forEachIndexed(
      (index, t) {
        final offset = t.item1;
        final label = t.item2;

        final lineStyle = label.lineStyle ?? grid.style.lineStyle;

        if (lineStyle != null) {
          LinePainter().paint(
            canvas,
            start: offset,
            end: Offset(size.width, offset.dy),
            style: lineStyle,
          );
        }
      },
    );
  }

  void _paintXLines(Canvas canvas, Size size) {
    /// TODO : paint x custom lines
  }
}
