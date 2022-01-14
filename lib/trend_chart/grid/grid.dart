import 'package:artv_chart/trend_chart/grid/boundary.dart';
import 'package:artv_chart/trend_chart/grid/grid_painter.dart';
import 'package:artv_chart/trend_chart/series/series.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../common/style.dart';
import '../grid/grid_style.dart';

class Grid {
  final String? identifier;
  final LineStyle? Function()? xLineStyleFn;
  final GridStyle style;
  final List<Series> series;
  final List<Boundary> boundaries;

  Grid({
    this.identifier,
    this.xLineStyleFn,
    this.style = const GridStyle(),
    this.series = const [],
    this.boundaries = const [],
  });

  @override
  operator ==(Object other) =>
      identical(this, other) ||
      other is Grid &&
          identifier == other.identifier &&
          xLineStyleFn == other.xLineStyleFn &&
          style == other.style &&
          listEquals(series, other.series);

  @override
  int get hashCode => hashValues(
        identifier,
        xLineStyleFn,
        style,
        hashList(series),
      );

  CustomPainter createPainter() => GridPainter(grid: this);
}
