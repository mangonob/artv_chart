import 'package:flutter/material.dart';

/// Description a absolute or relative distance of 2-dimension
class Distance {
  final double? absolute;
  final double? relative;

  const Distance({
    this.absolute,
    this.relative,
  }) : assert(absolute != null || relative != null);

  const Distance.absolute(double value) : this(absolute: value);

  const Distance.relative(double value) : this(relative: value);

  bool get isAbsolute => absolute != null;

  bool get isRelative => absolute != null;

  operator /(double value) => Distance(
        absolute: absolute != null ? absolute! / value : null,
        relative: relative != null ? relative! / value : null,
      );

  operator *(double value) => Distance(
        absolute: absolute != null ? absolute! * value : null,
        relative: relative != null ? relative! * value : null,
      );

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
      other is Distance &&
      absolute == other.absolute &&
      relative == other.relative;

  @override
  int get hashCode => hashValues(absolute, relative);
}
