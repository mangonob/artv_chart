import 'package:flutter/material.dart';

class AttachmentStyle {
  final TextStyle? _textStyle;

  /// Attachment
  final Decoration? decoration;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  TextStyle? get textStyle => _textStyle;

  AttachmentStyle({
    TextStyle? textStyle,
    Decoration? decoration,
    this.padding = kAttachmentStyleDefaultPadding,
    this.margin = kAttachmentStyleDefaultMargin,
  })  : _textStyle = const TextStyle(
          fontSize: 10,
          color: Colors.black87,
        ).merge(textStyle),
        decoration = decoration ??
            BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(1),
            );

  AttachmentStyle copyWith({
    TextStyle? textStyle,
    Decoration? decoration,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    return AttachmentStyle(
      textStyle: textStyle ?? this.textStyle,
      decoration: decoration ?? this.decoration,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
    );
  }

  AttachmentStyle merge(AttachmentStyle? other) {
    if (other == null) return this;

    return copyWith(
      textStyle: other.textStyle,
      decoration: other.decoration,
      padding: other.padding,
      margin: other.margin,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AttachmentStyle &&
        other.textStyle == textStyle &&
        other.decoration == decoration &&
        other.padding == padding &&
        other.margin == margin;
  }

  @override
  int get hashCode => hashValues(
        textStyle,
        decoration,
        padding,
        margin,
      );
}

const kAttachmentStyleDefaultPadding = EdgeInsets.symmetric(horizontal: 2);

const kAttachmentStyleDefaultMargin = EdgeInsets.zero;
