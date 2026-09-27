/// Base failure type for the app.
///
/// Every layer converts its own exceptions into a [Failure] subtype so the UI
/// never needs to handle raw [Exception] objects.
sealed class Failure {
  const Failure(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Network / HTTP failure (server unreachable, 5xx, timeout, etc.)
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// The requested resource was not found (404).
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);

  factory NotFoundFailure.forQuery(String query) =>
      NotFoundFailure('"$query" was not found.');
}

/// Authentication failure (wrong password, expired token, etc.)
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Local storage failure (SQLite / SharedPreferences I/O error).
class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

/// Catch-all for unexpected errors.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}

// ---------------------------------------------------------------------------
// Exceptions
// ---------------------------------------------------------------------------

class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => 'AppException: $message';
}

class SignInCancelledException implements Exception {
  @override
  String toString() => 'SignInCancelledException: user dismissed the picker.';
}
