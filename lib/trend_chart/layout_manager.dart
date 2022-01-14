import 'package:flutter/widgets.dart';

import 'grid/grid.dart';
import 'layout_details.dart';
import 'trend_chart.dart';

class LayoutManager extends ChangeNotifier {
  TrendChartState? _state;

  void bindState(TrendChartState state) {
    if (state != _state) {
      _state = state;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _state = null;
  }

  static LayoutManager of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<TrendChartScope>();
    assert(scope != null, "$TrendChartScope not found.");
    return scope!.layoutManager;
  }

  Rect rectForGrid(Grid grid, BoxConstraints constraints) {
    _ensureConstraints(constraints);
    double currentHeight = 0;

    for (final curr in _state!.widget.grids) {
      final height = heightForGrid(grid, constraints);
      if (grid == curr) {
        return Rect.fromLTWH(0, currentHeight, constraints.maxWidth, height);
      } else {
        currentHeight += height;
      }
    }

    return Rect.fromLTWH(
      0,
      currentHeight,
      constraints.maxWidth,
      heightForGrid(grid, constraints),
    );
  }

  void _ensureConstraints(BoxConstraints constraints) {
    assert(constraints.hasBoundedWidth);
  }

  double heightForGrid(Grid grid, BoxConstraints constraints) {
    _ensureConstraints(constraints);
    final margin = grid.style.margin ?? EdgeInsets.zero;
    final contentWidth = constraints.maxWidth - margin.horizontal;
    return (grid.style.height ?? grid.style.ratio! * contentWidth) +
        margin.vertical;
  }

  Rect convertRectFromGrid(Rect rect, Grid grid) {
    return rect;
  }

  Rect convertRectToGrid(Rect rect, Grid grid) {
    return rect;
  }

  Offset convertPointFromGrid(Offset point, Grid grid) {
    return point;
  }

  Offset convetPointToGrid(Offset point, Grid grid) {
    return point;
  }

  LayoutDetails createLayoutInfo(Grid grid) {
    return LayoutDetails(
      grid: grid,
      renderParams: _state!.renderParams,
    );
  }
}
