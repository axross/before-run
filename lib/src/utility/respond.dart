import 'dart:convert' show JSON;
import 'dart:io' show ContentType, HttpRequest;

void respondAsJson(HttpRequest request, dynamic payload) {
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

void respondException(HttpRequest request, Exception exception, {int statusCode = 400, String message}) {
  request.response
    ..statusCode = statusCode
    ..headers.contentType = ContentType.TEXT
    ..write(message != null ? message : exception.toString())
    ..close();
}
