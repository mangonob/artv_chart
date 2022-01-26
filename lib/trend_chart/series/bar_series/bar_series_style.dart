import 'package:artv_chart/trend_chart/common/style.dart';
import 'package:artv_chart/trend_chart/common/value_distance.dart';
import 'package:flutter/material.dart';

class BarSeriesStyle {
  final Color? riseColor;
  final Color? fallColor;
  final Distance? _distance;
  final double? width;

  Distance? get distance => _distance;

  BarSeriesStyle({
    this.riseColor = Colors.red,
    this.fallColor = Colors.green,
    LineStyle? lineStyle,
    this.width,
    Distance? distance,
  }) : _distance = distance ??
            CombineDistance(
              distances: [
                ValueDistance.absolute(1),
                ValueDistance.relative(0.1),
              ],
            );

  BarSeriesStyle copyWith({
    Color? riseColor,
    Color? fallColor,
    LineStyle? lineStyle,
    Distance? distance,
    double? width,
  }) =>
      BarSeriesStyle(
        riseColor: riseColor ?? this.riseColor,
        fallColor: fallColor ?? this.fallColor,
        distance: distance ?? this.distance,
        width: width ?? this.width,
      );

  BarSeriesStyle merge(BarSeriesStyle? other) {
    if (other == null) return this;

    return copyWith(
      riseColor: other.riseColor,
      fallColor: other.fallColor,
      distance: other.distance,
      width: other.width,
    );
  }

  @override
  operator ==(Object other) =>
      other is BarSeriesStyle &&
      riseColor == other.riseColor &&
      fallColor == other.fallColor &&
      width == other.width &&
      distance == other.distance;

  @override
  int get hashCode => hashValues(
        riseColor,
        fallColor,
        distance,
        width,
      );
}
