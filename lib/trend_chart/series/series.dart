import 'package:flutter/material.dart';

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
  CustomPainter createPainter();
}
