import 'package:flutter/material.dart';

import '../../common/style.dart';

abstract class ChartLabel {
  final Alignment? alignment;
  final LineStyle? lineStyle;

  ChartLabel({
    this.alignment,
    this.lineStyle,
  });

  ChartLabelPainter createPainter();
}

abstract class ChartLabelPainter {
  /// [alignment] Alignment provider by [Grid] this value will override by [ChatLabel.alignment] if not null.
  /// [textStyle] provider by [GridStyle]
  void paint(
    Canvas canvas, {
    required Offset offset,
    required Alignment alignment,
    TextStyle? textStyle,
  }) {}
}
