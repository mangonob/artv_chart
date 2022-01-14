import 'package:flutter/material.dart';

import 'chart_label.dart';

class DecorationLabel extends ChartLabel {
  final Size size;
  final Decoration decoration;

  DecorationLabel({
    required this.size,
    required this.decoration,
    Alignment alignment = Alignment.centerRight,
  }) : super(alignment: alignment);

  @override
  ChartLabelPainter createPainter() => _DecorationLabelPainter(this);
}

class _DecorationLabelPainter extends ChartLabelPainter {
  final DecorationLabel label;

  _DecorationLabelPainter(this.label);

  @override
  void paint(
    Canvas canvas, {
    required Offset offset,
    required Alignment alignment,
    TextStyle? textStyle,
  }) {
    final painter = label.decoration.createBoxPainter();
    painter.paint(
      canvas,
      offset +
          alignment.alongSize(label.size) -
          label.size.bottomRight(Offset.zero),
      ImageConfiguration(size: label.size),
    );
  }
}
