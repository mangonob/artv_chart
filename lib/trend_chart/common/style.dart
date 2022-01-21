import 'package:flutter/material.dart';

import 'enum.dart';

typedef LinePattern = List<double>;

class LineStyle {
  final Color? color;
  final double? size;
  final LineType? type;
  final double? singlePointSize;

  /// Pattern when line type is [LineType.dash] or [LineType.dot]
  /// Eg: pattern [2, 1] of [LineType.dash] will draw "-- -- --"
  ///
  final LinePattern pattern;

  const LineStyle({
    this.color = Colors.grey,
    this.size = 1,
    this.type = LineType.solid,
    this.singlePointSize = 5,
    this.pattern = const [2, 2],
  });

  LineStyle copyWith({
    Color? color,
    double? size,
    LineType? type,
    LinePattern? pattern,
    double? singlePointSize,
  }) {
    return LineStyle(
      color: color ?? this.color,
      size: size ?? this.size,
      type: type ?? this.type,
      pattern: pattern ?? this.pattern,
      singlePointSize: singlePointSize ?? this.singlePointSize,
    );
  }

  LineStyle merge(LineStyle? other) {
    if (other == null) return this;

    return copyWith(
      color: other.color,
      size: other.size,
      type: other.type,
      pattern: other.pattern,
      singlePointSize: other.singlePointSize,
    );
  }

  @override
  operator ==(Object other) {
    return identical(this, other) ||
        other is LineStyle &&
            color == other.color &&
            size == other.size &&
            type == other.type &&
            singlePointSize == other.singlePointSize &&
            pattern == other.pattern;
  }

  @override
  int get hashCode => hashValues(
        color,
        size,
        type,
        singlePointSize,
        hashList(pattern),
      );
}
