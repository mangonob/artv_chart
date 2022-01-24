import 'dart:math';

import 'package:flutter/material.dart';

import '../../common/style.dart';

class ValueRemarkStyle {
  final TextStyle? _textStyle;
  final LineStyle? _lineStyle;

  /// Padding of text label (default: EdgeInsets.symmetric(horizontal: 2)).
  final EdgeInsets? padding;

  /// Length of leading-line (default: 20).
  /// Leading-line is a line that start from anchor and end to the start point of label-line.
  ///
  ///         _________ (Label)
  ///        /
  ///       /
  ///      /
  ///   Anchor
  ///
  final double? leadingLineLength;

  /// Length of label-line (default: 0).
  /// Label-line is a horizontal line that start from end point of leading line and end to the label.
  /// SeeAlso: [leadingLineLength]
  final double? labelLineLength;

  /// How to align the text with end point of label-line .
  final Alignment? alignment;
  final DirectionSwitchMode? horizontalDirectionSwitchMode;
  final DirectionSwitchMode? verticalDirectionSwitchMode;

  /// Angle in radian between leading-line and label-line (default: 0.9 * pi).
  final double? theta;

  /// Offset between anchor and start point of leading-line (default: Offset(0, 1)).
  final Offset? leadingDelta;

  /// Style of text label.
  TextStyle? get textStyle => _textStyle;

  /// Style of leading-line and label-line.
  LineStyle? get lineStyle => _lineStyle;

  ValueRemarkStyle({
    TextStyle? textStyle,
    LineStyle? lineStyle,
    this.padding = const EdgeInsets.symmetric(horizontal: 2),
    this.leadingLineLength = 20,
    this.labelLineLength = 0,
    this.alignment = Alignment.centerRight,
    this.horizontalDirectionSwitchMode = DirectionSwitchMode.boundaryEnd,
    this.verticalDirectionSwitchMode = DirectionSwitchMode.inMiddle,
    this.theta = 0.9 * pi,
    this.leadingDelta = const Offset(0, 1),
  })  : _textStyle =
            const TextStyle(fontSize: 8, color: Colors.grey).merge(textStyle),
        _lineStyle =
            const LineStyle(size: 1, color: Colors.grey).merge(lineStyle);

  ValueRemarkStyle copyWith({
    TextStyle? textStyle,
    LineStyle? lineStyle,
    EdgeInsets? padding,
    double? leadingLineLength,
    double? labelLineLength,
    Alignment? alignment,
    DirectionSwitchMode? horizontalDirectionSwitchMode,
    DirectionSwitchMode? verticalDirectionSwitchMode,
    double? theta,
    Offset? leadingDelta,
  }) =>
      ValueRemarkStyle(
        textStyle: textStyle ?? this.textStyle,
        lineStyle: lineStyle ?? this.lineStyle,
        padding: padding ?? this.padding,
        leadingLineLength: leadingLineLength ?? this.leadingLineLength,
        labelLineLength: labelLineLength ?? this.labelLineLength,
        alignment: alignment ?? this.alignment,
        horizontalDirectionSwitchMode:
            horizontalDirectionSwitchMode ?? this.horizontalDirectionSwitchMode,
        verticalDirectionSwitchMode:
            verticalDirectionSwitchMode ?? this.verticalDirectionSwitchMode,
        theta: theta ?? this.theta,
        leadingDelta: leadingDelta ?? this.leadingDelta,
      );

  ValueRemarkStyle merge(ValueRemarkStyle? other) {
    if (other == null) return this;

    return copyWith(
      textStyle: other.textStyle,
      lineStyle: other.lineStyle,
      padding: other.padding,
      leadingLineLength: other.leadingLineLength,
      labelLineLength: other.labelLineLength,
      alignment: other.alignment,
      horizontalDirectionSwitchMode: other.horizontalDirectionSwitchMode,
      verticalDirectionSwitchMode: other.verticalDirectionSwitchMode,
      theta: other.theta,
      leadingDelta: other.leadingDelta,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ValueRemarkStyle &&
      other.textStyle == textStyle &&
      other.lineStyle == lineStyle &&
      other.padding == padding &&
      other.leadingLineLength == leadingLineLength &&
      other.labelLineLength == labelLineLength &&
      other.alignment == alignment &&
      other.horizontalDirectionSwitchMode == horizontalDirectionSwitchMode &&
      other.verticalDirectionSwitchMode == verticalDirectionSwitchMode &&
      other.theta == theta &&
      other.leadingDelta == leadingDelta;

  @override
  int get hashCode => hashValues(
        textStyle,
        lineStyle,
        padding,
        leadingLineLength,
        labelLineLength,
        alignment,
        horizontalDirectionSwitchMode,
        verticalDirectionSwitchMode,
        theta,
        leadingDelta,
      );
}

enum DirectionSwitchMode {
  inMiddle,
  boundaryStart,
  boundaryEnd,
}
