import 'package:artv_chart/trend_chart/grid/grid.dart';
import 'package:flutter/material.dart';

import '../common/render_params.dart';
import 'series.dart';

class SeriesPaint extends StatelessWidget {
  final Series series;
  final Widget child;

  const SeriesPaint({
    Key? key,
    required this.series,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: CustomPaint(
        painter: series.createPainter(
          RenderParams.of(context),
          grid: Grid.of(context),
        ),
        child: child,
      ),
    );
  }
}
