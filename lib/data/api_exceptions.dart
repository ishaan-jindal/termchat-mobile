/// Typed failures from the termchat HTTP API. Keeps error types distinct so
/// callers no longer parse stringified exceptions to tell apart offline vs.
/// server vs. malformed responses.
sealed class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Transport-level failure: timeout, DNS, socket, TLS.
class ApiNetworkException extends ApiException {
  const ApiNetworkException(super.message, [this.cause]);

  final Object? cause;
}

/// The server answered with a non-2xx status.
class ApiServerException extends ApiException {
  const ApiServerException(this.statusCode) : super('Server error');

  final int statusCode;

  @override
  String toString() => 'Server error ($statusCode)';
}

/// The response body was not valid JSON or had an unexpected shape.
class ApiParseException extends ApiException {
  const ApiParseException(super.message);
}
