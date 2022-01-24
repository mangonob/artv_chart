import 'package:flutter/material.dart';

import '../../common/style.dart';
import '../../common/value_distance.dart';
import 'candle_series_label_style.dart';

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
  final ValueRemarkStyle? _remarkStyle;

  Distance? get distance => _distance;
  LineStyle? get lineStyle => _lineStyle;
  ValueRemarkStyle? get remarkStyle => _remarkStyle;

  CandleSeriesStyle({
    this.type = CandleType.fill,
    this.riseColor = Colors.red,
    this.fallColor = Colors.green,
    LineStyle? lineStyle,
    Distance? distance,
    ValueRemarkStyle? remarkStyle,
  })  : _lineStyle = const LineStyle(size: 1).merge(lineStyle),
        _distance = distance ??
            CombineDistance(
              distances: [
                ValueDistance.absolute(1),
                ValueDistance.relative(0.1),
              ],
            ),
        _remarkStyle = ValueRemarkStyle().merge(
          remarkStyle,
        );

  CandleSeriesStyle copyWith({
    CandleType? type,
    Color? riseColor,
    Color? fallColor,
    LineStyle? lineStyle,
    Distance? distance,
    ValueRemarkStyle? remarkStyle,
  }) =>
      CandleSeriesStyle(
        type: type ?? this.type,
        riseColor: riseColor ?? this.riseColor,
        fallColor: fallColor ?? this.fallColor,
        lineStyle: lineStyle ?? this.lineStyle,
        distance: distance ?? this.distance,
        remarkStyle: remarkStyle ?? this.remarkStyle,
      );

  CandleSeriesStyle merge(CandleSeriesStyle? other) {
    if (other == null) return this;

    return copyWith(
      type: other.type,
      riseColor: other.riseColor,
      fallColor: other.fallColor,
      lineStyle: other.lineStyle,
      distance: other.distance,
      remarkStyle: other.remarkStyle,
    );
  }

  @override
  operator ==(Object other) =>
      other is CandleSeriesStyle &&
      type == other.type &&
      riseColor == other.riseColor &&
      fallColor == other.fallColor &&
      lineStyle == other.lineStyle &&
      distance == other.distance &&
      remarkStyle == other.remarkStyle;

  @override
  int get hashCode => hashValues(
        type,
        riseColor,
        fallColor,
        lineStyle,
        distance,
        remarkStyle,
      );
}
