import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../utils/utils.dart';
import 'chart_coordinator.dart';
import 'common/render_params.dart';
import 'grid/grid_painter.dart';
import 'trend_chart.dart';

class TrendChartController extends ChangeNotifier {
  TrendChartState? _state;

  final double initialUnit;
  final double initialXOffset;
  late AnimationController _animationController;
  bool _isSimulating = false;

  Animation<RenderParams>? _paramsAnimation;

  RenderParams get _renderParams => _state!.renderParams;

  TrendChartController({
    required TickerProvider vsync,
    this.initialUnit = 8,
    this.initialXOffset = 0,
  }) {
    _animationController = AnimationController.unbounded(vsync: vsync);
    _animationController.addListener(_animationListener);
  }

  void bindState(TrendChartState state) {
    if (state != _state) {
      _state = state;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _state = null;
    super.dispose();
  }

  static TrendChartController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<TrendChartScope>();
    assert(scope != null, "$TrendChartScope not found.");
    return scope!.controller;
  }

  /// Stop current animation performing and keep current [RenderParams] value.
  stopAnimation() {
    if (_animationController.isAnimating) _animationController.stop();
  }

  /// Change xOffset animated if needed.
  /// [animated] default is false
  void jumpTo(
    double xOffset, {
    bool animated = false,
    Curve curve = Curves.easeOut,
    Duration duration = const Duration(milliseconds: 250),
  }) {
    setRenderParams(
      _renderParams.copyWith(
        xOffset: xOffset
            .safeClamp(
              _renderParams.minExtend,
              _renderParams.maxExtend,
            )
            .toDouble(),
      ),
      animated: animated,
      curve: curve,
      duration: duration,
    );
  }

  void setRenderParams(
    RenderParams renderParams, {
    bool animated = false,
    Curve curve = Curves.easeOut,
    Duration duration = const Duration(milliseconds: 250),
  }) {
    stopAnimation();
    _interactiveStart();

    final clampedRenderParams = _clampRenderParams(renderParams);

    if (!animated) {
      _paramsAnimation = null;
      _mutate((p) => clampedRenderParams);
    } else {
      _paramsAnimation = RenderParamsTween(
        begin: _renderParams,
        end: _clampRenderParams(clampedRenderParams),
      ).animate(_animationController);
      _animationController.value = 0;
      _animationController
          .animateTo(1, curve: curve, duration: duration)
          .whenCompleteOrCancel(() {
        _paramsAnimation = null;
      });
    }
  }

  /// Reset unit and xOffset to initial config (animated if needed).
  void resetInitialValue({
    bool animated = false,
    Curve curve = Curves.easeOut,
    Duration duration = const Duration(milliseconds: 250),
  }) {
    setRenderParams(
      _renderParams.copyWith(
        unit: initialUnit,
        xOffset: initialXOffset,
      ),
      animated: animated,
      curve: curve,
      duration: duration,
    );
  }

  /// Create correct [RenderParams] clamps to bounds.
  RenderParams _clampRenderParams(RenderParams renderParams) {
    final minUnit = _state!.widget.minUnit;
    final maxUnit = _state!.widget.maxUnit;

    final clampUnit = renderParams.copyWith(
      unit: renderParams.unit.safeClamp(minUnit, maxUnit).toDouble(),
    );

    final minExtend = clampUnit.minExtend;
    final maxExtend = clampUnit.maxExtend;

    return clampUnit.copyWith(
      xOffset: clampUnit.xOffset.safeClamp(minExtend, maxExtend).toDouble(),
    );
  }

  /// Change unit animated if needed.
  /// [animated] deefault is false
  void scaleTo(
    double unit, {
    bool animated = false,
    Curve curve = Curves.easeOut,
    Duration duration = const Duration(milliseconds: 250),
  }) {
    setRenderParams(
      _renderParams.copyWith(
        unit: unit
            .safeClamp(
              _state!.widget.minUnit,
              _state!.widget.maxUnit,
            )
            .toDouble(),
      ),
      animated: animated,
      curve: curve,
      duration: duration,
    );
  }

  ScrollMetrics createPosition() {
    return FixedScrollMetrics(
      minScrollExtent: _renderParams.minExtend,
      maxScrollExtent: _renderParams.maxExtend,
      pixels: _renderParams.xOffset,
      viewportDimension: _renderParams.chartWidth,
      axisDirection: AxisDirection.right,
    );
  }

  void applyOffset(double delta) {
    _interactiveStart();

    if (delta != 0) {
      stopAnimation();
      final viewDelta = _state!.widget.physic.applyPhysicsToUserOffset(
        createPosition(),
        -delta,
      );

      _mutate((p) => p.copyWith(xOffset: p.xOffset + viewDelta));
    }
  }

  /// Declearing animation when user swap gesture end.
  /// Initial velocity of declerating [velocity]
  /// Animation will not perform when horizontal velocity (pixel/s) less then [threshold]
  void decelerate(
    Velocity velocity,
  ) {
    final simulation = _state!.widget.physic.createBallisticSimulation(
      createPosition(),
      -velocity.pixelsPerSecond.dx,
    );

    simulation.flatMap((simu) {
      stopAnimation();
      _isSimulating = true;
      _animationController.animateWith(simu).whenCompleteOrCancel(() {
        _isSimulating = false;
      });
    });
  }

  void interactive({
    double? destUnit,
    double? scale,
    required double anchorX,
    required double deltaX,
    bool animated = false,
    Curve curve = Curves.easeOut,
    Duration duration = const Duration(milliseconds: 250),
  }) {
    _interactiveStart();

    if (!(_renderParams.unit > 0)) return;
    assert(destUnit != null || scale != null);

    var oldValue = _renderParams;
    final minUnit = _state!.widget.minUnit;
    final maxUnit = _state!.widget.maxUnit;

    final newUnit = (destUnit ?? scale! * oldValue.unit)
        .safeClamp(minUnit, maxUnit)
        .toDouble();
    final clampedScale = newUnit / oldValue.unit;
    if (clampedScale.isInfinite || clampedScale.isNaN) return;

    final origin = oldValue.xOffset;
    final x = anchorX - deltaX;
    final newOffset = clampedScale * (origin + x) - x - deltaX;

    oldValue = oldValue.copyWith(
      unit: newUnit,
      xOffset: newOffset,
    );

    setRenderParams(
      oldValue,
      animated: animated,
      curve: curve,
      duration: duration,
    );
  }

  _animationListener() {
    final animatingParams = _paramsAnimation?.value;

    if (animatingParams != null) {
      _update(renderParams: animatingParams);
    } else if (_isSimulating) {
      _mutate((p) => p.copyWith(xOffset: _animationController.value));
    }
  }

  void updateCrossLine(Offset position) {
    if (_state == null || !_state!.mounted) return;
    final context = _state!.context;

    final box = context.findRenderObject() as RenderBox?;
    if (box != null) {
      final result = BoxHitTestResult();
      box.hitTest(result, position: position);
      final maybePaint = result.path.map((e) => e.target).firstWhereOrNull(
            (t) => t is RenderCustomPaint && t.painter is GridPainter,
          ) as RenderCustomPaint?;
      final gridPainter = maybePaint?.painter as GridPainter?;
      final activeGrid = gridPainter?.grid;

      /// User location in grid
      if (gridPainter != null && activeGrid != null) {
        final focusPosition =
            gridPainter.convertPointToGrid(Offset(position.dx, 0)).dx;
        final focusLocation = Offset(
          gridPainter
              .convertPointFromGrid(Offset(focusPosition.roundToDouble(), 0))
              .dx,
          position.dy,
        );
        _mutate((p) => p.copyWith(focusPosition: focusPosition));
        _update(focusLocation: focusLocation);
      } else {
        /// User location out of grid
        final coordinator = ChartCoordinator(
          grid: _state!.widget.grids.first,
          size: Size(box.size.width, 1),
          renderParams: _renderParams,
        );
        final focusPosition =
            coordinator.convertPointToGrid(Offset(position.dx, 0)).dx;
        final focusLocation = Offset(
          coordinator
              .convertPointFromGrid(Offset(focusPosition.roundToDouble(), 0))
              .dx,
          double.nan,
        );
        _mutate(
          (p) => p.copyWith(focusPosition: focusPosition),
        );
        _update(focusLocation: focusLocation);
      }
    }
  }

  void blur({
    bool force = false,
  }) {
    if (force) {
      _blur();
    } else if (_state?.widget.isAutoBlur ?? false) {
      Future.delayed(_state!.widget.autoBlurDuration).then((_) {
        _state.flatMap((s) {
          if (s.widget.isAutoBlur) _blur();
        });
      });
    }
  }

  void _blur() {
    if (_state != null && _state!.mounted) {
      _mutate((p) => p.copyWith(focusPosition: double.nan));
      _unfocus();
    }
  }

  void _interactiveStart() => _blur();

  void _update({
    RenderParams? renderParams,
    Offset? focusLocation,
  }) =>
      _state.flatMap((s) {
        s.update(renderParams: renderParams, focusLocation: focusLocation);
        notifyListeners();
      });

  void _mutate(Mutator<RenderParams> mutator) => _state.flatMap((s) {
        s.mutateRenderParams(mutator);
        notifyListeners();
      });

  void _unfocus() => _state.flatMap((s) {
        s.focusLocation = null;
        notifyListeners();
      });
}

extension _SafeCalmpingExtension on num {
  num safeClamp(num lowerLimit, num upperLimit) {
    return lowerLimit < upperLimit ? clamp(lowerLimit, upperLimit) : lowerLimit;
  }
}
