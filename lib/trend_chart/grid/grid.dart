import 'package:artv_chart/trend_chart/common/render_params.dart';
import 'package:artv_chart/trend_chart/grid/label/chart_label.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../common/range.dart';
import '../common/style.dart';
import '../grid/grid_style.dart';
import '../series/series.dart';
import 'boundary.dart';
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
          yLabel == other.yLabel;

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
      );

  CustomPainter createPainter(RenderParams renderParams) => GridPainter(
        grid: this,
        renderParams: renderParams,
      );

  Range xRange({RenderParams? params, Size? size}) {
    if (series.isEmpty) {
      return const Range.empty();
    } else {
      final total = series.map((e) => e.xRange()).reduce((l, r) => l.union(r));
      if (params == null) {
        return total;
      } else {
        return total;
      }
    }
  }

  Range _yRange() {
    if (series.isEmpty) {
      return const Range.empty();
    } else {
      return series.map((e) => e.yRange()).reduce((l, r) => l.union(r));
    }
  }

  Range yRange() {
    return boundaries.fold(_yRange(), (r, boundary) => boundary.createRange(r));
  }

  List<double> xValues() {
    if (series.isEmpty) {
      return [];
    } else {
      return series.map((e) => e.xValues()).reduce((l, r) => l + r);
    }
  }
}
