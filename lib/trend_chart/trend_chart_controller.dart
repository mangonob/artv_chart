import 'package:flutter/material.dart';

import '../utils/utils.dart';
import 'common/render_params.dart';
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

    final clampedRenderParams = _clampRenderParams(renderParams);

    if (!animated) {
      _paramsAnimation = null;
      _state?.mutateRenderParams((p) => clampedRenderParams);
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
    if (delta != 0) {
      stopAnimation();
      final viewDelta = _state!.widget.physic.applyPhysicsToUserOffset(
        createPosition(),
        -delta,
      );

      _state?.mutateRenderParams((params) {
        return params.copyWith(xOffset: params.xOffset + viewDelta);
      });
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

  void interactive(
    double scale,
    double anchorX,
    double deltaX, {
    bool animated = false,
    Curve curve = Curves.easeOut,
    Duration duration = const Duration(milliseconds: 250),
  }) {
    if (!(_renderParams.unit > 0)) return;
    var oldValue = _renderParams;
    final minUnit = _state!.widget.minUnit;
    final maxUnit = _state!.widget.maxUnit;

    final newUnit =
        (scale * oldValue.unit).safeClamp(minUnit, maxUnit).toDouble();
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
      _state?.updateRenderParams(animatingParams);
    } else if (_isSimulating) {
      _state?.mutateRenderParams(
        (p) => p.copyWith(xOffset: _animationController.value),
      );
    }
  }
}

extension _SafeCalmpingExtension on num {
  num safeClamp(num lowerLimit, num upperLimit) {
    return lowerLimit < upperLimit ? clamp(lowerLimit, upperLimit) : lowerLimit;
  }
}
