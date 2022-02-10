import 'package:flutter/material.dart';

extension RectUtilsExtension on Rect {
  /// Add padding insets to the rectangle.
  /// If [insets] have positive values, it will increase the size of the rectangle.
  Rect inset(EdgeInsets insets) {
    return Rect.fromLTWH(
      left + insets.left,
      top + insets.top,
      width + insets.horizontal,
      height + insets.vertical,
    );
  }

  bool get isValid => !hasNaN;
}

extension OffsetUtilsExtension on Offset {
  copyWith({
    double? dx,
    double? dy,
  }) =>
      Offset(
        dx ?? this.dx,
        dy ?? this.dy,
      );

  bool get isValid => !dx.isNaN && !dy.isNaN;
}
