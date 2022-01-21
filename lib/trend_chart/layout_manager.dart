import 'package:flutter/widgets.dart';

import 'grid/grid.dart';
import 'trend_chart.dart';

/// TODO: Remove this class.
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
}
