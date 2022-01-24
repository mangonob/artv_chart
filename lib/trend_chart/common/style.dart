import 'package:flutter/material.dart';

import 'enum.dart';

typedef LinePattern = List<double>;

class LineStyle {
  final Color? lineColor;
  final double? size;
  final LineType? type;

  /// Pattern when line type is [LineType.dash] or [LineType.dot]
  /// Eg: pattern [2, 1] of [LineType.dash] will draw "-- -- --"
  ///
  final LinePattern pattern;

  const LineStyle({
    this.lineColor = Colors.grey,
    this.size = 1,
    this.type = LineType.solid,
    this.pattern = const [2, 2],
  });

  LineStyle copyWith({
    Color? color,
    double? size,
    LineType? type,
    LinePattern? pattern,
    double? singlePointSize,
    PaintingStyle? paintingStyle,
  }) {
    return LineStyle(
      lineColor: color ?? this.lineColor,
      size: size ?? this.size,
      type: type ?? this.type,
      pattern: pattern ?? this.pattern,
    );
  }

  LineStyle merge(LineStyle? other) {
    if (other == null) return this;

    return copyWith(
      color: other.lineColor,
      size: other.size,
      type: other.type,
      pattern: other.pattern,
    );
  }

  @override
  operator ==(Object other) {
    return identical(this, other) ||
        other is LineStyle &&
            lineColor == other.lineColor &&
            size == other.size &&
            type == other.type &&
            pattern == other.pattern;
  }

  @override
  int get hashCode => hashValues(
        lineColor,
        size,
        type,
        hashList(pattern),
      );
}
