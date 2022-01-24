import 'package:artv_chart/trend_chart/common/style.dart';
import 'package:flutter/material.dart';

class LineSeriesStyle {
  final Color? lineColor;
  final double? size;
  final double? singlePointSize;
  final PaintingStyle? paintingStyle;
  final Color? fillColor;
  final List<Color>? gradientColor;

  /// Pattern when line type is [LineType.dash] or [LineType.dot]
  /// Eg: pattern [2, 1] of [LineType.dash] will draw "-- -- --"
  ///
  final LinePattern pattern;

  LineSeriesStyle({
    this.lineColor = Colors.grey,
    this.size = 1,
    this.singlePointSize = 5,
    this.pattern = const [2, 2],
    this.paintingStyle = PaintingStyle.stroke,
    this.fillColor = Colors.grey,
    this.gradientColor = const [Colors.red, Colors.transparent],
  });

  LineSeriesStyle copyWith({
    Color? color,
    double? size,
    LinePattern? pattern,
    double? singlePointSize,
    PaintingStyle? paintingStyle,
    List<Color>? gradientColor,
  }) {
    return LineSeriesStyle(
      lineColor: color ?? lineColor,
      size: size ?? this.size,
      pattern: pattern ?? this.pattern,
      singlePointSize: singlePointSize ?? this.singlePointSize,
      paintingStyle: paintingStyle ?? this.paintingStyle,
      gradientColor: gradientColor ?? this.gradientColor,
    );
  }

  LineSeriesStyle merge(LineSeriesStyle? other) {
    if (other == null) return this;

    return copyWith(
      color: other.lineColor,
      size: other.size,
      pattern: other.pattern,
      singlePointSize: other.singlePointSize,
      paintingStyle: other.paintingStyle,
      gradientColor: other.gradientColor,
    );
  }

  @override
  operator ==(Object other) {
    return identical(this, other) ||
        other is LineSeriesStyle &&
            lineColor == other.lineColor &&
            size == other.size &&
            singlePointSize == other.singlePointSize &&
            paintingStyle == other.paintingStyle &&
            gradientColor == other.gradientColor &&
            pattern == other.pattern;
  }

  @override
  int get hashCode => hashValues(
        lineColor,
        size,
        singlePointSize,
        paintingStyle,
        hashList(pattern),
        hashList(gradientColor),
      );
}
