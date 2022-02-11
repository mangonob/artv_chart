import 'package:flutter/material.dart';

import 'enum.dart';

typedef LinePattern = List<double>;

class LineStyle {
  final Color? color;
  final double? size;
  final LineType? type;
  final StrokeCap? strokeCap;
  final StrokeJoin? strokeJoin;

  /// Pattern when line type is [LineType.dash] or [LineType.dot]
  /// Eg: pattern [2, 1] of [LineType.dash] will draw "-- -- --"
  ///
  final LinePattern pattern;

  const LineStyle({
    this.color = Colors.grey,
    this.size = 1,
    this.type = LineType.solid,
    this.pattern = const [2, 2],
    this.strokeCap = StrokeCap.butt,
    this.strokeJoin = StrokeJoin.miter,
  });

  LineStyle copyWith({
    Color? color,
    double? size,
    LineType? type,
    LinePattern? pattern,
    double? singlePointSize,
    PaintingStyle? paintingStyle,
    StrokeCap? strokeCap,
    StrokeJoin? strokeJoin,
  }) {
    return LineStyle(
      color: color ?? this.color,
      size: size ?? this.size,
      type: type ?? this.type,
      pattern: pattern ?? this.pattern,
      strokeCap: strokeCap ?? this.strokeCap,
      strokeJoin: strokeJoin ?? this.strokeJoin,
    );
  }

  LineStyle merge(LineStyle? other) {
    if (other == null) return this;

    return copyWith(
      color: other.color,
      size: other.size,
      type: other.type,
      pattern: other.pattern,
      strokeCap: other.strokeCap,
      strokeJoin: other.strokeJoin,
    );
  }

  @override
  operator ==(Object other) {
    return identical(this, other) ||
        other is LineStyle &&
            color == other.color &&
            size == other.size &&
            type == other.type &&
            strokeCap == other.strokeCap &&
            strokeJoin == other.strokeJoin &&
            pattern == other.pattern;
  }

  @override
  int get hashCode => hashValues(
        color,
        size,
        type,
        strokeCap,
        strokeJoin,
        hashList(pattern),
      );
}
