import 'package:flutter/material.dart';

import '../common/style.dart';
import '../grid/grid_style.dart';

class Grid {
  final LineStyle? Function()? xLineStyleFn;
  final GridStyle? style;

  Grid({
    this.xLineStyleFn,
    this.style,
  });

  @override
  operator ==(Object other) =>
      identical(this, other) ||
      other is Grid &&
          runtimeType == other.runtimeType &&
          xLineStyleFn == other.xLineStyleFn &&
          style == other.style;

  @override
  int get hashCode => hashValues(
        xLineStyleFn,
        style,
      );
}
