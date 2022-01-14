import 'package:flutter/material.dart';

import 'grid.dart';

class GridPainter extends CustomPainter {
  final Grid grid;

  GridPainter({
    required this.grid,
  });

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) {
    return oldDelegate.grid != grid;
  }

  @override
  void paint(Canvas canvas, Size size) {}
}
