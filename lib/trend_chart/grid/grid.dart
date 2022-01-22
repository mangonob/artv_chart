import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../common/enum.dart';
import '../common/range.dart';
import '../common/render_params.dart';
import '../common/style.dart';
import '../grid/grid_style.dart';
import '../series/series.dart';
import 'boundary.dart';
import 'custom_line.dart';
import 'grid_cache.dart';
import 'grid_painter.dart';
import 'label/chart_label.dart';

typedef ValueFormatter<T> = ChartLabel? Function(T);

class Grid {
  final String? identifier;
  final LineStyle? Function()? xLineStyleFn;
  final int ySplitCount;
  final GridStyle _style;
  final List<Series> series;
  final List<Boundary> boundaries;
  final ValueFormatter<int>? xLabel;
  final ValueFormatter<double>? yLabel;
  final List<CustomLine>? xCustomLines;
  final List<CustomLine>? yCustomLines;

  GridStyle get style => _style;

  final GridCache _cache;

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
  })  : _style = style ?? GridStyle(),
        _cache = GridCache();

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
        gridCache: _cache,
      );

  /// Logical x range of current visible grid area, it's boundary can be floating point number.
  /// [params] the render params.
  /// [size] grid size.
  Range xRange({
    required RenderParams params,
    required Size size,
  }) {
    if (_cache.xRange != null) return _cache.xRange!;
    final xRange = _xRange(params: params, size: size);
    _cache.write(xRange: xRange);
    return xRange;
  }

  Range _xRange({
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
  }) {
    if (_cache.yRange != null) return _cache.yRange!;
    final yRange = _yRange(params: params, size: size);
    _cache.write(yRange: yRange);
    return yRange;
  }

  Range _yRange({
    required RenderParams params,
    required Size size,
  }) {
    final xRange = this.xRange(params: params, size: size);
    final range = series.fold<Range>(
      const Range.empty(),
      (range, s) => range.union(s.yRange(xRange)),
    );

    return boundaries.fold(
      range,
      (r, boundary) => boundary.createRange(r),
    );
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
