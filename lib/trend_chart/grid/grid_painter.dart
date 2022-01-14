import 'package:artv_chart/trend_chart/common/painter/line_painter.dart';
import 'package:artv_chart/trend_chart/common/render_params.dart';
import 'package:artv_chart/trend_chart/grid/label/text_label.dart';
import 'package:artv_chart/utils/utils.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../common/range.dart';
import 'grid.dart';

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

  void _prepare() {
    _xRange = grid.xRange();
    _yRange = grid.yRange();
    _xValues = grid.xValues();
  }

  @override
  void paint(Canvas canvas, Size size) {
    _prepare();

    final margin = grid.style.margin ?? EdgeInsets.zero;
    canvas.translate(margin.left, margin.top);
    final gridSize =
        Size(size.width - margin.horizontal, size.height - margin.vertical);

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
        .map(
          (y) => Offset(0, y),
        )
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
    if (size.isEmpty || _xValues.isEmpty) return;

    final labels = _xValues.map((e) => grid.xLabel?.call(e));
    final offsets = _xValues.map(
      (e) => Offset(renderParams.unit * (e + 0.5), size.height),
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
