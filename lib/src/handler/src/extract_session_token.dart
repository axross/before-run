import 'dart:io' show HttpHeaders;

final RegExp _headerValueRegExp = new RegExp(r'^token [a-z0-9]{64}$');

String extractSessionToken(HttpHeaders headers) {
  final headerValue = headers.value(HttpHeaders.AUTHORIZATION);
  final isValid = headerValue is String && _headerValueRegExp.hasMatch(headerValue);

  if (!isValid) {
    throw new NoAutorizationException('This API endpoint needs authentication. Call with `authorization: token xxx...`.');
  }

  return headerValue.substring(6);
}

class NoAutorizationException implements Exception {
  final String message;

  String toString() => message;

  NoAutorizationException(String this.message);
}
