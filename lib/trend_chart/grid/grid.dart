import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../common/enum.dart';
import '../common/painter/cache_manager.dart';
import '../common/range.dart';
import '../common/render_params.dart';
import '../common/style.dart';
import '../grid/grid_style.dart';
import '../series/series.dart';
import 'boundary.dart';
import 'custom_line.dart';
import 'grid_painter.dart';
import 'label/chart_label.dart';

typedef ValueFormatter = ChartLabel? Function(double);

class Grid {
  final String? identifier;
  final LineStyle? Function()? xLineStyleFn;
  final int ySplitCount;
  final GridStyle _style;
  final List<Series> series;
  final List<Boundary> boundaries;
  final ValueFormatter? xLabel;
  final ValueFormatter? yLabel;
  final List<CustomLine>? xCustomLines;
  final List<CustomLine>? yCustomLines;

  GridStyle get style => _style;

  Grid({
    this.identifier,
    this.xLineStyleFn,
    this.ySplitCount = 5,
    GridStyle? style,
    this.series = const [],
    this.boundaries = const [],
    this.xLabel,
    this.yLabel,
    this.xCustomLines,
    this.yCustomLines,
  }) : _style = style ?? GridStyle();

  @override
  operator ==(Object other) =>
      identical(this, other) ||
      other is Grid &&
          identifier == other.identifier &&
          xLineStyleFn == other.xLineStyleFn &&
          ySplitCount == other.ySplitCount &&
          _style == other._style &&
          listEquals(series, other.series) &&
          listEquals(boundaries, other.boundaries) &&
          xLabel == other.xLabel &&
          yLabel == other.yLabel &&
          listEquals(xCustomLines, other.xCustomLines) &&
          listEquals(yCustomLines, other.yCustomLines);

  @override
  int get hashCode => hashValues(
        identifier,
        xLineStyleFn,
        ySplitCount,
        _style,
        hashList(series),
        hashList(boundaries),
        xLabel,
        yLabel,
        hashList(xCustomLines),
        hashList(yCustomLines),
      );

  CustomPainter createPainter(RenderParams renderParams) => GridPainter(
        grid: this,
        renderParams: renderParams,
      );

  Range xRange({
    required RenderParams params,
    required Size size,
  }) {
    if (series.isEmpty) {
      return const Range.empty();
    } else {
      final total = params.xRange;
      if (params.unit == 0) {
        return total;
      } else {
        final unit = params.unit;
        assert(params.unit > 0);
        final xOffset = params.xOffset;
        final isIgnoredUnitVolume = params.isIgnoredUnitVolume;
        final padding = params.padding;
        final modelOffset = xOffset - padding.left;
        final start = (total.lower + modelOffset / unit)
            .reserve(params.xOffsetReserveMode);
        return Range(start, start + size.width / unit) -
            (isIgnoredUnitVolume ? 0 : 0.5);
      }
    }
  }

  Range yRange({
    required RenderParams params,
    required Size size,
    Cache? cache,
  }) {
    final xRange = cache?.xRange ?? this.xRange(params: params, size: size);
    final range = series.fold<Range>(
      const Range.empty(),
      (range, s) => range.union(s.yRange(xRange)),
    );

    return boundaries.fold(
      range,
      (r, boundary) => boundary.createRange(r),
    );
  }

  List<double> xValues({
    required RenderParams params,
    required Size size,
    Cache? cache,
  }) {
    if (series.isEmpty) {
      return [];
    } else {
      final total = series.map((e) => e.xValues()).reduce((l, r) => l + r);
      final xRange = cache?.xRange ?? this.xRange(params: params, size: size);
      return total.where((g) => xRange.contains(g)).toList();
    }
  }

  static Grid of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<GridScope>();
    assert(scope != null, "$GridScope scope not found");
    return scope!.grid;
  }
}

class GridScope extends InheritedWidget {
  final Grid grid;

  const GridScope({
    Key? key,
    required this.grid,
    required Widget child,
  }) : super(
          key: key,
          child: child,
        );

  @override
  bool updateShouldNotify(covariant GridScope oldWidget) {
    return oldWidget.grid != grid;
  }
}
