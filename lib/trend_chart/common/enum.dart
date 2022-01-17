enum LineType {
  /// "_____________"
  solid,

  /// "_ _ _ _ _ _ _"
  dash,

  /// ". . . . . . ."
  dot,
}

enum ReserveMode {
  none,
  ceil,
  floor,
  round,
}

extension NumberReserveExtension<T extends num> on T {
  double reserve(ReserveMode mode) {
    switch (mode) {
      case ReserveMode.none:
        return toDouble();
      case ReserveMode.ceil:
        return ceilToDouble();
      case ReserveMode.floor:
        return floorToDouble();
      case ReserveMode.round:
        return roundToDouble();
    }
  }
}
