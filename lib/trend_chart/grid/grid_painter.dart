import 'package:artv_chart/utils/utils.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../common/painter/cache_manager.dart';
import '../common/painter/line_painter.dart';
import '../common/range.dart';
import '../common/render_params.dart';
import 'grid.dart';
import 'label/text_label.dart';

class GridPainter extends CustomPainter {
  final Grid grid;
  final RenderParams renderParams;

  GridPainter({
    required this.grid,
    required this.renderParams,
  });

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) {
    return oldDelegate.grid != grid;
  }

  /// Cache computed values
  late Range _xRange;
  late Range _yRange;
  late List<double> _xValues;

  void _prepareForSize(Size size) {
    final cache = Cache(
      xRange: _xRange = grid.xRange(params: renderParams, size: size),
    );
    _yRange = grid.yRange(params: renderParams, size: size, cache: cache);
    _xValues = grid.xValues(params: renderParams, size: size, cache: cache);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final margin = grid.style.margin ?? EdgeInsets.zero;
    canvas.translate(margin.left, margin.top);
    final gridSize =
        Size(size.width - margin.horizontal, size.height - margin.vertical);
    _prepareForSize(gridSize);

    _paintGrid(canvas, gridSize);
    _paintYValues(canvas, gridSize);
    _paintXValues(canvas, gridSize);
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

    final labels = _yRange.split(grid.ySplitCount).map(
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
    if (size.isEmpty || _xValues.isEmpty) return;

    final labels = _xValues.map((e) => grid.xLabel?.call(e));
    final offsets = _xValues.map(
      (e) => Offset((e - _xRange.lower) * unit, size.height),
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
