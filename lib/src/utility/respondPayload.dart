import 'dart:convert';
import 'dart:io' show ContentType, HttpRequest;

void respondPayload(HttpRequest request, dynamic payload) {
  try {
    final json = payload is String
      ? payload
      : JSON.encode(payload);

    request.response
      ..statusCode = 200
      ..headers.contentType = ContentType.JSON
      ..write(json)
      ..close();
  } catch (_) {
    request.response
      ..statusCode = 500
      ..headers.contentType = ContentType.TEXT
      ..write('An internal server error has occured.')
      ..close();

    rethrow;
  }
}
