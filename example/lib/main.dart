import 'dart:math';

import 'package:artv_chart/trend_chart/common/range.dart';
import 'package:artv_chart/trend_chart/grid/boundary.dart';
import 'package:artv_chart/trend_chart/grid/grid.dart';
import 'package:artv_chart/trend_chart/grid/grid_style.dart';
import 'package:artv_chart/trend_chart/grid/label/chart_label.dart';
import 'package:artv_chart/trend_chart/grid/label/text_label.dart';
import 'package:artv_chart/trend_chart/layout_manager.dart';
import 'package:artv_chart/trend_chart/series/line_series/line_series.dart';
import 'package:artv_chart/trend_chart/series/series.dart';
import 'package:artv_chart/trend_chart/trend_chart.dart';
import 'package:artv_chart/trend_chart/trend_chart_controller.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Chart Demo',
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late TrendChartController _controller;
  late LayoutManager _layoutManager;
  late List<Offset> _offsets;

  @override
  void initState() {
    super.initState();

    _controller = TrendChartController(vsync: this);
    _layoutManager = LayoutManager();
    _offsets = List.generate(1000, (idx) {
      final value = Random.secure().nextDouble() * 100 - 30;
      return Offset(idx.toDouble(), value.toDouble());
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
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 44,
        title: const Text("Chart Demo"),
      ),
      body: Container(
        color: Colors.white,
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            GestureDetector(
              onDoubleTap: () {
                _controller.jumpTo(0, animated: true);
              },
              child: TrendChart(
                controller: _controller,
                layoutManager: _layoutManager,
                isIgnoredUnitVolume: false,
                xRange: const Range(0, 1000),
                grids: [
                  Grid(
                    ySplitCount: 10,
                    style: GridStyle(
                      ratio: 0.8,
                      margin: const EdgeInsets.all(10).copyWith(bottom: 20),
                    ),
                    boundaries: [AlignBoundary(10 * 0.05)],
                    series: [
                      LineSeries(
                        _offsets,
                        xValue: xValue,
                        yValue: yValue,
                      ),
                    ],
                    xLabel: xLabel,
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
            ),
          ],
        ),
      ),
    );
  }

  double xValue(Offset offset, int index, Series<Offset> series) {
    return offset.dx;
  }

  double yValue(Offset offset, int index, Series<Offset> series) {
    return offset.dy;
  }

  ChartLabel? xLabel(double value) {
    return TextLabel(value.toStringAsFixed(0));
  }

  ChartLabel? yLabel(double value) {
    return TextLabel(value.toStringAsFixed(2));
  }
}
