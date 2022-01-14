import 'dart:ui';

import 'package:artv_chart/trend_chart/trend_chart.dart';
import 'package:flutter/material.dart';

class RenderParams {
  final double unit;
  final double xOffset;
  final ReserveMode xOffsetReserveMode;

  const RenderParams({
    required this.unit,
    required this.xOffset,
    required this.xOffsetReserveMode,
  });

  RenderParams copyWith({
    double? unit,
    double? xOffset,
    ReserveMode? xOffsetReserveMode,
  }) =>
      RenderParams(
        unit: unit ?? this.unit,
        xOffset: xOffset ?? this.xOffset,
        xOffsetReserveMode: this.xOffsetReserveMode,
      );

  @override
  operator ==(Object other) =>
      identical(this, other) ||
      other is RenderParams &&
          unit == other.unit &&
          xOffset == other.xOffset &&
          xOffsetReserveMode == other.xOffsetReserveMode;

  @override
  int get hashCode => hashValues(
        unit,
        xOffset,
        xOffsetReserveMode,
      );

  static RenderParams lerp(RenderParams a, RenderParams b, double t) {
    return RenderParams(
      unit: lerpDouble(a.unit, b.unit, t)!,
      xOffset: lerpDouble(a.xOffset, b.xOffset, t)!,
      xOffsetReserveMode: b.xOffsetReserveMode,
    );
  }

  static RenderParams of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<RenderParamsScope>();
    assert(scope != null, "$RenderParamsScope not found.");
    return scope!.renderParams;
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

class RenderParamsScope extends InheritedWidget {
  final RenderParams renderParams;

  const RenderParamsScope({
    Key? key,
    required this.renderParams,
    required Widget child,
  }) : super(
          key: key,
          child: child,
        );

  @override
  bool updateShouldNotify(covariant RenderParamsScope oldWidget) {
    return oldWidget.renderParams != renderParams;
  }
}
