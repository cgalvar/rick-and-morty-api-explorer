enum AppFailureKind {
  charactersNotFound,
  locationNotFound,
  timeout,
  offline,
  serverUnavailable,
  invalidResponse,
  unexpected,
}

class AppFailure implements Exception {
  const AppFailure(this.kind);
  final AppFailureKind kind;
}

class NotFoundFailure extends AppFailure {
  const NotFoundFailure(super.kind);
}
