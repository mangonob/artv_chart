import 'package:flutter/material.dart';

import '../../../utils/utils.dart';
import '../../common/render_params.dart';
import 'attachment_style.dart';
import 'trend_chart_attachment.dart';

class AttachmentPainter {
  final TrendChartAttachment attachment;
  final RenderParams renderParams;

  AttachmentPainter(
    this.attachment, {
    required this.renderParams,
  });

  void paint(
    Canvas canvas,
    Size size, {
    required Offset crossLineLocation,
  }) {
    final position = renderParams.focusPosition;
    if (position == null) return;
    final content = attachment.contentFn?.call(position);
    if (content == null) return;

    final anchor = _anchorOfLocation(crossLineLocation, size: size);

    if (Rect.fromLTWH(0, 0, size.width, size.height)
            .contains(crossLineLocation) ||
        attachment.position.isVertical) {
      final style = attachment.style;
      final padding = style.padding ?? kAttachmentStyleDefaultPadding;
      final margin = style.margin ?? kAttachmentStyleDefaultMargin;
      final painter = TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(text: content, style: style.textStyle),
      )..layout();
      final textSize = painter.size;
      final contentSize = Size(
        textSize.width + padding.horizontal,
        textSize.height + padding.vertical,
      );
      final containerSize = Size(
        contentSize.width + margin.horizontal,
        contentSize.height + margin.vertical,
      );

      final textOrigin = anchor +
          Offset(padding.left + margin.left, padding.top + margin.top) +
          attachment.alignment.alongSize(containerSize) -
          Offset(containerSize.width, containerSize.height);

      style.decoration.flatMap((decoration) {
        decoration.createBoxPainter().paint(
              canvas,
              textOrigin - Offset(padding.left, padding.top),
              ImageConfiguration(size: contentSize),
            );
      });

      painter.paint(canvas, textOrigin);
    }
  }

  _anchorOfLocation(Offset location, {required Size size}) {
    switch (attachment.position) {
      case AttachmentPosition.left:
        return Offset(0, location.dy);
      case AttachmentPosition.right:
        return Offset(size.width, location.dy);
      case AttachmentPosition.bottom:
        return Offset(location.dx, size.height);
      case AttachmentPosition.top:
        return Offset(location.dx, 0);
    }
  }
}
