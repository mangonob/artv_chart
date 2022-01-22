import 'dart:math';

class DataGenerator {
  final num Function(num) f;
  final num Function(num) delta;
  final Random random;

  DataGenerator({
    required this.f,
    required this.delta,
  }) : random = Random.secure();

  factory DataGenerator.sinable({double period = 100, double max = 5000}) =>
      DataGenerator(
        f: (x) => x * sin(x / period * 2 * pi) * max,
        delta: (x) => max * x * 0.8,
      );

  List<num> generate(num index, {int count = 1}) {
    return List.generate(count, (_) {
      final v = f(index);
      final d = delta(index);
      return v + random.nextDouble() * d - d / 2;
    });
  }
}
