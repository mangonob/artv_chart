import 'dart:math' as math;
import 'dart:ui';

import 'package:artv_chart/trend_chart/common/range.dart';
import 'package:flutter/material.dart';

import '../../common/render_params.dart';
import '../../grid/grid.dart';
import 'line_series.dart';

class LineSeriesPainter extends CustomPainter {
  final LineSeries series;
  final RenderParams renderParams;
  final Grid grid;
  int _startIndex = 0, _stopIndex = 0;

  LineSeriesPainter({
    required this.series,
    required this.renderParams,
    required this.grid,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    if (series.datas.isEmpty) return;
    _calculate(size);
    _paintLineChart(canvas, size);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) =>
      oldDelegate != this;

  @override
  operator ==(Object other) =>
      other is LineSeriesPainter &&
      series == other.series &&
      renderParams == other.renderParams;

  @override
  int get hashCode => hashValues(
        series,
        renderParams,
      );

  final List<Offset> _offsetList = [];

  bool get _isDrawLine => _offsetList.length > 1;
  late Range _yRange;

  void _paintLineChart(Canvas canvas, Size size) {
    final margin = grid.style.margin ?? EdgeInsets.zero;

    ///裁剪矩形绘制区域
    canvas.clipRect(Rect.fromLTRB(margin.left, margin.top,
        size.width - margin.right, size.height - margin.bottom));
    Size rectSize = Size(
        size.width - margin.horizontal - renderParams.padding.horizontal,
        size.height - renderParams.padding.vertical - margin.vertical);

    ///计算Y轴每一个点所占的offset.dy
    double yPerUnit = rectSize.height / (_yRange.upper - _yRange.lower);
    canvas.translate(
        _getTranslateX(margin), margin.top + renderParams.padding.top);
    _offsetList.clear();
    for (int i = _startIndex; i <= _stopIndex; i++) {
      ///当数据只有一个的时候，就只添加一个坐标画一个点
      if (series.datas.length == 1) {
        _offsetList.add(Offset(series.datas[_startIndex].dx * renderParams.unit,
            _getY(_startIndex, yPerUnit)));
        continue;
      }

      ///当画到屏幕上第一个点的时候，往左边多画一个点
      if (i == _startIndex) {
        if (i == 0 && _offsetList.isNotEmpty) {
          continue;
        }
        _offsetList.add(Offset(
            series.datas[i == 0 ? 0 : i - 1].dx * renderParams.unit,
            _getY(i == 0 ? 0 : i - 1, yPerUnit)));
      }
      _offsetList.add(
          Offset(series.datas[i].dx * renderParams.unit, _getY(i, yPerUnit)));

      ///当画到屏幕上最后一个点并且没有画到总数据的最大长度的时候，往右边多画一个点
      if (i == _stopIndex && i < series.datas.length - 1) {
        _offsetList.add(Offset(series.datas[i + 1].dx * renderParams.unit,
            _getY(i + 1, yPerUnit)));
      }
    }
    canvas.drawPoints(
        _isDrawLine ? PointMode.polygon : PointMode.points,
        _offsetList,
        Paint()
          ..style = PaintingStyle.fill
          ..strokeCap = _isDrawLine ? StrokeCap.butt : StrokeCap.round
          ..color = series.style.color!
          ..strokeWidth =
              _isDrawLine ? series.style.size! : series.style.singlePointSize!);
  }

  void _calculate(Size size) {
    _yRange = grid.yRange(params: renderParams, size: size);

    if (renderParams.xOffset < 0) {
      _startIndex = 0;
      _stopIndex = _startIndex +
          (size.width + renderParams.xOffset) ~/ renderParams.unit;
      return;
    }

    ///从第几个点开始画
    _startIndex = renderParams.xOffset ~/ renderParams.unit;

    ///从开始点的位置加上屏幕能装的下的位置
    _stopIndex = math.min(
        _startIndex + size.width ~/ renderParams.unit, series.datas.length - 1);
  }

  ///计算画布的x偏移量
  double _getTranslateX(EdgeInsets margin) {
    double result = 0;
    result = margin.left +
        renderParams.padding.left +

        ///X轴左边是否留半个单位宽度出来
        (renderParams.isIgnoredUnitVolume ? 0 : renderParams.unit / 2) -

        ///从第几个点开始画，就要跳过当前点之前的位移
        renderParams.unit * _startIndex;
    if (renderParams.xOffset < 0) {
      ///反方向滑到负数之后，原点应该不停的往右移动
      result -= renderParams.xOffset;
    } else {
      result -= renderParams.xOffset % renderParams.unit;
    }
    return result;
  }

  double _getY(int dataIndex, double yPerUnit) =>
      (_yRange.upper - series.datas[dataIndex].dy) * yPerUnit;
}
