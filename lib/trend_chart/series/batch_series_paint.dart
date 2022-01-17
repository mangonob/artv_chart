import 'package:flutter/material.dart';

import '../common/render_params.dart';
import 'series.dart';

class BatchSeriesPaint extends StatelessWidget {
  final List<Series> series;
  final Widget? child;

  const BatchSeriesPaint({
    Key? key,
    required this.series,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (series.isEmpty) {
      return child ?? const SizedBox();
    } else {
      final head = series.first;
      final tail = series.skip(1).toList();
      return ClipRect(
        child: CustomPaint(
          painter: head.createPainter(RenderParams.of(context)),
          child: BatchSeriesPaint(
            series: tail,
            child: child,
          ),
        ),
      );
    }
  }
}
