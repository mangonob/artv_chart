import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Options<T extends Object> extends StatelessWidget {
  final Iterable<T> values;
  final String? Function(T)? formatter;
  final Color? selectedColor;
  final Color? unselectedColor;
  final ValueChanged<T> onValueChagned;
  final EdgeInsets textPadding;
  final T? value;

  const Options({
    Key? key,
    required this.values,
    required this.onValueChagned,
    this.formatter,
    this.selectedColor = Colors.blue,
    this.unselectedColor = Colors.white,
    this.textPadding = const EdgeInsets.symmetric(horizontal: 4),
    this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoSegmentedControl<T>(
      groupValue: value,
      children: {
        for (final v in values)
          v: Padding(
            padding: textPadding,
            child: Text(
              formatter?.call(v) ?? v.toString(),
            ),
          )
      },
      selectedColor: selectedColor,
      unselectedColor: unselectedColor,
      borderColor: selectedColor,
      onValueChanged: onValueChagned,
    );
  }
}
