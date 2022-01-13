import 'dart:ui';

import 'package:flutter/material.dart';

class RenderParams {
  final double unit;
  final double phase;

  const RenderParams({
    required this.unit,
    required this.phase,
  });

  RenderParams copyWith({
    double? unit,
    double? phase,
  }) =>
      RenderParams(
        unit: unit ?? this.unit,
        phase: phase ?? this.phase,
      );

  @override
  operator ==(Object other) =>
      identical(this, other) ||
      other is RenderParams && unit == other.unit && phase == other.phase;

  @override
  int get hashCode => hashValues(unit, phase);

  static RenderParams lerp(RenderParams a, RenderParams b, double t) {
    return RenderParams(
      unit: lerpDouble(a.unit, b.unit, t)!,
      phase: lerpDouble(a.phase, b.phase, t)!,
    );
  }
}

class RenderParamsTween extends Tween<RenderParams> {
  RenderParamsTween({
    required RenderParams begin,
    required RenderParams end,
  }) : super(begin: begin, end: end);

  @override
  RenderParams lerp(double t) => RenderParams.lerp(begin!, end!, t);
}
