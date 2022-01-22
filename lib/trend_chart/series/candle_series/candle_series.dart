import '../../common/range.dart';
import 'package:flutter/material.dart';

import '../../common/render_params.dart';
import '../../grid/grid.dart';
import '../series.dart';
import 'candle_entry.dart';
import 'candle_series_painter.dart';
import 'candle_series_style.dart';

class CandleSeries extends Series<CandleEntry> {
  final CandleSeriesStyle _style;

  CandleSeriesStyle get style => _style;

  CandleSeries({
    required List<CandleEntry> candles,
    ValueConvertor<CandleEntry>? yValue,
    CandleSeriesStyle? style,
  })  : _style = CandleSeriesStyle().merge(style),
        super(
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
  Range yRange(Range xRange) {
    final datas = datasInXRange(xRange);
    return datas.item1.fold(
      const Range.empty(),
      (range, candle) => range.union(candle.range),
    );
  }

  @override
  operator ==(Object other) =>
      identical(this, other) ||
      other is CandleSeries && _style == other._style && super == other;

  @override
  int get hashCode => hashValues(
        super.hashCode,
        _style,
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
