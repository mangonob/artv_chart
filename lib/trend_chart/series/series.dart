import 'package:artv_chart/trend_chart/layout_info.dart';
import 'package:flutter/material.dart';

abstract class Series<D> {
  final List<D> datas;

  Series({required this.datas});

  /// Factory method to generate a new painter.
  CustomPainter createPainter({
    required LayoutDetails details,
  });
}
