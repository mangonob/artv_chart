import 'package:flutter/material.dart';

import '../../common/style.dart';

class DotSeriesStyle {
  final double? circleRadius;
  final double? strokeWidth;
  final Color? fillColor;

  final LineStyle? _lineStyle;

  LineStyle? get lineStyle => _lineStyle;

  DotSeriesStyle({
    this.circleRadius = 3,
    this.strokeWidth = 1,
    LineStyle? lineStyle,
    this.fillColor,
  }) : _lineStyle = LineStyle(color: Colors.red[200]).merge(lineStyle);

  DotSeriesStyle copyWith({
    double? radius,
    double? strokeWidth,
    Color? fillColor,
    LineStyle? lineStyle,
  }) {
    return DotSeriesStyle(
      circleRadius: radius ?? radius,
      lineStyle: lineStyle ?? lineStyle,
      fillColor: fillColor ?? fillColor,
      strokeWidth: strokeWidth ?? strokeWidth,
    );
  }

  DotSeriesStyle merge(DotSeriesStyle? other) {
    if (other == null) return this;

    return copyWith(
      radius: other.circleRadius,
      lineStyle: other.lineStyle,
      fillColor: other.fillColor,
      strokeWidth: other.strokeWidth,
    );
  }

  @override
  operator ==(Object other) {
    return identical(this, other) ||
        other is DotSeriesStyle &&
            circleRadius == other.circleRadius &&
            lineStyle == other.lineStyle &&
            strokeWidth == other.strokeWidth &&
            fillColor == other.fillColor;
  }

  @override
  int get hashCode => hashValues(
        circleRadius,
        lineStyle,
        fillColor,
        strokeWidth,
      );
}
