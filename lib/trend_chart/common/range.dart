import 'dart:math';

import 'package:flutter/material.dart';

class Range {
  final double lower;
  final double upper;

  const Range(
    this.lower,
    this.upper,
  );

  const Range.lowest(double lower) : this(lower, double.infinity);

  const Range.highest(double upper) : this(double.negativeInfinity, upper);

  const Range.empty() : this(double.infinity, double.negativeInfinity);

  const Range.unbounded() : this(double.negativeInfinity, double.infinity);

  bool isEmpty() => lower >= upper;

  double get length => upper - lower;

  Range intersection(Range other) => Range(
        max(lower, other.lower),
        min(upper, other.upper),
      );

  Range union(Range other) => Range(
        min(lower, other.lower),
        max(upper, other.upper),
      );

  @override
  operator ==(Object other) =>
      identical(this, other) ||
      other is Range &&
          runtimeType == other.runtimeType &&
          lower == other.lower &&
          upper == other.upper;

  @override
  int get hashCode => hashValues(lower, upper);

  @override
  String toString() {
    return 'Range($lower, $upper)';
  }
}
