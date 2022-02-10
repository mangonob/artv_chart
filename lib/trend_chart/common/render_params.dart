import 'dart:ui';

import 'package:flutter/material.dart';

import '../../utils/utils.dart';
import '../constant.dart';
import 'enum.dart';
import 'range.dart';

class RenderParams {
  /// Width of per item in data series.
  final double unit;

  /// Offset in pixel at left of the chart.
  final double xOffset;

  /// Horizontal content padding in pixel, the value of top and bottom will be ignored.
  final EdgeInsets padding;

  /// The data item have size like candle or not point, line etc.
  final bool isIgnoredUnitVolume;

  final ReserveMode xOffsetReserveMode;

  final Range xRange;

  final double chartWidth;

  /// Current point focus on
  final Offset focusLocation;

  int? get focusPosition {
    if (focusLocation.dx.isValid) {
      if (unit > 0) {
        final delta = isIgnoredUnitVolume ? 0 : -0.5 * unit;
        return ((focusLocation.dx + xOffset + delta - padding.left) / unit)
            .round();
      } else {
        /// TODO: kScaleToFitGridUnit
      }
    }
  }

  const RenderParams({
    required this.unit,
    required this.xOffset,
    required this.padding,
    required this.xOffsetReserveMode,
    required this.xRange,
    required this.chartWidth,
    this.isIgnoredUnitVolume = true,
    this.focusLocation = kNullLocation,
  });

  @override
  String toString() =>
      "$runtimeType { unit: $unit, xOffset: $xOffset, padding: $padding, xOffsetReserveMode: $xOffsetReserveMode, "
      "xRange: $xRange, chartWidth: $chartWidth, isIgnoredUnitVolume: $isIgnoredUnitVolume, focusLocation: $focusLocation, }";

  RenderParams copyWith({
    double? unit,
    double? xOffset,
    EdgeInsets? padding,
    bool? isIgnoredUnitVolume,
    ReserveMode? xOffsetReserveMode,
    Range? xRange,
    double? chartWidth,
    Offset? focusLocation,
  }) =>
      RenderParams(
        unit: unit ?? this.unit,
        xOffset: xOffset ?? this.xOffset,
        padding: padding ?? this.padding,
        isIgnoredUnitVolume: isIgnoredUnitVolume ?? this.isIgnoredUnitVolume,
        xOffsetReserveMode: xOffsetReserveMode ?? this.xOffsetReserveMode,
        xRange: xRange ?? this.xRange,
        chartWidth: chartWidth ?? this.chartWidth,
        focusLocation: focusLocation ?? this.focusLocation,
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
          chartWidth == other.chartWidth &&
          focusLocation == other.focusLocation;

  @override
  int get hashCode => hashValues(
        unit,
        xOffset,
        padding,
        isIgnoredUnitVolume,
        xOffsetReserveMode,
        xRange,
        chartWidth,
        focusLocation,
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
      focusLocation: b.focusLocation,
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
