import 'package:flutter/material.dart';

import '../common/style.dart';

class CustomLine {
  final double? position;
  final LineStyle? style;

  CustomLine({
    this.position,
    this.style,
  });

  CustomLine copyWith({
    double? position,
    LineStyle? style,
  }) {
    return CustomLine(
      position: position ?? this.position,
      style: style ?? this.style,
    );
  }

  CustomLine merge(CustomLine? other) {
    if (other == null) return this;

    return copyWith(
      position: other.position,
      style: other.style,
    );
  }

  @override
  operator ==(Object other) =>
      identical(this, other) ||
      other is CustomLine &&
          runtimeType == other.runtimeType &&
          position == other.position &&
          style == other.style;

  @override
  int get hashCode => hashValues(position, style);
}
