import 'package:flutter/material.dart';

class DotSeriesStyle {
  final double? circleSize;
  final PaintingStyle? paintingStyle;

  DotSeriesStyle({
    this.circleSize = 1,
    this.paintingStyle = PaintingStyle.stroke,
  });

  DotSeriesStyle copyWith({
    double? circleSize,
    PaintingStyle? paintingStyle,
  }) {
    return DotSeriesStyle(
      circleSize: circleSize ?? circleSize,
      paintingStyle: paintingStyle ?? paintingStyle,
    );
  }

  DotSeriesStyle merge(DotSeriesStyle? other) {
    if (other == null) return this;

    return copyWith(
      circleSize: other.circleSize,
      paintingStyle: other.paintingStyle,
    );
  }

  @override
  operator ==(Object other) {
    return identical(this, other) ||
        other is DotSeriesStyle &&
            circleSize == other.circleSize &&
            paintingStyle == other.paintingStyle;
  }

  @override
  int get hashCode => hashValues(circleSize, paintingStyle);
}
