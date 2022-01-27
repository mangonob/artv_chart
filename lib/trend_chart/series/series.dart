import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

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

  Tuple2<Iterable<D>, int> datasInXRange(Range xRange) {
    final start = min(
      max(xRange.lower.ceil(), 0),
      datas.length,
    );
    final end = min(max(xRange.upper.ceil(), 0), datas.length);
    if (end > start) {
      return Tuple2(ListSlice(datas, start, end), start);
    } else {
      return const Tuple2([], -1);
    }
  }

  Iterable<double> yValues(Range xRange) {
    if (yValue == null) {
      return [];
    } else {
      final t = datasInXRange(xRange);
      final datas = t.item1;
      final start = t.item2;
      return datas.mapIndexed(
        (index, d) => yValue!(d, index + start, this),
      );
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

  @override
  operator ==(Object other) =>
      other is Series<D> &&
      other.datas == datas &&
      other.priority == priority &&
      other.yValue == yValue;

  @override
  int get hashCode => hashValues(
        hashList(datas),
        priority,
        yValue,
      );
}
