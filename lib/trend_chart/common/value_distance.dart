import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class Distance {
  double apply(double value);
}

/// Description a absolute or relative distance of 2-dimension
class ValueDistance extends Distance {
  final double? absolute;
  final double? relative;

  ValueDistance({
    this.absolute,
    this.relative,
  }) : assert(absolute != null || relative != null);

  factory ValueDistance.absolute(double value) =>
      ValueDistance(absolute: value);

  factory ValueDistance.relative(double value) =>
      ValueDistance(relative: value);

  bool get isAbsolute => absolute != null;

  bool get isRelative => absolute != null;

  operator /(double value) => ValueDistance(
        absolute: absolute != null ? absolute! / value : null,
        relative: relative != null ? relative! / value : null,
      );

  operator *(double value) => ValueDistance(
        absolute: absolute != null ? absolute! * value : null,
        relative: relative != null ? relative! * value : null,
      );

  @override
  double apply(double value) {
    if (absolute != null) {
      return absolute!;
    } else if (relative != null) {
      return relative! * value;
    } else {
      return 0;
    }
  }

  @override
  operator ==(Object other) =>
      other is ValueDistance &&
      absolute == other.absolute &&
      relative == other.relative;

  @override
  int get hashCode => hashValues(absolute, relative);
}

class CombineDistance extends Distance {
  final bool useMax;
  final List<Distance> distances;

  CombineDistance({
    required this.distances,
    this.useMax = false,
  }) : assert(distances.isNotEmpty);

  @override
  double apply(double value) {
    final values = distances.map((distance) => distance.apply(value)).toList();
    if (useMax) {
      return values.reduce(max);
    } else {
      return values.reduce(min);
    }
  }

  @override
  operator ==(Object other) =>
      other is CombineDistance && listEquals(distances, other.distances);

  @override
  int get hashCode => hashList(distances);
}
