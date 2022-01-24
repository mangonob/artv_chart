import 'package:artv_chart/trend_chart/common/style.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LineSeriesStyle {
  final double? singlePointSize;
  final PaintingStyle? paintingStyle;
  final Color? fillColor;
  final LineStyle? _lineStyle;

  LineStyle? get lineStyle => _lineStyle;

  List<Color>? get gradientColors => _gradientColors;

  final List<Color>? _gradientColors;

  /// Pattern when line type is [LineType.dash] or [LineType.dot]
  /// Eg: pattern [2, 1] of [LineType.dash] will draw "-- -- --"
  ///
  final LinePattern pattern;

  LineSeriesStyle({
    this.singlePointSize = 5,
    this.pattern = const [2, 2],
    this.paintingStyle = PaintingStyle.stroke,
    this.fillColor = Colors.grey,
    List<Color>? gradientColors,
    LineStyle? lineStyle,
  })  : _lineStyle = LineStyle(color: Colors.red[200]).merge(lineStyle),
        _gradientColors = [Colors.red, Colors.red.withOpacity(0)];

  LineSeriesStyle copyWith({
    Color? color,
    double? size,
    LinePattern? pattern,
    double? singlePointSize,
    PaintingStyle? paintingStyle,
    List<Color>? gradientColor,
    LineStyle? lineStyle,
  }) {
    return LineSeriesStyle(
      pattern: pattern ?? this.pattern,
      singlePointSize: singlePointSize ?? this.singlePointSize,
      paintingStyle: paintingStyle ?? this.paintingStyle,
      gradientColors: gradientColor ?? gradientColors,
      lineStyle: lineStyle ?? lineStyle,
    );
  }

  LineSeriesStyle merge(LineSeriesStyle? other) {
    if (other == null) return this;

    return copyWith(
      pattern: other.pattern,
      singlePointSize: other.singlePointSize,
      paintingStyle: other.paintingStyle,
      gradientColor: other.gradientColors,
      lineStyle: other.lineStyle,
    );
  }

  @override
  operator ==(Object other) {
    return identical(this, other) ||
        other is LineSeriesStyle &&
            singlePointSize == other.singlePointSize &&
            paintingStyle == other.paintingStyle &&
            listEquals(gradientColors, other.gradientColors) &&
            lineStyle == other.lineStyle &&
            pattern == other.pattern;
  }

  @override
  int get hashCode => hashValues(
        singlePointSize,
        lineStyle,
        paintingStyle,
        hashList(pattern),
        hashList(gradientColors),
      );
}
