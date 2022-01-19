import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../utils/utils.dart';
import 'common/enum.dart';
import 'common/range.dart';
import 'common/render_params.dart';
import 'grid/grid.dart';
import 'grid/grid_paint.dart';
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
  final EdgeInsets xPadding;
  final EdgeInsets padding;
  final ScrollPhysics physic;
  final GestureTapCallback? onDoubleTap;

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
    this.xPadding = EdgeInsets.zero,
    this.padding = EdgeInsets.zero,
    this.headerBuilder,
    this.footerBuilder,
    this.physic = const BouncingScrollPhysics(),
    this.onDoubleTap,
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
      padding: widget.xPadding,
      xOffsetReserveMode: widget.xOffsetReserveMode,
      isIgnoredUnitVolume: widget.isIgnoredUnitVolume,
      xRange: widget.xRange,
      chartWidth: 0,
    );

    widget.controller.bindState(this);
    widget.layoutManager.bindState(this);
    widget.controller.addListener(_controllerListener);
    widget.layoutManager.addListener(_managerListener);

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      final box = context.findRenderObject() as RenderBox?;
      if (box != null) {
        mutateRenderParams(
            (params) => params.copyWith(chartWidth: box.size.width));
      }
    });
  }

  _managerListener() {}

  _controllerListener() {}

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: LayoutBuilder(builder: (ctx, constraints) {
        return RenderParamsScope(
          renderParams:
              _renderParams.copyWith(chartWidth: constraints.maxWidth),
          child: TrendChartScope(
            controller: widget.controller,
            layoutManager: widget.layoutManager,
            child: GestureDetector(
              onScaleUpdate: (d) {
                if (d.pointerCount == 1) {
                  widget.controller.applyOffset(d.focalPointDelta.dx);
                }
              },
              onScaleEnd: (d) {
                if (d.pointerCount == 0) {
                  widget.controller.decelerate(d.velocity);
                }
              },
              onTapDown: (_) => widget.controller.stopAnimation(),
              onDoubleTap: widget.onDoubleTap,
              child: RepaintBoundary(
                child: Builder(builder: (ctx) {
                  return _buildGrids(ctx, constraints);
                }),
              ),
            ),
          ),
        );
      }),
    );
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

  _changed<T>(T a, T b) => a != b;

  @override
  bool updateShouldNotify(covariant TrendChartScope oldWidget) {
    return _changed(oldWidget.controller, controller) ||
        _changed(oldWidget.layoutManager, layoutManager);
  }
}
