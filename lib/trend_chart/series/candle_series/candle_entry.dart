import 'package:flutter/material.dart';

enum CandleDirection {
  fall,
  rise,
  undefined,
}

/// Model class of candle chart.
class CandleEntry {
  /// 开盘价
  double? open;

  /// 最高价
  double? high;

  /// 最低价
  double? lower;

  /// 收盘价
  double? close;

  /// Whether entry has not any value.
  bool get isEmpty =>
      open == null && high == null && lower == null && close == null;

  CandleDirection get direction => open != null || close != null
      ? close! > open!
          ? CandleDirection.rise
          : CandleDirection.fall
      : CandleDirection.undefined;

  CandleEntry({
    this.high,
    this.lower,
    this.open,
    this.close,
  });

  CandleEntry copyWith({
    double? high,
    double? lower,
    double? open,
    double? close,
  }) =>
      CandleEntry(
        high: high ?? this.high,
        lower: lower ?? this.lower,
        open: open ?? this.open,
        close: close ?? this.close,
      );

  CandleEntry merge(CandleEntry? other) {
    if (other == null) return this;

    return copyWith(
      high: other.high,
      lower: other.lower,
      open: other.open,
      close: other.close,
    );
  }

  @override
  operator ==(Object other) =>
      identical(this, other) ||
      other is CandleEntry &&
          high == other.high &&
          lower == other.lower &&
          open == other.open &&
          close == other.close;

  @override
  int get hashCode => hashValues(
        high,
        lower,
        open,
        close,
      );
}
