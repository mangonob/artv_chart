import 'package:artv_chart/trend_chart/grid/grid_paint.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../utils/utils.dart';
import 'common/enum.dart';
import 'common/range.dart';
import 'common/render_params.dart';
import 'grid/grid.dart';
import 'layout_manager.dart';
import 'trend_chart_controller.dart';

typedef GridWidgetBuilder = Widget? Function(
    BuildContext context, Grid grid, int index);

class TrendChart extends StatefulWidget {
  final TrendChartController controller;
  final LayoutManager layoutManager;
  final Range xRange;
  final List<Grid> grids;
  final ReserveMode xOffsetReserveMode;
  final bool isIgnoredUnitVolume;
  final EdgeInsets padding;

  /// Builder optional header for every grid
  /// [ ------ Header? ------ ]
  /// [ ------  Grid   ------ ]
  /// [ ------ Footer? ------ ]
  ///
  final GridWidgetBuilder? headerBuilder;

  /// Builder optional footer for every grid
  final GridWidgetBuilder? footerBuilder;

  const TrendChart({
    Key? key,
    required this.controller,
    required this.layoutManager,
    required this.xRange,
    this.grids = const [],
    this.xOffsetReserveMode = ReserveMode.none,
    this.isIgnoredUnitVolume = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 0),
    this.headerBuilder,
    this.footerBuilder,
  }) : super(key: key);

  @override
  State<TrendChart> createState() => TrendChartState();
}

class TrendChartState extends State<TrendChart> {
  late RenderParams _renderParams;

  void updateRenderParams(RenderParams renderParams) {
    setState(() {
      _renderParams = renderParams;
    });
  }

  void mutateRenderParams(Mutator<RenderParams> mutator) {
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
      xOffset: widget.controller.initialXOffset,
      padding: widget.padding,
      xOffsetReserveMode: widget.xOffsetReserveMode,
      isIgnoredUnitVolume: widget.isIgnoredUnitVolume,
      xRange: widget.xRange,
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
    return LayoutBuilder(builder: (ctx, constraints) {
      return RenderParamsScope(
        renderParams: _renderParams,
        child: TrendChartScope(
          controller: widget.controller,
          layoutManager: widget.layoutManager,
          child: GestureDetector(
            onPanUpdate: (d) {
              widget.controller.jumpTo(
                _renderParams.xOffset - d.delta.dx,
              );
            },
            child: RepaintBoundary(
              child: Builder(builder: (ctx) {
                return _buildGrids(ctx, constraints);
              }),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildGrids(BuildContext context, BoxConstraints constraints) {
    if (widget.grids.isEmpty) {
      return const SizedBox();
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: widget.grids.mapIndexed((index, g) {
          final header = widget.headerBuilder?.call(context, g, index);
          final footer = widget.footerBuilder?.call(context, g, index);

          return [
            if (header != null) header,
            SizedBox(
              height: widget.layoutManager.heightForGrid(g, constraints),
              child: GridPaint(grid: g),
            ),
            if (footer != null) footer,
          ];
        }).reduce((acc, v) => acc + v),
      );
    }
  }
}

class TrendChartScope extends InheritedWidget {
  final TrendChartController controller;
  final LayoutManager layoutManager;

  const TrendChartScope({
    Key? key,
    required Widget child,
    required this.controller,
    required this.layoutManager,
  }) : super(
          key: key,
          child: child,
        );

  _changed<T>(T a, T b) {
    return a != b;
  }

  @override
  bool updateShouldNotify(covariant TrendChartScope oldWidget) {
    return _changed(oldWidget.controller, controller) ||
        _changed(oldWidget.layoutManager, layoutManager);
  }
}
