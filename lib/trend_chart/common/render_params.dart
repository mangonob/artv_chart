import 'dart:ui';

import 'package:flutter/material.dart';

import '../constant.dart';
import 'enum.dart';
import 'range.dart';

class RenderParams {
  final double unit;
  final double xOffset;
  final EdgeInsets padding;
  final bool isIgnoredUnitVolume;
  final ReserveMode xOffsetReserveMode;
  final Range xRange;
  final double chartWidth;

  const RenderParams({
    required this.unit,
    required this.xOffset,
    required this.padding,
    this.isIgnoredUnitVolume = true,
    required this.xOffsetReserveMode,
    required this.xRange,
    required this.chartWidth,
  });

  RenderParams copyWith({
    double? unit,
    double? xOffset,
    EdgeInsets? padding,
    bool? isIgnoredUnitVolume,
    ReserveMode? xOffsetReserveMode,
    Range? xRange,
    double? chartWidth,
  }) =>
      RenderParams(
        unit: unit ?? this.unit,
        xOffset: xOffset ?? this.xOffset,
        padding: padding ?? this.padding,
        isIgnoredUnitVolume: isIgnoredUnitVolume ?? this.isIgnoredUnitVolume,
        xOffsetReserveMode: xOffsetReserveMode ?? this.xOffsetReserveMode,
        xRange: xRange ?? this.xRange,
        chartWidth: chartWidth ?? this.chartWidth,
      );

  @override
  operator ==(Object other) =>
      identical(this, other) ||
      other is RenderParams &&
          unit == other.unit &&
          xOffset == other.xOffset &&
          padding == other.padding &&
          isIgnoredUnitVolume == other.isIgnoredUnitVolume &&
          xOffsetReserveMode == other.xOffsetReserveMode &&
          xRange == other.xRange &&
          chartWidth == other.chartWidth;

  @override
  int get hashCode => hashValues(
        unit,
        xOffset,
        padding,
        isIgnoredUnitVolume,
        xOffsetReserveMode,
        xRange,
        chartWidth,
      );

  double get minExtend => padding.left;

  double get maxExtend {
    if (unit == kScaleToFitGridUnit) {
      return padding.right;
    } else {
      final expandedLength =
          isIgnoredUnitVolume ? xRange.length : xRange.length + 1;
      return expandedLength * unit + padding.right - chartWidth;
    }
  }

  static RenderParams lerp(RenderParams a, RenderParams b, double t) {
    return RenderParams(
      unit: lerpDouble(a.unit, b.unit, t)!,
      xOffset: lerpDouble(a.xOffset, b.xOffset, t)!,
      padding: EdgeInsets.lerp(a.padding, b.padding, t)!,
      isIgnoredUnitVolume: b.isIgnoredUnitVolume,
      xOffsetReserveMode: b.xOffsetReserveMode,
      xRange: Range.lerp(a.xRange, b.xRange, t),
      chartWidth: lerpDouble(a.chartWidth, b.chartWidth, t)!,
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
