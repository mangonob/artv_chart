import 'package:flutter/widgets.dart';

import 'grid/grid.dart';
import 'layout_info.dart';
import 'trend_chart.dart';

class LayoutManager extends ChangeNotifier {
  TrendChartState? _state;

  void bindState(TrendChartState state) {
    assert(_state == null || _state == state);
    if (state != _state) {
      _state = state;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _state = null;
  }

  Rect rectForGrid(Grid grid, BoxConstraints constraints) {
    return Rect.zero;
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
      series: [],
      renderParams: _state!.renderParams,
    );
  }
}
