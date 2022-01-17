import 'package:flutter/material.dart';

import '../common/style.dart';

class GridStyle {
  final EdgeInsets? margin;
  final double? height;
  final double? ratio;
  final Color? color;
  final Decoration? decoration;
  final TextStyle? _labelStyle;
  final LineStyle? _lineStyle;

  LineStyle? get lineStyle => _lineStyle;
  TextStyle? get labelStyle => _labelStyle;

  GridStyle({
    this.margin = EdgeInsets.zero,
    this.height,
    this.ratio = 0.8,
    this.color,
    this.decoration,
    TextStyle? labelStyle,
    LineStyle? lineStyle,
  })  : assert(color == null || decoration == null),
        _lineStyle = lineStyle ?? LineStyle(color: Colors.grey[200]),
        _labelStyle =
            labelStyle ?? TextStyle(fontSize: 10, color: Colors.grey[500]);

  GridStyle copyWith({
    EdgeInsets? margin,
    double? height,
    double? ratio,
    Color? color,
    Decoration? decoration,
    TextStyle? labelStyle,
    LineStyle? lineStyle,
  }) {
    return GridStyle(
      margin: margin ?? this.margin,
      height: height ?? this.height,
      ratio: ratio ?? this.ratio,
      color: color ?? this.color,
      decoration: decoration ?? this.decoration,
      labelStyle: labelStyle ?? this.labelStyle,
      lineStyle: lineStyle ?? this.lineStyle,
    );
  }

  GridStyle merge(GridStyle? other) {
    if (other == null) return this;

    return copyWith(
      margin: other.margin,
      height: other.height,
      ratio: other.ratio,
      color: other.color,
      decoration: other.decoration,
      labelStyle: other.labelStyle,
      lineStyle: other.lineStyle,
    );
  }

  @override
  operator ==(Object other) {
    return identical(this, other) ||
        other is GridStyle &&
            runtimeType == other.runtimeType &&
            margin == other.margin &&
            height == other.height &&
            ratio == other.ratio &&
            color == other.color &&
            decoration == other.decoration &&
            _labelStyle == other._labelStyle &&
            _lineStyle == other._lineStyle;
  }

  @override
  int get hashCode => hashValues(
        margin,
        height,
        ratio,
        color,
        decoration,
        _labelStyle,
        _lineStyle,
      );
}
