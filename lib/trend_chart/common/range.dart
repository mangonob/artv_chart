import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class Range {
  final double lower;
  final double upper;

  const Range(
    this.lower,
    this.upper,
  );

  /// The range contain all value greater then given value.
  const Range.lowest(double lower) : this(lower, double.infinity);

  /// The range contain all value less than given value.
  const Range.highest(double upper) : this(double.negativeInfinity, upper);

  /// The range that does not contain any values.
  const Range.empty() : this(double.infinity, double.negativeInfinity);

  /// The range that contain all values.
  const Range.unbounded() : this(double.negativeInfinity, double.infinity);

  operator +(double value) => Range(lower + value, upper + value);

  operator -(double value) => Range(lower - value, upper - value);

  operator *(double value) => Range(lower * value, upper * value);

  operator /(double value) => Range(lower / value, upper / value);

  bool get isEmpty => lower > upper;
  bool get isNotEmpty => lower <= upper;

  double get length => upper - lower;

  /// Intersection set
  Range intersection(Range other) => Range(
        max(lower, other.lower),
        min(upper, other.upper),
      );

  /// Whether two range is intersected.
  bool intersected(Range other) => intersection(other).isNotEmpty;

  /// Union set
  Range union(Range other) => Range(
        min(lower, other.lower),
        max(upper, other.upper),
      );

  /// Extend range to include the given value.
  /// ```dart
  /// Range(1, 3).extend(2); // Range(1, 3)
  ///
  /// Range.empty().extend(4); // Range(4, 4)
  ///
  /// Range(1, 3).extend(4); // Range(1, 4)
  /// ```
  Range extend(double value) => Range(
        min(lower, value),
        max(upper, value),
      );

  /// Whether the value is in the range.
  bool contains(double value) => lower <= value && value <= upper;

  static Range lerp(Range a, Range b, double t) => Range(
        lerpDouble(a.lower, b.lower, t)!,
        lerpDouble(a.upper, b.upper, t)!,
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

  /// Split range into [count] parts.
  List<double> split(int count) {
    if (isEmpty) {
      return [];
    } else {
      final step = length / count;
      return List.generate(count + 1, (index) => lower + step * index);
    }
  }
}
