import 'package:flutter/material.dart';

import '../../series/series.dart';

class FragmentSeries extends Series<dynamic> {
  final List<Series> series;

  FragmentSeries(this.series) : super(datas: []);

  @override
  CustomPainter createPainter() {
    // TODO: implement createPainter
    throw UnimplementedError();
  }
}
