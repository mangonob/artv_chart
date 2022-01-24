import 'package:artv_chart/utils/utils.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../chart_coordinator.dart';
import '../common/painter/padding_painter.dart';
import '../common/range.dart';
import '../common/render_params.dart';
import 'grid.dart';
import 'label/text_label.dart';

class GridLabelPainter extends CustomPainter
    with CoordinatorProvider, HasCoordinator {
  final Grid grid;
  final RenderParams renderParams;

  GridLabelPainter({
    required this.grid,
    required this.renderParams,
  });

  @override
  ChartCoordinator createCoordinator(Size size) => ChartCoordinator(
        grid: grid,
        size: size,
        renderParams: renderParams,
      );

  @override
  bool shouldRepaint(covariant GridLabelPainter oldDelegate) {
    return oldDelegate.grid != grid || oldDelegate.renderParams != renderParams;
  }

  @override
  void paint(Canvas canvas, Size size) {
    PaddingPainter().paint(
      canvas,
      size,
      padding: grid.style.margin?.copyWith(left: 0, right: 0),
      routine: (Canvas canvas, Size size) {
        coordinator = createCoordinator(size);

        _paintYValues(canvas, size);
        _paintXValues(canvas, size);
      },
    );
  }

  void _paintYValues(Canvas canvas, Size size) {
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
    final hasMore = labels.length > 1;
    final count = labels.length;

    zip(offsets, labels).forEachIndexed(
      (index, t) {
        final offset = t.item1;
        final label = t.item2;
        final isFirst = index == 0;
        final isLast = index == count - 1;

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
    final drawRange = coordinator.xRange.intersection(renderParams.xRange);
    if (size.isEmpty || drawRange.isEmpty) return;

    final labels = drawRange.toIterable().map((x) => grid.xLabel?.call(x));
    final offsets = drawRange.toIterable().map(
          (x) => Offset((x - coordinator.xRange.lower) * unit, size.height),
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
