import 'package:example/pages/kline_demo.dart';
import 'package:example/pages/time_sharing_demo.dart';
import 'package:flutter/cupertino.dart';
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

enum KLineType {
  kLine,
  timeSharing,
}

extension KLineTypeDescriptionExtension on KLineType {
  String description() {
    switch (this) {
      case KLineType.kLine:
        return "K线";
      case KLineType.timeSharing:
        return "分时";
    }
  }
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_tabListener);
  }

  void _tabListener() {
    setState(() {
      _currentIndex = _tabController.index;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 44,
        title: CupertinoSegmentedControl<int>(
          selectedColor: Colors.white,
          unselectedColor: Colors.blue,
          borderColor: Colors.white,
          groupValue: _currentIndex,
          children: {
            for (var v in KLineType.values)
              v.index: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(v.description()),
              ),
          },
          onValueChanged: (v) {
            setState(() {
              _currentIndex = v;
            });
            _tabController.index = v;
          },
        ),
      ),
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: const [
          KLineDemo(),
          TimeSharingDemo(),
        ],
      ),
    );
  }
}
