import 'package:artv_chart/trend_chart/grid/grid.dart';
import 'package:artv_chart/trend_chart/grid/grid_style.dart';
import 'package:artv_chart/trend_chart/layout_manager.dart';
import 'package:artv_chart/trend_chart/series/line_series/line_series.dart';
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

  @override
  void initState() {
    super.initState();

    _controller = TrendChartController(vsync: this);
    _layoutManager = LayoutManager();
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
          children: [
            Container(
              color: Colors.grey[200],
              child: TrendChart(
                controller: _controller,
                layoutManager: _layoutManager,
                grids: [
                  Grid(
                    style: const GridStyle(ratio: 0.8),
                    series: [
                      LineSeries(
                        [
                          const Offset(1, 0),
                          const Offset(2, 4),
                          const Offset(3, 42),
                          const Offset(4, 3),
                          const Offset(5, -10),
                          const Offset(6, 20),
                        ],
                      ),
                    ],
                  ),
                  Grid(
                    style: const GridStyle(height: 100),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
