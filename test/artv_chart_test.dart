import 'package:artv_chart/trend_chart/common/range.dart';
import 'package:artv_chart/trend_chart/grid/boundary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Range test', () {
    expect(const Range(1, 4).union(const Range(2, 8)), const Range(1, 8));
    expect(const Range(1, 4).union(const Range(7, 8)), const Range(1, 8));
    expect(
      const Range.lowest(40).union(const Range(10, 20)),
      const Range.lowest(10),
    );
    expect(
      const Range.lowest(100).intersection(const Range.highest(200)),
      const Range(100, 200),
    );
    expect(
      const Range.lowest(100).union(const Range.highest(200)),
      const Range.unbounded(),
    );
  });

  test('AlignBoundary test', () {
    final aHalf = AlignBoundary(0.5);
    final a1 = AlignBoundary(1);
    final a20 = AlignBoundary(20);

    expect(aHalf.createRange(const Range(0.1, 2.3)), const Range(0, 2.5));
    expect(aHalf.createRange(const Range(-0.4, 100)), const Range(-0.5, 100));
    expect(a1.createRange(const Range(-0.4, 37.4)), const Range(-1, 38));
    expect(a20.createRange(const Range(0, 2)), const Range(0, 20));
    expect(a20.createRange(const Range(0, 4)), const Range(0, 20));
    expect(a20.createRange(const Range(-3, 10)), const Range(-20, 20));
    expect(a20.createRange(const Range(-3, 20)), const Range(-20, 20));
    expect(a20.createRange(const Range(-3, 21)), const Range(-20, 40));
    expect(a20.createRange(const Range(-20, 21)), const Range(-20, 40));
    expect(a20.createRange(const Range(-21, 21)), const Range(-40, 40));
    expect(a20.createRange(const Range(-37, 101)), const Range(-40, 120));
    expect(a20.createRange(const Range(101, 181)), const Range(100, 200));
    expect(
      a20.createRange(const Range(0, double.infinity)),
      const Range(0, double.infinity),
    );
  });
}
