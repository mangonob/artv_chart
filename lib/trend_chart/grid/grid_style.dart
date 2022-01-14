import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import '../common/style.dart';

typedef LineData = Tuple2<double, LineStyle>;

class GridStyle {
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? height;
  final double? ratio;
  final Color? color;
  final Decoration? decoration;
  final TextStyle? _labelStyle;
  final LineStyle? _lineStyle;

  LineStyle? get lineStyle => _lineStyle;
  TextStyle? get labelStyle => _labelStyle;

  final List<LineData>? xCustomLine;
  final List<LineData>? yCustomLine;

  GridStyle({
    this.margin = EdgeInsets.zero,
    this.padding = EdgeInsets.zero,
    this.height,
    this.ratio = 0.8,
    this.color,
    this.decoration,
    LineStyle? lineStyle,
    this.xCustomLine,
    this.yCustomLine,
  })  : assert(color == null || decoration == null),
        _lineStyle = lineStyle ?? LineStyle(color: Colors.grey[200]),
        _labelStyle = TextStyle(fontSize: 10, color: Colors.grey[500]);
}
