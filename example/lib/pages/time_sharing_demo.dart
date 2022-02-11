import 'package:artv_chart/trend_chart/common/range.dart';
import 'package:artv_chart/trend_chart/common/style.dart';
import 'package:artv_chart/trend_chart/grid/boundary.dart';
import 'package:artv_chart/trend_chart/grid/grid.dart';
import 'package:artv_chart/trend_chart/grid/grid_style.dart';
import 'package:artv_chart/trend_chart/grid/label/chart_label.dart';
import 'package:artv_chart/trend_chart/grid/label/text_label.dart';
import 'package:artv_chart/trend_chart/layout_manager.dart';
import 'package:artv_chart/trend_chart/series/line_series/line_series.dart';
import 'package:artv_chart/trend_chart/series/line_series/line_series_style.dart';
import 'package:artv_chart/trend_chart/series/series.dart';
import 'package:artv_chart/trend_chart/trend_chart.dart';
import 'package:artv_chart/trend_chart/trend_chart_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../data_generator.dart';

class TimeSharingDemo extends StatefulWidget {
  const TimeSharingDemo({
    Key? key,
  }) : super(key: key);

  @override
  State<TimeSharingDemo> createState() => _TimeSharingDemoState();
}

class _TimeSharingDemoState extends State<TimeSharingDemo>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TrendChartController _controller;
  late LayoutManager _layoutManager;
  late List<double> _offsets;
  final int _itemCount = 500;

  bool _isAutoHiddenCrossLine = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _controller = TrendChartController(vsync: this, initialUnit: 0.8);
    _layoutManager = LayoutManager();
    _offsets = [];

    compute(
      _generateOffsets,
      _itemCount,
    ).then((v) {
      setState(() {
        _offsets = v;
      });
    });
  }

  static List<double> _generateOffsets(int count) {
    final generator = DataGenerator.sinable();
    return List.generate(
      count,
      (index) => generator.generate(index).first.toDouble(),
    );
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
        // physics: const NeverScrollableScrollPhysics(),
        children: [
          LayoutBuilder(builder: _buildChart),
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
        ],
      ),
    );
  }

  Widget _buildChart(BuildContext context, BoxConstraints constraints) {
    return TrendChart(
      physic: const ClampingScrollPhysics(),
      controller: _controller,
      layoutManager: _layoutManager,
      isIgnoredUnitVolume: false,
      minUnit: constraints.maxWidth / _itemCount,
      maxUnit: constraints.maxWidth / _itemCount,
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
            LineSeries(
              _offsets,
              lineSeriesStyle: LineSeriesStyle(
                lineStyle: const LineStyle(color: Colors.blue),
                paintingStyle: PaintingStyle.fill,
                gradientColors: [Colors.blue, Colors.blue.withAlpha(0)],
              ),
            ),
            // BarSeries(_offsets),
            // DotSeries(_offsets),
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
