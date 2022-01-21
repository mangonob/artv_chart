import 'package:flutter/material.dart';

import '../../common/value_distance.dart';

enum CandleType {
  /// 实心蜡烛
  fill,

  /// 空心蜡烛
  outlet,

  /// 美国线
  ohlc,
}

class CandleSeriesStyle {
  final CandleType? type;
  final Color? riseColor;
  final Color? fallColor;
  final Distance? _distance;

  Distance? get distance => _distance;

  CandleSeriesStyle({
    this.type,
    this.riseColor,
    this.fallColor,
    Distance? distance,
  }) : _distance = distance ?? ValueDistance.absolute(2);

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
