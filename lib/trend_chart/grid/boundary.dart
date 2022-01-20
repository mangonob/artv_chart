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

  double _align(double value, {bool isUpper = true}) {
    if (value.isFinite && !value.isNaN) {
      final aligned = (value ~/ align) * align;
      if (isUpper) {
        return aligned >= value ? aligned : aligned + align;
      } else {
        return aligned <= value ? aligned : aligned - align;
      }
    } else {
      return value;
    }
  }

  @override
  Range createRange(Range range) {
    return Range(
      _align(range.lower, isUpper: false),
      _align(range.upper, isUpper: true),
    );
  }
}
