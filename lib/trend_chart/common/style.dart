import 'package:flutter/material.dart';

import 'enum.dart';

class LineStyle {
  Color? color;
  double? size;
  LineType? type;

  LineStyle({
    this.color,
    this.size = 1,
    this.type = LineType.solid,
  });

  LineStyle copyWith({
    Color? color,
    double? size,
    LineType? type,
  }) {
    return LineStyle(
      color: color ?? this.color,
      size: size ?? this.size,
      type: type ?? this.type,
    );
  }

  LineStyle merge(LineStyle? other) {
    if (other == null) return this;

    return copyWith(
      color: other.color,
      size: other.size,
      type: other.type,
    );
  }

  @override
  operator ==(Object other) {
    return identical(this, other) ||
        other is LineStyle &&
            color == other.color &&
            size == other.size &&
            type == other.type;
  }

  @override
  int get hashCode => hashValues(
        color,
        size,
        type,
      );
}
