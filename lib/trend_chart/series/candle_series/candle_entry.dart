import 'package:flutter/material.dart';

import '../../common/range.dart';

enum CandleDirection {
  fall,
  rise,
  undefined,
}

/// Model class of candle chart.
class CandleEntry {
  /// Open price
  double? open;

  /// Hightest price
  double? high;

  /// Lowest price
  double? lower;

  /// Close price
  double? close;

  /// Whether entry contains no value.
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

  factory CandleEntry.emtpy() => CandleEntry();

  /// Range from highest value to lowest value in [CandleEntry].
  /// If [CandleEntry] is empty, return [Range.empty].
  Range get range {
    Range r = const Range.empty();
    if (open != null) r = r.extend(open!);
    if (high != null) r = r.extend(high!);
    if (lower != null) r = r.extend(lower!);
    if (close != null) r = r.extend(close!);
    return r;
  }

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
