import 'package:tuple/tuple.dart';

typedef Mutator<T> = T Function(T);

extension NullableMonad<T> on T? {
  U? flatMap<U>(U? Function(T v) f) {
    if (this == null) {
      return null;
    } else {
      return f(this!);
    }
  }
}

List<Tuple2<T1, T2>> zip<T1, T2>(Iterable<T1> i1, Iterable<T2> i2) {
  final iter1 = i1.iterator;
  final iter2 = i2.iterator;
  final List<Tuple2<T1, T2>> result = [];

  while (iter1.moveNext() && iter2.moveNext()) {
    result.add(Tuple2(iter1.current, iter2.current));
  }

  return result;
}

/// Ignore unused variable warning
void ignoreUnused<T>(T any) {}

D undefined<D, S>(S obj) {
  return null as D;
}
