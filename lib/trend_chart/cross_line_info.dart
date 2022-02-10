import 'package:flutter/material.dart';

import 'grid/grid.dart';

class CrossLineEntry {
  /// Current focused grid
  final Grid grid;

  /// Rect of current focused grid in chart coordinate
  final Rect gridRect;

  CrossLineEntry({
    required this.grid,
    required this.gridRect,
  });
}

class CrossLineInfo {
  final List<CrossLineEntry> visibleGridEntries;

  CrossLineInfo({
    required this.visibleGridEntries,
  });
}
