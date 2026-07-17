/// Base failure type surfaced from repositories to the presentation layer.
/// Keeping this sealed-ish (via subclasses) lets UI code pattern-match on
/// failure kind without leaking Dio/Hive-specific exceptions upward.
sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Network request failed.']);
}

class CacheException extends AppException {
  const CacheException([super.message = 'Local cache operation failed.']);
}

class ParsingException extends AppException {
  const ParsingException([super.message = 'Failed to parse response.']);
}

class UnknownException extends AppException {
  const UnknownException([super.message = 'An unknown error occurred.']);
}
