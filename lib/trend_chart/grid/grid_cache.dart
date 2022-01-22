import '../common/range.dart';

class GridCache {
  Range? xRange;
  Range? yRange;

  GridCache({
    this.xRange,
    this.yRange,
  });

  invlidate() {
    xRange = null;
    yRange = null;
  }

  void write({
    Range? xRange,
    Range? yRange,
  }) {
    this.xRange ??= xRange;
    this.yRange ??= yRange;
  }
}
