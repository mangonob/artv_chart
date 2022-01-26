import 'package:artv_chart/trend_chart/common/render_params.dart';
import 'package:artv_chart/trend_chart/grid/grid.dart';
import 'package:flutter/material.dart';

import '../series.dart';
import 'dot_series_painter.dart';
import 'dot_series_style.dart';

typedef ColorConvertor<T> = Color Function(T);

class DotSeries extends Series<Offset> {
  final DotSeriesStyle _style;
  final ColorConvertor<Offset> _color;

  DotSeries(
    List<Offset> datas, {
    DotSeriesStyle? lineSeriesStyle,
    ValueConvertor<Offset>? yValue,
    ColorConvertor<Offset>? color,
  })  : _style = DotSeriesStyle().merge(lineSeriesStyle),
        _color = color ??
            _DefaultDotSeriesColorConvertorConvertor
                ._defaultDotSeriesColorConvertor,
        super(
          datas: datas,
          yValue: yValue ??
              _DefaultDotSeriesYValueConvertor._defaultDotSeriesYValue,
        );

  DotSeriesStyle get style => _style;

  ColorConvertor<Offset> get color => _color;

  // @override
  // CustomPainter createPainter(RenderParams renderParams, ) =>
  @override
  CustomPainter createPainter(
    RenderParams renderParams, {
    required Grid grid,
  }) =>
      DotSeriesPainter(
        series: this,
        renderParams: renderParams,
        grid: grid,
      );
}

class _DefaultDotSeriesYValueConvertor {
  static double _defaultDotSeriesYValue(
    Offset offset,
    int index,
    Series<Offset> series,
  ) {
    return offset.dy;
  }
}

class _DefaultDotSeriesColorConvertorConvertor {
  static Color _defaultDotSeriesColorConvertor(Offset offset) {
    return Colors.green;
  }
}
