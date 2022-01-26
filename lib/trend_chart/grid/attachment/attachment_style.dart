import 'package:flutter/material.dart';

class AttachmentStyle {
  final TextStyle? textStyle;

  /// Attachment
  final Decoration? decoration;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const AttachmentStyle({
    this.textStyle,
    this.decoration,
    this.padding = const EdgeInsets.symmetric(horizontal: 2),
    this.margin = const EdgeInsets.all(0),
  });

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
