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
