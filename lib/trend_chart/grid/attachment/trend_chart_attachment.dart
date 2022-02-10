import 'package:flutter/material.dart';

import 'attachment_style.dart';

enum AttachmentPosition {
  top,
  bottom,
  left,
  right,
}

typedef AttachmentContentFn = String? Function(int position);

class TrendChartAttachment {
  final AttachmentStyle _style;
  final bool? isBounded;
  final AttachmentPosition position;
  final Alignment? alignment;
  final String? Function(int position)? contentFn;

  AttachmentStyle get style => _style;

  TrendChartAttachment({
    required this.position,
    AttachmentStyle? style,
    this.isBounded = true,
    this.alignment,
    this.contentFn,
  }) : _style = const AttachmentStyle().merge(style);

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

  AttachmentPainter createPainter() => AttachmentPainter(this);

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

class AttachmentPainter {
  final TrendChartAttachment attachment;

  AttachmentPainter(this.attachment);

  void paint(
    Canvas canvas,
    Size size, {
    required Offset focusPosition,
  }) {}
}
