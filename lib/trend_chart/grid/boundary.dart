import '../common/range.dart';

abstract class Boundary {
  Range createRange(Range range);
}

class PaddingBoundary extends Boundary {
  final double padding;

  PaddingBoundary(this.padding);

  @override
  Range createRange(Range range) {
    return Range(range.lower - padding, range.upper + padding);
  }
}

class AlignBoundary extends Boundary {
  final double align;

  AlignBoundary(
    this.align,
  ) : assert(align.isFinite && align > 0);

  double _align(double value) {
    final factor = value.abs() / align;
    if (factor.isFinite && !factor.isNaN) {
      return value.sign * align * factor.ceil();
    } else {
      return value;
    }
  }

  @override
  Range createRange(Range range) {
    return Range(
      _align(range.lower),
      _align(range.upper),
    );
  }
}
