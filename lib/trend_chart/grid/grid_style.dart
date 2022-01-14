import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import '../common/style.dart';
import '../common/enum.dart';

typedef LineData = Tuple2<double, LineStyle>;

class GridStyle {
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? height;
  final double? ratio;
  final Color? color;
  final Decoration? decoration;
  final TextStyle? labelStyle;
  final Color? lineColor;

  /// Default [LineType]
  final LineType? lineType;

  /// Default 1.0
  final double? lineWidth;

  /// Pattern when line type is [LineType.dash] or [LineType.dot]
  /// Eg: pattern [1, 2] of [LineType.dash] will draw "-  -  -  -"
  ///
  final List<double>? pattern;

  final List<LineData>? xCustomLine;
  final List<LineData>? yCustomLine;

  const GridStyle({
    this.margin = EdgeInsets.zero,
    this.padding = EdgeInsets.zero,
    this.height,
    this.ratio = 0.8,
    this.color,
    this.decoration,
    this.labelStyle = const TextStyle(),
    this.lineColor = Colors.grey,
    this.lineType = LineType.solid,
    this.lineWidth = 1,
    this.pattern = const [2, 2],
    this.xCustomLine,
    this.yCustomLine,
  }) : assert(color == null || decoration == null);
}
