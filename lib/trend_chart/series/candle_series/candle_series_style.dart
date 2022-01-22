import 'package:artv_chart/trend_chart/common/style.dart';
import 'package:flutter/material.dart';

import '../../common/value_distance.dart';

enum CandleType {
  /// 实心蜡烛
  fill,

  /// 空心蜡烛
  outline,

  /// 美国线
  ohlc,
}

class CandleSeriesStyle {
  final CandleType? type;
  final Color? riseColor;
  final Color? fallColor;
  final LineStyle? _lineStyle;
  final Distance? _distance;

  Distance? get distance => _distance;
  LineStyle? get lineStyle => _lineStyle;

  CandleSeriesStyle({
    this.type,
    this.riseColor,
    this.fallColor,
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

  CandleSeriesStyle copyWith({
    CandleType? type = CandleType.fill,
    Color? riseColor = Colors.red,
    Color? fallColor = Colors.green,
    Distance? distance,
  }) =>
      CandleSeriesStyle(
        type: type ?? this.type,
        riseColor: riseColor ?? this.riseColor,
        fallColor: fallColor ?? this.fallColor,
        distance: distance ?? this.distance,
      );

  CandleSeriesStyle merge(CandleSeriesStyle? other) {
    if (other == null) return this;

    return copyWith(
      type: other.type,
      riseColor: other.riseColor,
      fallColor: other.fallColor,
      distance: other.distance,
    );
  }

  @override
  operator ==(Object other) =>
      other is CandleSeriesStyle &&
      type == other.type &&
      riseColor == other.riseColor &&
      fallColor == other.fallColor &&
      distance == other.distance;

  @override
  int get hashCode => hashValues(
        type,
        riseColor,
        fallColor,
        distance,
      );
}
