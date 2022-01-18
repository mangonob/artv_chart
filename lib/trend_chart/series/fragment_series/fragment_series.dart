import 'package:flutter/material.dart';

import '../../common/render_params.dart';
import '../../grid/grid.dart';
import '../../series/series.dart';

class FragmentSeries extends Series<dynamic> {
  final List<Series> series;

  FragmentSeries(this.series) : super(datas: []);

  @override
  CustomPainter createPainter(RenderParams renderParams, {required Grid grid}) {
    // TODO: implement createPainter
    throw UnimplementedError();
  }
}
