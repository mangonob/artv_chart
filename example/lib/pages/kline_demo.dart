import 'dart:async';
import 'dart:isolate';
import 'dart:math';

import 'package:artv_chart/trend_chart/common/range.dart';
import 'package:artv_chart/trend_chart/grid/boundary.dart';
import 'package:artv_chart/trend_chart/grid/grid.dart';
import 'package:artv_chart/trend_chart/grid/grid_style.dart';
import 'package:artv_chart/trend_chart/grid/label/chart_label.dart';
import 'package:artv_chart/trend_chart/grid/label/text_label.dart';
import 'package:artv_chart/trend_chart/layout_manager.dart';
import 'package:artv_chart/trend_chart/series/candle_series/candle_entry.dart';
import 'package:artv_chart/trend_chart/series/candle_series/candle_series.dart';
import 'package:artv_chart/trend_chart/series/candle_series/candle_series_style.dart';
import 'package:artv_chart/trend_chart/series/series.dart';
import 'package:artv_chart/trend_chart/trend_chart.dart';
import 'package:artv_chart/trend_chart/trend_chart_controller.dart';
import 'package:example/widgets/color_tile.dart';
import 'package:example/widgets/options.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

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
  late List<Offset> _offsets;
  late List<CandleEntry> _candles;
  late ReceivePort _dataPort;
  final int _itemCount = 10000;
  late StreamSubscription _portSubscription;

  /// 自定义样式
  bool _isAutoHiddenCrossLine = false;
  CandleType _candleType = CandleType.fill;
  Color _riseColor = Colors.red;
  Color _fallColor = Colors.green;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _controller = TrendChartController(vsync: this);
    _layoutManager = LayoutManager();
    _offsets = [];
    _candles = [];

    _dataPort = ReceivePort();
    Isolate.spawn(
      _generateTestData,
      Tuple2<SendPort, int>(_dataPort.sendPort, _itemCount),
    );

    _portSubscription = _dataPort.listen((message) {
      if (message is Tuple2<List<Offset>, List<CandleEntry>>) {
        setState(() {
          _offsets = message.item1;
          _candles = message.item2;
        });
      }
    });
  }

  @override
  void dispose() {
    _portSubscription.cancel();
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
        // physics: const NeverScrollableScrollPhysics(),
        children: [
          TrendChart(
            controller: _controller,
            layoutManager: _layoutManager,
            isIgnoredUnitVolume: false,
            minUnit: 2,
            maxUnit: 40,
            xRange: Range.length(_itemCount.toDouble()),
            onDoubleTap: () => _controller.resetInitialValue(animated: true),
            grids: [
              Grid(
                ySplitCount: 5,
                style: GridStyle(
                  ratio: 0.8,
                  margin: const EdgeInsets.all(10).copyWith(bottom: 20),
                  labelStyle: const TextStyle(color: Colors.blue),
                ),
                boundaries: [AlignBoundary(5 * 10)],
                series: [
                  CandleSeries(
                    candles: _candles,
                    style: CandleSeriesStyle(
                      type: _candleType,
                      riseColor: _riseColor,
                      fallColor: _fallColor,
                    ),
                  ),
                ],
                // xLabel: xLabel,
                yLabel: yLabel,
              ),
              // Grid(
              //   style: GridStyle(
              //     height: 100,
              //     decoration: BoxDecoration(
              //       border: Border.all(
              //           color: Colors.grey[200] ?? Colors.grey, width: 1),
              //     ),
              //   ),
              // ),
            ],
          ),
          Container(
            color: Colors.grey[100],
            height: 16,
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

  ChartLabel? xLabel(int index) {
    if (index % 5 == 0) {
      return TextLabel(index.toStringAsFixed(0));
    }
  }

  ChartLabel? yLabel(double value) {
    return TextLabel(value.toStringAsFixed(2));
  }
}

void _generateTestData(Tuple2<SendPort, int> portAndCount) {
  final count = portAndCount.item2;
  final port = portAndCount.item1;

  /// Generate test data;
  final random = Random.secure();

  final offsets = List.generate(count, (idx) {
    final value = random.nextDouble() * 10 * idx + 100;
    return Offset(idx.toDouble(), value.toDouble());
  });

  final candels = List.generate(count, (idx) {
    final value = random.nextDouble() * 10 * idx + 100;
    double range = 100;
    final values =
        List.generate(4, (_) => value + random.nextDouble() * range - range / 2)
          ..sort();
    var openClose = values.getRange(1, 3).toList();
    if (random.nextBool()) openClose = openClose.reversed.toList();

    return CandleEntry(
      open: openClose[0],
      high: values.last,
      lower: values.first,
      close: openClose[1],
    );
  });

  port.send(Tuple2<List<Offset>, List<CandleEntry>>(offsets, candels));
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
