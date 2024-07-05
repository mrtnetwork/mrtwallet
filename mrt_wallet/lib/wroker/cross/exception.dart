class FailedIsolateInitialization implements Exception {
  const FailedIsolateInitialization._();
  static const FailedIsolateInitialization failed =
      FailedIsolateInitialization._();
}
