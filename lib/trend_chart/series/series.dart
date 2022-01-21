import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../common/range.dart';
import '../common/render_params.dart';
import '../grid/grid.dart';

typedef ValueConvertor<T> = double Function(T, int, Series<T>);

abstract class Series<D> {
  final List<D> datas;
  final int priority;
  final ValueConvertor<D>? yValue;

  Series({
    required this.datas,
    this.priority = 0,
    this.yValue,
  });

  /// Factory method to generate a new painter.
  CustomPainter createPainter(
    RenderParams renderParams, {
    required Grid grid,
  });

  List<double> yValues(Range xRange) {
    if (yValue == null) {
      return [];
    } else {
      final start = min(
        max(xRange.lower.ceil(), 0),
        datas.length,
      );
      final end = min(max(xRange.upper.ceil(), 0), datas.length);
      if (end > start) {
        return datas
            .getRange(start, end)
            .mapIndexed((index, d) => yValue!(d, index + start, this))
            .toList();
      } else {
        return [];
      }
    }
  }

  Range yRange(Range xRange) {
    if (yValue == null) {
      return const Range.empty();
    } else {
      final yValues = this.yValues(xRange);

      return yValues.foldIndexed(
        const Range.empty(),
        (index, range, value) => range.extend(value),
      );
    }
  }

  Range xRange() {
    return Range(0, datas.length - 1);
  }
}
