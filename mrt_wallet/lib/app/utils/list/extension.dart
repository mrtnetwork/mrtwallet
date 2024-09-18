extension QuickImutableList<T> on Iterable<T> {
  List<T> get imutable => List<T>.unmodifiable(this);
  List<T>? get imutableAndNullOnEmpty =>
      isEmpty ? null : List<T>.unmodifiable(this);
  T? firstWhereOrNull(bool Function(T) test, {T? Function()? orElse}) {
    try {
      return firstWhere(test);
    } on StateError {
      return orElse?.call();
    }
  }
}
