import 'package:flutter/material.dart';

import '../utils/utils.dart';
import 'common/render_params.dart';
import 'layout_manager.dart';
import 'trend_chart_controller.dart';

class TrendChart extends StatefulWidget {
  final TrendChartController controller;
  final LayoutManager layoutManager;

  const TrendChart({
    Key? key,
    required this.controller,
    required this.layoutManager,
  }) : super(key: key);

  @override
  State<TrendChart> createState() => TrendChartState();
}

class TrendChartState extends State<TrendChart> {
  late RenderParams _renderParams;

  updateRenderParams(RenderParams renderParams) {
    setState(() {
      _renderParams = renderParams;
    });
  }

  mutateRenderParams(Mutator<RenderParams> mutator) {
    final newValue = mutator(_renderParams);
    if (newValue != _renderParams) {
      updateRenderParams(newValue);
    }
  }

  RenderParams get renderParams => _renderParams;

  @override
  void initState() {
    super.initState();

    _renderParams = RenderParams(
      unit: widget.controller.initialUnit,
      phase: widget.controller.initialPhase,
    );

    widget.controller.bindState(this);
    widget.layoutManager.bindState(this);
    widget.controller.addListener(_controllerListener);
    widget.layoutManager.addListener(_managerListener);
  }

  _managerListener() {}

  _controllerListener() {}

  @override
  void didUpdateWidget(covariant TrendChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    assert(
      widget.controller == oldWidget.controller,
      "can not chagne controller",
    );

    assert(
      widget.layoutManager == oldWidget.layoutManager,
      "con not change layoutManager",
    );
  }

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}
