import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:quiver/iterables.dart';

import '../common/range.dart';
import '../common/render_params.dart';
import '../grid/grid.dart';

typedef ValueConvertor<T> = double Function(T, int, Series<T>);

abstract class Series<D> {
  final List<D> datas;
  final int priority;
  final ValueConvertor<D>? xValue;
  final ValueConvertor<D>? yValue;

  Series({
    required this.datas,
    this.priority = 0,
    this.xValue,
    this.yValue,
  });

  /// Factory method to generate a new painter.
  CustomPainter createPainter(
    RenderParams renderParams, {
    required Grid grid,
  });

  List<double> xValues() {
    if (xValue == null) {
      return [];
    } else {
      return datas.mapIndexed((index, d) => xValue!(d, index, this)).toList();
    }
  }

  List<double> yValues(Range xRange) {
    if (xValue == null || yValue == null) {
      return [];
    } else {
      final rangedDatas = datas
          .whereIndexed((index, d) => xRange.contains(xValue!(d, index, this)));
      return rangedDatas
          .mapIndexed((index, d) => yValue!(d, index, this))
          .toList();
    }
  }

  Range yRange(Range xRange) {
    if (xValue == null || yValue == null) {
      return const Range.empty();
    } else {
      final rangedDatas = datas
          .whereIndexed((index, d) => xRange.contains(xValue!(d, index, this)));

      return rangedDatas.foldIndexed(
        const Range.empty(),
        (index, range, d) => range.extend(yValue!(d, index, this)),
      );
    }
  }

  Range xRange() {
    final xs = xValues();
    if (xs.isEmpty) {
      return const Range.empty();
    } else {
      return Range(min(xs)!, max(xs)!);
    }
  }
}
