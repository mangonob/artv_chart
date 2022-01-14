import 'package:flutter/material.dart';

import '../utils/utils.dart';
import 'common/render_params.dart';
import 'trend_chart.dart';

class TrendChartController extends ChangeNotifier {
  TrendChartState? _state;

  final double initialUnit;
  final double initialPhase;
  late AnimationController _animationController;

  Animation<RenderParams>? _paramsAnimation;

  TrendChartController({
    required TickerProvider vsync,
    this.initialUnit = 10,
    this.initialPhase = 0,
  }) {
    _animationController = AnimationController(vsync: vsync);
    _animationController.addListener(_animationListener);
  }

  void bindState(TrendChartState state) {
    if (state != _state) {
      _state = state;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _state = null;
  }

  static TrendChartController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<TrendChartScope>();
    assert(scope != null, "$TrendChartScope not found.");
    return scope!.controller;
  }

  /// Change phase animated if needed.
  /// [animated] default is false
  void jumpTo(
    double phase, {
    bool animated = false,
    Curve curve = Curves.easeOut,
    Duration duration = const Duration(milliseconds: 250),
  }) {
    if (!animated) {
      _paramsAnimation = null;
      _state?.mutateRenderParams((p) => p.copyWith(phase: phase));
    } else {
      _state?.renderParams.flatMap((oldValue) {
        _paramsAnimation = RenderParamsTween(
                begin: oldValue, end: oldValue.copyWith(phase: phase))
            .animate(
                CurvedAnimation(parent: _animationController, curve: curve));
      });
      _animationController.duration = duration;
      _animationController.forward(from: 0);
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
    if (!animated) {
      _paramsAnimation = null;
      _state?.mutateRenderParams((p) => p.copyWith(unit: unit));
    } else {
      _state?.renderParams.flatMap((oldValue) {
        _paramsAnimation = RenderParamsTween(
                begin: oldValue, end: oldValue.copyWith(unit: unit))
            .animate(
          CurvedAnimation(parent: _animationController, curve: curve),
        );
      });
      _animationController.duration = duration;
      _animationController.forward(from: 0);
    }
  }

  _animationListener() {
    final animatingParams = _paramsAnimation?.value;
    if (animatingParams != null) {
      _state?.updateRenderParams(animatingParams);
    }
  }
}
