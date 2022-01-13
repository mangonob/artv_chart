import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'common/render_params.dart';
import 'grid/grid.dart';
import 'series/series.dart';

class LayoutDetails {
  final Grid grid;
  final List<Series> series;
  final RenderParams renderParams;

  LayoutDetails({
    required this.grid,
    required this.series,
    required this.renderParams,
  });

  @override
  operator ==(Object other) =>
      other is LayoutDetails &&
      grid == other.grid &&
      listEquals(series, other.series) &&
      renderParams == other.renderParams;

  @override
  int get hashCode => hashValues(
        grid,
        hashList(series),
        renderParams,
      );
}
