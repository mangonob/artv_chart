import 'package:artv_chart/trend_chart/common/render_params.dart';
import 'package:flutter/material.dart';

import 'attachment_painter.dart';
import 'attachment_style.dart';

enum AttachmentPosition {
  top,
  bottom,
  left,
  right,
}

extension AttachmentPositionExtension on AttachmentPosition {
  bool get isVertical =>
      this == AttachmentPosition.top || this == AttachmentPosition.bottom;

  bool get isHorizontal =>
      this == AttachmentPosition.left || this == AttachmentPosition.right;

  Alignment defaultAlignment() {
    switch (this) {
      case AttachmentPosition.top:
        return Alignment.bottomCenter;
      case AttachmentPosition.left:
        return Alignment.centerRight;
      case AttachmentPosition.right:
        return Alignment.centerLeft;
      case AttachmentPosition.bottom:
        return Alignment.topCenter;
    }
  }
}

typedef AttachmentContentFn = String? Function(int position);

class TrendChartAttachment {
  final AttachmentStyle _style;
  final bool? isBounded;
  final AttachmentPosition position;
  final Alignment _alignment;
  final String? Function(int position)? contentFn;

  AttachmentStyle get style => _style;
  Alignment get alignment => _alignment;

  TrendChartAttachment({
    required this.position,
    Alignment? alignment,
    AttachmentStyle? style,
    this.isBounded = true,
    this.contentFn,
  })  : _style = AttachmentStyle().merge(style),
        _alignment = alignment ?? position.defaultAlignment();

  TrendChartAttachment copyWith({
    AttachmentStyle? style,
    bool? isBounded,
    AttachmentPosition? position,
    Alignment? alignment,
    AttachmentContentFn? contentFn,
  }) =>
      TrendChartAttachment(
        style: style ?? _style,
        isBounded: isBounded ?? this.isBounded,
        position: position ?? this.position,
        alignment: alignment ?? this.alignment,
        contentFn: contentFn ?? this.contentFn,
      );

  TrendChartAttachment merge(TrendChartAttachment? other) {
    if (other == null) return this;

    return copyWith(
      style: _style,
      isBounded: other.isBounded,
      position: other.position,
      alignment: other.alignment,
      contentFn: other.contentFn,
    );
  }

  AttachmentPainter createPainter({
    required RenderParams renderParams,
  }) =>
      AttachmentPainter(
        this,
        renderParams: renderParams,
      );

  @override
  operator ==(Object other) =>
      other is TrendChartAttachment &&
      other.position == position &&
      other._style == _style &&
      other.isBounded == isBounded &&
      other.alignment == alignment &&
      other.contentFn == contentFn;

  @override
  int get hashCode => hashValues(
        position,
        _style,
        isBounded,
        alignment,
        contentFn,
      );
}
