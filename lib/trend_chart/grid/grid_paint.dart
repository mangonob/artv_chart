import 'package:artv_chart/trend_chart/common/render_params.dart';
import 'package:artv_chart/trend_chart/series/batch_series_paint.dart';
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
    return ClipRect(
      child: CustomPaint(
        painter: grid.createPainter(RenderParams.of(context)),
        child: BatchSeriesPaint(
          series: grid.series,
          child: child,
        ),
      ),
    );
  }
}
