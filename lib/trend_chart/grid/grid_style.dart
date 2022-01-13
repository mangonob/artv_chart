import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import '../common/style.dart';
import '../common/enum.dart';

typedef LineData = Tuple2<double, LineStyle>;

class GridStyle {
  final EdgeInsets? padding;
  final EdgeInsets? margin;
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
    this.decoration,
    this.labelStyle,
    this.lineColor,
    this.lineType,
    this.lineWidth,
    this.pattern,
    this.xCustomLine,
    this.yCustomLine,
  });

  factory GridStyle.defaultStyle() => const GridStyle(
        labelStyle: TextStyle(),
        lineColor: Colors.grey,
        lineType: LineType.solid,
        lineWidth: 1,
        pattern: [2, 2],
      );
}
