import 'package:artv_chart/trend_chart/common/distance.dart';
import 'package:flutter/material.dart';

enum CandleStyle {
  /// 实心蜡烛
  fill,

  /// 空心蜡烛
  outlet,

  /// 美国线
  ohlc,
}

class CandleSeriesStyle {
  final CandleStyle? style;
  final Color? riseColor;
  final Color? fallColor;
  final Distance? distance;

  const CandleSeriesStyle({
    this.style,
    this.riseColor,
    this.fallColor,
    this.distance = const Distance.absolute(2),
  });

  CandleSeriesStyle copyWith({
    CandleStyle? style = CandleStyle.fill,
    Color? riseColor = Colors.red,
    Color? fallColor = Colors.green,
    Distance? distance,
  }) =>
      CandleSeriesStyle(
        style: style ?? this.style,
        riseColor: riseColor ?? this.riseColor,
        fallColor: fallColor ?? this.fallColor,
        distance: distance ?? this.distance,
      );

  CandleSeriesStyle merge(CandleSeriesStyle? other) {
    if (other == null) return this;

    return copyWith(
      style: other.style,
      riseColor: other.riseColor,
      fallColor: other.fallColor,
      distance: other.distance,
    );
  }

  @override
  operator ==(Object other) =>
      other is CandleSeriesStyle &&
      style == other.style &&
      riseColor == other.riseColor &&
      fallColor == other.fallColor &&
      distance == other.distance;

  @override
  int get hashCode => hashValues(
        style,
        riseColor,
        fallColor,
        distance,
      );
}
