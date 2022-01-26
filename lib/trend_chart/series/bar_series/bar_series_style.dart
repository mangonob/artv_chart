import 'package:artv_chart/trend_chart/common/style.dart';
import 'package:artv_chart/trend_chart/common/value_distance.dart';
import 'package:flutter/material.dart';

class BarSeriesStyle {
  final Color? riseColor;
  final Color? fallColor;
  final LineStyle? _lineStyle;
  final Distance? _distance;

  Distance? get distance => _distance;

  LineStyle? get lineStyle => _lineStyle;

  BarSeriesStyle({
    this.riseColor = Colors.red,
    this.fallColor = Colors.green,
    LineStyle? lineStyle,
    Distance? distance,
  })  : _lineStyle = const LineStyle(size: 1).merge(lineStyle),
        _distance = distance ??
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
  }) =>
      BarSeriesStyle(
        riseColor: riseColor ?? this.riseColor,
        fallColor: fallColor ?? this.fallColor,
        lineStyle: lineStyle ?? this.lineStyle,
        distance: distance ?? this.distance,
      );

  BarSeriesStyle merge(BarSeriesStyle? other) {
    if (other == null) return this;

    return copyWith(
      riseColor: other.riseColor,
      fallColor: other.fallColor,
      lineStyle: other.lineStyle,
      distance: other.distance,
    );
  }

  @override
  operator ==(Object other) =>
      other is BarSeriesStyle &&
      riseColor == other.riseColor &&
      fallColor == other.fallColor &&
      lineStyle == other.lineStyle &&
      distance == other.distance;

  @override
  int get hashCode => hashValues(
        riseColor,
        fallColor,
        lineStyle,
        distance,
      );
}
