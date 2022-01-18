import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:quiver/iterables.dart';

import '../common/range.dart';
import '../common/render_params.dart';

typedef ValueConvertor<T> = double Function(T, int, Series<T>);

abstract class Series<D> {
  final List<D> datas;
  final int gridIndex;
  final int priority;
  final ValueConvertor<D>? xValue;
  final ValueConvertor<D>? yValue;

  Series({
    required this.datas,
    this.gridIndex = 0,
    this.priority = 0,
    this.xValue,
    this.yValue,
  });

  /// Factory method to generate a new painter.
  CustomPainter createPainter(RenderParams renderParams);

  List<double> xValues() {
    if (xValue == null) {
      return [];
    } else {
      return datas.mapIndexed((index, d) => xValue!(d, index, this)).toList();
    }
  }

  List<double> yValues() {
    if (xValue == null) {
      return [];
    } else {
      return datas.mapIndexed((index, d) => yValue!(d, index, this)).toList();
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

  Range yRange() {
    final ys = yValues();
    if (ys.isEmpty) {
      return const Range.empty();
    } else {
      return Range(min(ys)!, max(ys)!);
    }
  }
}
