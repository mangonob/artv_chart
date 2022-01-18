import 'package:artv_chart/trend_chart/common/enum.dart';
import 'package:artv_chart/trend_chart/common/render_params.dart';
import 'package:artv_chart/trend_chart/grid/label/chart_label.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../common/range.dart';
import '../common/style.dart';
import '../grid/grid_style.dart';
import '../series/series.dart';
import 'boundary.dart';
import 'custom_line.dart';
import 'grid_painter.dart';

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

  Range _yRange({RenderParams? params, Size? size}) {
    if (series.isEmpty) {
      return const Range.empty();
    } else {
      return series.map((e) => e.yRange()).reduce((l, r) => l.union(r));
    }
  }

  Range yRange({RenderParams? params, Size? size}) {
    return boundaries.fold(
      _yRange(params: params, size: size),
      (r, boundary) => boundary.createRange(r),
    );
  }

  List<double> xValues() {
    if (series.isEmpty) {
      return [];
    } else {
      return series.map((e) => e.xValues()).reduce((l, r) => l + r);
    }
  }
}
