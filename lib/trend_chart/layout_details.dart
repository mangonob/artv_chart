import 'package:flutter/material.dart';

import 'common/render_params.dart';
import 'grid/grid.dart';

class LayoutDetails {
  final Grid grid;
  final RenderParams renderParams;

  LayoutDetails({
    required this.grid,
    required this.renderParams,
  });

  @override
  operator ==(Object other) =>
      other is LayoutDetails &&
      grid == other.grid &&
      renderParams == other.renderParams;

  @override
  int get hashCode => hashValues(
        grid,
        renderParams,
      );
}
