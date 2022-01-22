import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

class ColorTile extends StatelessWidget {
  final String title;
  final Color value;
  final ValueChanged<Color>? onChanged;

  const ColorTile({
    Key? key,
    required this.title,
    required this.value,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: GestureDetector(
        onTap: () {
          ColorPicker(
            color: value,
            onColorChanged: (v) {
              onChanged?.call(v);
            },
            pickersEnabled: const {
              ColorPickerType.wheel: true,
            },
          ).showPickerDialog(context);
        },
        child: Container(
          height: 30,
          width: 55,
          decoration: BoxDecoration(
            color: value,
            border: Border.all(
              width: 1,
              color: Colors.grey[200] ?? Colors.grey,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }
}
