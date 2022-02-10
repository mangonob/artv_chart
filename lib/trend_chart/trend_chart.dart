import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../utils/utils.dart';
import 'common/enum.dart';
import 'common/range.dart';
import 'common/render_params.dart';
import 'common/style.dart';
import 'cross_line_info.dart';
import 'grid/grid.dart';
import 'grid/grid_paint.dart';
import 'layout_manager.dart';
import 'trend_chart_controller.dart';
import 'trend_chart_cross_line_painter.dart';

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
  final ScrollPhysics physic;
  final GestureTapCallback? onDoubleTap;
  final double minUnit;
  final double maxUnit;
  final LineStyle _crossLineStyle;

  /// Whether the cross line should been auto hidden after user interacte end;
  final bool isAutoBlur;
  final Duration autoBlurDuration;

  /// Use [GestureDetector.onHorizontalDragUpdate] detecte multi fingers drag,
  /// that maybe cause scale action get no sensitive.
  final bool isAllowHorizontalDrag;

  /// Builder optional header for every grid
  /// [ ------ Header? ------ ]
  /// [ ------  Grid   ------ ]
  /// [ ------ Footer? ------ ]
  ///
  final GridWidgetBuilder? headerBuilder;

  /// Builder optional footer for every grid
  final GridWidgetBuilder? footerBuilder;

  final ValueChanged<int?>? onFocusPositionChanged;

  LineStyle get crossLineStyle => _crossLineStyle;

  TrendChart({
    Key? key,
    required this.controller,
    required this.layoutManager,
    required this.xRange,
    this.grids = const [],
    this.xOffsetReserveMode = ReserveMode.none,
    this.isIgnoredUnitVolume = true,
    this.xPadding = EdgeInsets.zero,
    this.headerBuilder,
    this.footerBuilder,
    this.physic = const BouncingScrollPhysics(),
    this.onDoubleTap,
    this.minUnit = 0,
    this.maxUnit = 30,
    this.isAllowHorizontalDrag = true,
    this.isAutoBlur = false,
    this.autoBlurDuration = const Duration(milliseconds: 1000),
    LineStyle? crossLineStyle,
    this.onFocusPositionChanged,
  })  : assert(minUnit <= maxUnit),
        _crossLineStyle =
            const LineStyle(color: Colors.grey, size: 1).merge(crossLineStyle),
        super(key: key);

  @override
  State<TrendChart> createState() => TrendChartState();
}

class TrendChartState extends State<TrendChart> {
  late RenderParams _renderParams;
  double? _scaleStartUnit;
  final crossLineInfo = ValueNotifier<CrossLineInfo?>(null);

  RenderParams get renderParams => _renderParams;

  void update(
    RenderParams renderParams, {
    ValueChangedWithPrevCallback<RenderParams>? updated,
  }) {
    if (_renderParams != renderParams) {
      final prev = _renderParams;
      setState(() {
        _renderParams = renderParams;
      });
      _valueChangedChecker(prev, _renderParams);
      updated?.call(prev, _renderParams);
    }
  }

  _valueChangedChecker(RenderParams prev, RenderParams curr) {
    final prevPosition = prev.focusPosition;
    final currPosition = curr.focusPosition;

    if (prevPosition != currPosition) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        widget.onFocusPositionChanged?.call(currPosition);
      });
    }
  }

  void mutate(
    Mutator<RenderParams> mutator, {
    ValueChangedWithPrevCallback<RenderParams>? mutated,
  }) =>
      update(mutator(_renderParams), updated: mutated);

  @override
  void initState() {
    super.initState();

    _renderParams = RenderParams(
      unit: widget.controller.initialUnit.clamp(widget.minUnit, widget.maxUnit),
      xOffset: widget.controller.initialXOffset,
      padding: widget.xPadding,
      xOffsetReserveMode: widget.xOffsetReserveMode,
      isIgnoredUnitVolume: widget.isIgnoredUnitVolume,
      xRange: widget.xRange,
      chartWidth: 0,
    );

    widget.controller.bindState(this);
    widget.layoutManager.bindState(this);

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      final box = context.findRenderObject() as RenderBox?;
      if (box != null) {
        mutate((params) => params.copyWith(chartWidth: box.size.width));
      }
    });
  }

  @override
  void didUpdateWidget(covariant TrendChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.isAutoBlur && widget.isAutoBlur) {
      widget.controller.blur();
    }

    mutate((p) => p.copyWith(
          xOffsetReserveMode: widget.xOffsetReserveMode,
          isIgnoredUnitVolume: widget.isIgnoredUnitVolume,
          xRange: widget.xRange,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraints) {
      return RenderParamsScope(
        renderParams: _renderParams,
        child: TrendChartScope(
          controller: widget.controller,
          layoutManager: widget.layoutManager,
          child: RawGestureDetector(
            gestures: _createGestures(ctx),
            child: RepaintBoundary(
              child: Builder(builder: (ctx) => _buildGrids(ctx, constraints)),
            ),
          ),
        ),
      );
    });
  }

  Map<Type, GestureRecognizerFactory> _createGestures(BuildContext context) {
    return {
      LongPressGestureRecognizer:
          GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
        () => LongPressGestureRecognizer(),
        (longPress) {
          longPress.onLongPressStart =
              (d) => widget.controller.updateCrossLine(d.localPosition);
          longPress.onLongPressMoveUpdate =
              (d) => widget.controller.updateCrossLine(d.localPosition);
          longPress.onLongPressEnd = (_) => _blur();
          longPress.onLongPressCancel = () => _blur();
          longPress.onLongPressUp = () => _blur();
        },
      ),
      if (widget.isAllowHorizontalDrag)
        HorizontalDragGestureRecognizer: GestureRecognizerFactoryWithHandlers<
            HorizontalDragGestureRecognizer>(
          () => HorizontalDragGestureRecognizer(),
          (drag) {
            drag.onUpdate = (d) {
              widget.controller.applyOffset(d.delta.dx);
            };
            drag.onEnd = (d) {
              widget.controller.decelerate(d.velocity);
            };
          },
        ),
      ScaleGestureRecognizer:
          GestureRecognizerFactoryWithHandlers<ScaleGestureRecognizer>(
        () => ScaleGestureRecognizer(),
        (scale) {
          scale.onStart = (_) {
            _scaleStartUnit = _renderParams.unit;
          };

          scale.onUpdate = (d) {
            if (d.pointerCount == 1) {
              widget.controller.applyOffset(d.focalPointDelta.dx);
            } else {
              if (_scaleStartUnit != null) {
                widget.controller.interactive(
                  destUnit: d.horizontalScale * _scaleStartUnit!,
                  anchorX: d.localFocalPoint.dx,
                  deltaX: d.focalPointDelta.dx,
                );
              }
            }
          };

          scale.onEnd = (d) {
            _scaleStartUnit = null;
            if (d.pointerCount == 0) {
              widget.controller.decelerate(d.velocity);
            }
          };
        },
      ),
      TapGestureRecognizer:
          GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
        () => TapGestureRecognizer(),
        (tap) {
          tap.onTapDown = (_) => widget.controller.stopAnimation();
          tap.onTap = () => widget.controller.blur(force: true);
        },
      ),
      DoubleTapGestureRecognizer:
          GestureRecognizerFactoryWithHandlers<DoubleTapGestureRecognizer>(
        () => DoubleTapGestureRecognizer(),
        (doubleTap) {
          doubleTap.onDoubleTap = widget.onDoubleTap;
        },
      ),
    };
  }

  Widget _buildGrids(BuildContext context, BoxConstraints constraints) {
    if (widget.grids.isEmpty) {
      return const SizedBox();
    } else {
      return ValueListenableBuilder<CrossLineInfo?>(
        valueListenable: crossLineInfo,
        builder: (ctx, value, child) {
          return CustomPaint(
            child: child,
            foregroundPainter: createCrossLinePainter(),
          );
        },
        child: Column(
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
        ),
      );
    }
  }

  CustomPainter createCrossLinePainter() => TrendChartCrossLinePainter(
        chart: widget,
        renderParams: renderParams,
        info: crossLineInfo.value,
      );

  void _blur({
    bool force = false,
  }) =>
      widget.controller.blur(force: force);
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
