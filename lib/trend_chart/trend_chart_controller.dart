import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../utils/utils.dart';
import 'common/render_params.dart';
import 'constant.dart';
import 'cross_line_info.dart';
import 'grid/grid_painter.dart';
import 'trend_chart.dart';

class TrendChartController extends ChangeNotifier {
  TrendChartState? _state;

  final double initialUnit;
  final double initialXOffset;
  late AnimationController _animationController;
  bool _isSimulating = false;
  int _focusIndex = 0;

  Animation<RenderParams>? _paramsAnimation;

  RenderParams get _renderParams => _state!.renderParams;

  RenderParams get currentRenderParams => _renderParams;

  /// Whether the controller bind to a [TrendChartState].
  bool get hasClient => _state != null;

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

  void _ensureHasClient() {
    assert(hasClient, "$runtimeType has not client.");
  }

  void setRenderParams(
    RenderParams renderParams, {
    bool animated = false,
    Curve curve = Curves.easeOut,
    Duration duration = const Duration(milliseconds: 250),
  }) {
    _ensureHasClient();
    stopAnimation();

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
    _ensureHasClient();

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
      final focusedGrid = gridPainter?.grid;

      /// User location in grid
      if (gridPainter != null && focusedGrid != null) {
        _state?.crossLineInfo.value = CrossLineInfo(
          grid: focusedGrid,
          gridRect: Rect.zero,
        );
        _mutate((p) => p.copyWith(focusLocation: position));
      } else {
        /// User location out of grid
        final focusLocation = Offset(
          position.dx,
          double.infinity,
        );
        _state?.crossLineInfo.value = null;
        _mutate(
          (p) => p.copyWith(focusLocation: focusLocation),
        );
      }
    }
  }

  void blur({
    bool force = false,
  }) {
    if (_state == null || _state!.renderParams.focusLocation == kNullLocation) {
      return;
    }

    if (force) {
      _blur();
    } else if (_state?.widget.isAutoBlur ?? false) {
      final _focusToBlur = _focusIndex;

      Future.delayed(_state!.widget.autoBlurDuration).then((_) {
        if (_focusToBlur == _focusIndex) {
          _state.flatMap((s) {
            if (s.widget.isAutoBlur) _blur();
          });
        }
      });
    }
  }

  void _blur() {
    if (_state != null && _state!.mounted) {
      _mutate((p) => p.copyWith(focusLocation: kNullLocation));
    }
  }

  void _update({required RenderParams renderParams}) {
    _state.flatMap((s) {
      s.update(renderParams, updated: (p, v) {
        notifyListeners();
      });
    });
  }

  void _mutate(Mutator<RenderParams> mutator) {
    _state.flatMap((s) {
      s.mutate(mutator, mutated: (p, v) {
        notifyListeners();
      });
    });
  }
}

extension _SafeCalmpingExtension on num {
  num safeClamp(num lowerLimit, num upperLimit) {
    return lowerLimit < upperLimit ? clamp(lowerLimit, upperLimit) : lowerLimit;
  }
}
