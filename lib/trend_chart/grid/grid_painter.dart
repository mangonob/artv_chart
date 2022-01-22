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

class GridPainter extends CustomPainter with CoordinatorProvider {
  final Grid grid;
  final RenderParams renderParams;
  final GridCache? gridCache;

  late ChartCoordinator _coordinator;

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
        _coordinator = createCoordinator(size);

        _paintGrid(canvas, size);
        _paintYValues(canvas, size);
        _paintXValues(canvas, size);
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

  void _paintYValues(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final labels = _coordinator.yRange.split(grid.ySplitCount).map(
          (v) => grid.yLabel?.call(v) ?? TextLabel(v.toStringAsFixed(3)),
        );
    final offsets = Range(0, size.height)
        .split(grid.ySplitCount)
        .map((y) => Offset(0, y))
        .toList()
        .reversed;

    if (labels.isEmpty || offsets.isEmpty) return;

    assert(labels.length == offsets.length);
    final hasMore = labels.length > 1;
    final count = labels.length;

    zip(offsets, labels).forEachIndexed(
      (index, t) {
        final offset = t.item1;
        final label = t.item2;
        final isFirst = index == 0;
        final isLast = index == count - 1;

        final lineStyle = label.lineStyle ?? grid.style.lineStyle;

        if (lineStyle != null) {
          LinePainter().paint(
            canvas,
            start: offset,
            end: Offset(size.width, offset.dy),
            style: lineStyle,
          );
        }

        label.createPainter().paint(
              canvas,
              offset: offset,
              alignment: hasMore && isFirst
                  ? Alignment.topRight
                  : hasMore && isLast
                      ? Alignment.bottomRight
                      : Alignment.centerRight,
              textStyle: grid.style.labelStyle,
            );
      },
    );
  }

  void _paintXValues(Canvas canvas, Size size) {
    final unit = renderParams.unit;
    final drawRange = _coordinator.xRange.intersection(renderParams.xRange);
    if (size.isEmpty || drawRange.isEmpty) return;

    final labels = drawRange.toIterable().map((x) => grid.xLabel?.call(x));
    final offsets = drawRange.toIterable().map(
          (x) => Offset((x - _coordinator.xRange.lower) * unit, size.height),
        );

    assert(labels.length == offsets.length);

    zip(offsets, labels).forEach((t) {
      final offset = t.item1;
      final label = t.item2;

      if (label != null) {
        label.createPainter().paint(
              canvas,
              offset: offset,
              alignment: Alignment.bottomCenter,
              textStyle: grid.style.labelStyle,
            );
      }
    });
  }
}
