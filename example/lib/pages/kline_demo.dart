import 'dart:math';

import 'package:artv_chart/trend_chart/common/enum.dart';
import 'package:artv_chart/trend_chart/common/range.dart';
import 'package:artv_chart/trend_chart/common/style.dart';
import 'package:artv_chart/trend_chart/grid/attachment/trend_chart_attachment.dart';
import 'package:artv_chart/trend_chart/grid/boundary.dart';
import 'package:artv_chart/trend_chart/grid/grid.dart';
import 'package:artv_chart/trend_chart/grid/grid_style.dart';
import 'package:artv_chart/trend_chart/grid/label/chart_label.dart';
import 'package:artv_chart/trend_chart/grid/label/text_label.dart';
import 'package:artv_chart/trend_chart/layout_manager.dart';
import 'package:artv_chart/trend_chart/series/bar_series/bar_series.dart';
import 'package:artv_chart/trend_chart/series/candle_series/candle_entry.dart';
import 'package:artv_chart/trend_chart/series/candle_series/candle_series.dart';
import 'package:artv_chart/trend_chart/series/candle_series/candle_series_style.dart';
import 'package:artv_chart/trend_chart/series/dot_series/dot_series.dart';
import 'package:artv_chart/trend_chart/series/dot_series/dot_series_style.dart';
import 'package:artv_chart/trend_chart/series/line_series/line_series.dart';
import 'package:artv_chart/trend_chart/series/line_series/line_series_style.dart';
import 'package:artv_chart/trend_chart/series/series.dart';
import 'package:artv_chart/trend_chart/trend_chart.dart';
import 'package:artv_chart/trend_chart/trend_chart_controller.dart';
import 'package:artv_chart/utils/utils.dart';
import 'package:example/data_generator.dart';
import 'package:example/utils/list.dart';
import 'package:example/widgets/color_tile.dart';
import 'package:example/widgets/options.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class KLineDemo extends StatefulWidget {
  const KLineDemo({
    Key? key,
  }) : super(key: key);

  @override
  State<KLineDemo> createState() => _KLineDemoState();
}

class _KLineDemoState extends State<KLineDemo>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TrendChartController _controller;
  late LayoutManager _layoutManager;
  late List<double> _offsets;
  late List<double> _dots;
  late List<double> _bars;
  late List<CandleEntry> _candles;
  final int _itemCount = 10000;

  final _dateFormatter = DateFormat("yyyy/MM/dd");

  /// 自定义样式
  bool _isAutoHiddenCrossLine = false;
  bool _isCrossLineFollowUser = true;
  bool _isRaster = false;
  bool _isMainIndexHidden = true;
  CandleType _candleType = CandleType.fill;
  Color _riseColor = Colors.red;
  Color _fallColor = Colors.green;
  Color _crossLineColor = Colors.grey;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _controller = TrendChartController(vsync: this);
    _layoutManager = LayoutManager();
    _offsets = [];
    _dots = [];
    _bars = [];
    _candles = [];

    _controller.addListener(_controllerListener);

    compute(
      _generateOffsets,
      _itemCount,
    ).then((v) {
      setState(() {
        _offsets = v;
      });
    });

    compute(
      _generateOffsets,
      _itemCount,
    ).then((v) {
      setState(() {
        _dots = v.map((e) => e - 3000).toList();
      });
    });

    compute(
      _generateOffsets,
      _itemCount,
    ).then((v) {
      setState(() {
        _bars = v;
      });
    });

    compute(
      _generateCandles,
      _itemCount,
    ).then((v) {
      setState(() {
        _candles = v;
      });
    });
  }

  _controllerListener() {}

  static List<double> _generateOffsets(int count) {
    final generator = DataGenerator.sinable();
    return List.generate(
      count,
      (index) => generator.generate(index).first.toDouble(),
    );
  }

  static List<CandleEntry> _generateCandles(int count) {
    final generator = DataGenerator.sinable();
    final random = Random.secure();
    return List.generate(count, (index) {
      final values = generator.generate(index, count: 4)..sort();

      var openClose = values.getRange(1, 3).toList();
      if (random.nextBool()) openClose = openClose.reversed.toList();

      return CandleEntry(
        open: openClose[0].toDouble(),
        high: values.last.toDouble(),
        lower: values.first.toDouble(),
        close: openClose[1].toDouble(),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _layoutManager.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
      color: Colors.white,
      child: ListView(
        // physics: const ClampingScrollPhysics(),
        children: [
          TrendChart(
            controller: _controller,
            physic: const BouncingScrollPhysics(),
            layoutManager: _layoutManager,
            isIgnoredUnitVolume: false,
            minUnit: 2,
            maxUnit: 40,
            isAutoBlur: _isAutoHiddenCrossLine,
            xOffsetReserveMode: _isRaster ? ReserveMode.ceil : ReserveMode.none,
            crossLineStyle: LineStyle(color: _crossLineColor),
            xRange: Range.length(_itemCount.toDouble()),
            onDoubleTap: () => _controller.resetInitialValue(animated: true),
            grids: [
              Grid(
                ySplitCount: 5,
                style: GridStyle(
                  ratio: 0.8,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  labelStyle:
                      const TextStyle(fontSize: 9, color: Colors.blueGrey),
                ),
                boundaries: [
                  FractionalPaddingBoundary(0.1),
                  AlignBoundary(5 * 10)
                ],
                series: [
                  CandleSeries(
                    candles: _candles,
                    style: CandleSeriesStyle(
                      type: _candleType,
                      riseColor: _riseColor,
                      fallColor: _fallColor,
                    ),
                  ),
                  if (!_isMainIndexHidden)
                    DotSeries(
                      _dots,
                      style: DotSeriesStyle(
                        circleRadius: 2,
                        lineStyle: const LineStyle(color: Colors.blue),
                      ),
                    ),
                  if (!_isMainIndexHidden)
                    LineSeries(
                      _dots,
                      lineSeriesStyle: LineSeriesStyle(
                        lineStyle: const LineStyle(color: Colors.orange),
                      ),
                    ),
                ],
                // xLabel: xLabel,
                yLabel: yLabel,
                yValueForCrossLine: when(
                  !_isCrossLineFollowUser,
                  (_, i) => _candles.maybeElementAt(i)?.close,
                ),
                attachments: [
                  TrendChartAttachment(
                    position: AttachmentPosition.left,
                    contentFn: yAttachmentContent,
                  ),
                  TrendChartAttachment(
                    position: AttachmentPosition.bottom,
                    contentFn: dateAttachmentContent,
                  ),
                ],
              ),
              Grid(
                ySplitCount: 3,
                style: GridStyle(
                  height: 90,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                ),
                boundaries: [FractionalPaddingBoundary(0.1)],
                yValueForCrossLine: when(
                  !_isCrossLineFollowUser,
                  (_, i) => _offsets.maybeElementAt(i),
                ),
                series: [
                  LineSeries(
                    _offsets,
                    lineSeriesStyle: LineSeriesStyle(
                      lineStyle: const LineStyle(color: Colors.blue),
                    ),
                  ),
                  DotSeries(_dots),
                ],
                attachments: [
                  TrendChartAttachment(
                    position: AttachmentPosition.right,
                    contentFn: yAttachmentContent,
                  )
                ],
              ),
              Grid(
                ySplitCount: 1,
                style: GridStyle(
                  height: 70,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                ),
                yValueForCrossLine: when(
                  !_isCrossLineFollowUser,
                  (_, i) => _bars.maybeElementAt(i)?.abs(),
                ),
                boundaries: [AlignBoundary(10)],
                series: [
                  BarSeries(_bars, isAlwaysPositive: true),
                ],
                attachments: [
                  TrendChartAttachment(
                    position: AttachmentPosition.bottom,
                    contentFn: (i, y) => i.toString(),
                  )
                ],
              ),
            ],
          ),
          Container(
            color: Colors.grey[100],
            height: 16,
          ),
          ListTile(
            title: const Text("显示主图指标"),
            trailing: CupertinoSwitch(
                value: !_isMainIndexHidden,
                onChanged: (v) {
                  setState(() {
                    _isMainIndexHidden = !v;
                  });
                }),
          ),
          ListTile(
            title: const Text("十字线自动消失"),
            trailing: CupertinoSwitch(
                value: _isAutoHiddenCrossLine,
                onChanged: (v) {
                  setState(() {
                    _isAutoHiddenCrossLine = v;
                  });
                }),
          ),
          ListTile(
            title: const Text("十字线跟随手势"),
            trailing: CupertinoSwitch(
                value: _isCrossLineFollowUser,
                onChanged: (v) {
                  setState(() {
                    _isCrossLineFollowUser = v;
                  });
                }),
          ),
          ListTile(
            title: const Text("栅格化绘制"),
            trailing: CupertinoSwitch(
                value: _isRaster,
                onChanged: (v) {
                  setState(() {
                    _isRaster = v;
                  });
                }),
          ),
          ListTile(
            title: const Text("线型"),
            trailing: Options<CandleType>(
              value: _candleType,
              values: CandleType.values,
              formatter: (v) => v.description(),
              onValueChagned: (v) {
                setState(() {
                  _candleType = v;
                });
              },
            ),
          ),
          ColorTile(
            title: "上涨",
            value: _riseColor,
            onChanged: (v) {
              setState(() {
                _riseColor = v;
              });
            },
          ),
          ColorTile(
            title: "下跌",
            value: _fallColor,
            onChanged: (v) {
              setState(() {
                _fallColor = v;
              });
            },
          ),
          ColorTile(
            title: "十字线",
            value: _crossLineColor,
            onChanged: (v) {
              setState(() {
                _crossLineColor = v;
              });
            },
          ),
        ],
      ),
    );
  }

  double xValue(Offset offset, int index, Series<Offset> series) {
    return offset.dx;
  }

  double yValue(Offset offset, int index, Series<Offset> series) {
    return offset.dy;
  }

  String? yAttachmentContent(int position, double yValue) {
    return yValue.toStringAsFixed(3);
  }

  String? dateAttachmentContent(int position, double yValue) {
    return _dateFormatter.format(
      DateTime(2022, 1, 1).add(Duration(days: position)),
    );
  }

  ChartLabel? xLabel(int index) {
    if (index % 5 == 0) {
      return TextLabel(index.toStringAsFixed(0));
    }
  }

  ChartLabel? yLabel(double value) {
    return TextLabel(value.toStringAsFixed(2));
  }
}

extension _CanldeTypeDescription on CandleType {
  String description() {
    switch (this) {
      case CandleType.fill:
        return "实心";
      case CandleType.outline:
        return "空心";
      case CandleType.ohlc:
        return "美国线";
    }
  }
}
