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
    this.initialUnit = 20,
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
    stopAnimation();
    if (!animated) {
      _paramsAnimation = null;
      _state?.mutateRenderParams((p) => p.copyWith(xOffset: xOffset));
    } else {
      _state?.renderParams.flatMap((oldValue) {
        _paramsAnimation = RenderParamsTween(
          begin: oldValue,
          end: oldValue.copyWith(xOffset: xOffset),
        ).animate(_animationController);
      });
      _animationController.value = 0;
      _animationController
          .animateTo(1, curve: curve, duration: duration)
          .whenCompleteOrCancel(() {
        _paramsAnimation = null;
      });
    }
  }

  /// Change unit animated if needed.
  /// [animated] deefault is false
  void scaleTo(
    double unit, {
    bool animated = false,
    Curve curve = Curves.easeOut,
    Duration duration = const Duration(milliseconds: 250),
  }) {
    stopAnimation();
    if (!animated) {
      _paramsAnimation = null;
      _state?.mutateRenderParams((p) => p.copyWith(unit: unit));
    } else {
      _paramsAnimation = RenderParamsTween(
        begin: _renderParams,
        end: _renderParams.copyWith(unit: unit),
      ).animate(_animationController);

      _animationController.value = 0;
      _animationController
          .animateTo(1, curve: curve, duration: duration)
          .whenCompleteOrCancel(() {
        _paramsAnimation = null;
      });
    }
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
