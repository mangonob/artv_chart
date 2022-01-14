import 'package:flutter/material.dart';

import 'grid.dart';

class GridPaint extends StatelessWidget {
  final Grid grid;
  final Widget? child;

  const GridPaint({
    Key? key,
    required this.grid,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: grid.createPainter(),
      child: child,
    );
  }
}
