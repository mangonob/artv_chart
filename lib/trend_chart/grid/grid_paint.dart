import 'package:flutter/material.dart';

import '../common/render_params.dart';
import '../series/batch_series_paint.dart';
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
    return ClipRect(
      child: CustomPaint(
        painter: grid.createPainter(RenderParams.of(context)),
        child: GridScope(
          grid: grid,
          child: BatchSeriesPaint(
            series: grid.series,
            child: child,
          ),
        ),
      ),
    );
  }
}
