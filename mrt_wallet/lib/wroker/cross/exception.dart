class FailedIsolateInitialization implements Exception {
  const FailedIsolateInitialization._();
  static const FailedIsolateInitialization failed =
      FailedIsolateInitialization._();
}

class IsolateAuthenticated implements Exception {
  const IsolateAuthenticated._();
  static const IsolateAuthenticated failed = IsolateAuthenticated._();
}
