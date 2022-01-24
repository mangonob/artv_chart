import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../utils/extensions/geometry_extensions.dart';
import '../../../chart_coordinator.dart';
import '../../../common/painter/line_painter.dart';
import '../candle_series_label_style.dart';

class ValueRemarkPainter {
  final ChartCoordinator coordinator;

  ValueRemarkPainter({
    required this.coordinator,
  });

  void paint(
    Canvas canvas, {
    String? content,
    required double value,
    required int position,
    required ValueRemarkStyle? style,
  }) {
    if (content == null) return;
    final size = coordinator.size;
    if (size.isEmpty) return;

    assert(size.width > 0 && size.height > 0);

    final origin =
        coordinator.convertPointFromGrid(Offset(position.toDouble(), value));
    final anchor = Offset(origin.dx / size.width, origin.dy / size.height);
    if (!const Rect.fromLTWH(0, 0, 1, 1).contains(anchor)) return;

    final ensureStyle = ValueRemarkStyle().merge(style);
    final theta = ensureStyle.theta!;
    final delta = ensureStyle.leadingDelta!;
    final l1 = ensureStyle.leadingLineLength!;
    final l2 = ensureStyle.labelLineLength!;
    final textStyle = ensureStyle.textStyle!;
    final lineStyle = ensureStyle.lineStyle!;
    final textPadding = ensureStyle.padding!;
    final alignment = ensureStyle.alignment!;
    final verticalDirectionSwitchMode =
        ensureStyle.verticalDirectionSwitchMode!;
    final horizontalDirectionSwitchMode =
        ensureStyle.horizontalDirectionSwitchMode!;

    final gridRect =
        Rect.fromLTWH(0, 0, coordinator.size.width, coordinator.size.height);
    final l1End = delta + Offset(-l1 * cos(theta), l1 * sin(theta));
    final l2End = l1End + Offset(l2, 0);
    final textPainter = TextPainter(
      text: TextSpan(text: content, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    final textSize = textPainter.size;
    final labelSize =
        textSize + Offset(textPadding.horizontal, textPadding.vertical);
    final labelOffset = l2End +
        alignment.alongSize(labelSize) -
        Offset(labelSize.width, labelSize.height);
    final textRect = Rect.fromLTWH(
      labelOffset.dx,
      labelOffset.dy,
      labelSize.width,
      labelSize.height,
    );
    final container = Rect.fromPoints(delta, l2End).expandToInclude(textRect);

    var direction = const Offset(1, 1);

    switch (horizontalDirectionSwitchMode) {
      case DirectionSwitchMode.inMiddle:
        direction = direction.copyWith(dx: anchor.dx > 0.5 ? -1 : 1);
        break;
      case DirectionSwitchMode.boundaryStart:
        direction = direction.copyWith(dx: -1);
        if (container.apply(direction).shift(origin).left < gridRect.left) {
          direction = direction.flip(inHorizontal: true);
        }
        break;
      case DirectionSwitchMode.boundaryEnd:
        if (container.apply(direction).shift(origin).right > gridRect.right) {
          direction = direction.flip(inHorizontal: true);
        }
        break;
    }

    switch (verticalDirectionSwitchMode) {
      case DirectionSwitchMode.inMiddle:
        direction = direction.copyWith(dy: anchor.dy > 0.5 ? 1 : -1);
        break;
      case DirectionSwitchMode.boundaryStart:
        direction = direction.copyWith(dy: -1);
        if (container.apply(direction).shift(origin).top < gridRect.top) {
          direction = direction.flip(inHorizontal: false);
        }
        break;
      case DirectionSwitchMode.boundaryEnd:
        if (container.apply(direction).shift(origin).bottom > gridRect.bottom) {
          direction = direction.flip(inHorizontal: false);
        }
        break;
    }

    LinePainter().paint(
      canvas,
      start: origin + delta.apply(direction),
      end: origin + l1End.apply(direction),
      style: lineStyle,
    );

    LinePainter().paint(
      canvas,
      start: origin + l1End.apply(direction),
      end: origin + l2End.apply(direction),
      style: lineStyle,
    );

    final textContainer = textRect.apply(direction).shift(origin);
    textPainter.paint(canvas, textContainer.topLeft + textPadding.topLeft);
  }
}

extension _OffsetExtension on Offset {
  /// Transform offset by vector defined by [Offset]
  Offset apply(Offset other) => Offset(dx * other.dx, dy * other.dy);

  Offset flip({
    required bool inHorizontal,
  }) =>
      inHorizontal ? Offset(-dx, dy) : Offset(dx, -dy);
}

extension _RectExtension on Rect {
  Rect apply(Offset other) => Rect.fromPoints(
        topLeft.apply(other),
        bottomRight.apply(other),
      );
}
