import 'package:artv_chart/trend_chart/series/candle_series/candle_series_painter.dart';
import 'package:artv_chart/trend_chart/series/candle_series/candle_series_style.dart';
import 'package:flutter/material.dart';

import '../../common/render_params.dart';
import '../../grid/grid.dart';
import '../series.dart';
import 'candle_entry.dart';

class CandleSeries extends Series<CandleEntry> {
  final CandleSeriesStyle style;

  CandleSeries({
    required List<CandleEntry> candles,
    ValueConvertor<CandleEntry>? yValue,
    this.style = const CandleSeriesStyle(),
  }) : super(
          datas: candles,
          yValue: yValue ?? _DefaultCandleSeriesConvertor._defaultCandleYValue,
        );

  @override
  CustomPainter createPainter(
    RenderParams renderParams, {
    required Grid grid,
  }) =>
      CandleSeriesPainter(
        series: this,
        grid: grid,
        renderParams: renderParams,
      );

  @override
  operator ==(Object other) =>
      identical(this, other) ||
      other is CandleSeries && style == other.style && super == other;

  @override
  int get hashCode => hashValues(
        super.hashCode,
        style,
      );
}

class _DefaultCandleSeriesConvertor {
  static double _defaultCandleYValue(
    CandleEntry offset,
    int index,
    Series<CandleEntry> series,
  ) {
    return offset.close ?? 0;
  }
}
