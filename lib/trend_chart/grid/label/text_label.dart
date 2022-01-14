import 'package:flutter/material.dart';

import 'chart_label.dart';

class TextLabel extends ChartLabel {
  final String? text;
  final TextStyle? style;

  TextLabel(
    this.text, {
    this.style,
    Alignment? alignment,
  }) : super(alignment: alignment);

  @override
  ChartLabelPainter createPainter() => _TextLabelPainter(this);
}

class _TextLabelPainter extends ChartLabelPainter {
  final TextLabel label;

  _TextLabelPainter(this.label);

  @override
  void paint(
    Canvas canvas, {
    required Offset offset,
    required Alignment alignment,
    TextStyle? textStyle,
  }) {
    if (label.text != null) {
      final painter = TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(text: label.text, style: label.style ?? textStyle),
      )..layout();

      painter.paint(
        canvas,
        offset +
            alignment.alongSize(painter.size) -
            Offset(painter.size.width, painter.size.height),
      );
    }
  }
}
