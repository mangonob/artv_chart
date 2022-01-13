import 'package:flutter/material.dart';

import '../../layout_info.dart';
import '../../series/series.dart';

class FragmentSeries extends Series<dynamic> {
  final List<Series> series;

  FragmentSeries(this.series) : super(datas: []);

  @override
  CustomPainter createPainter({required LayoutDetails details}) {
    // TODO: implement createPainter
    throw UnimplementedError();
  }
}
