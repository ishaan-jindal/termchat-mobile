/// Typed failures from the termchat HTTP API.
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

/// Non-2xx status with a truncated body snippet for debuggability.
class ApiServerException extends ApiException {
  const ApiServerException(this.statusCode, [this.bodySnippet = ''])
    : super('Server error');

  final int statusCode;
  final String bodySnippet;

  @override
  String toString() => bodySnippet.isEmpty
      ? 'Server error ($statusCode)'
      : 'Server error ($statusCode): $bodySnippet';
}

class ApiParseException extends ApiException {
  const ApiParseException(super.message);
}
