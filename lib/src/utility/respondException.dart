import 'dart:io' show ContentType, HttpRequest;

void respondException(HttpRequest request, Exception exception, {int statusCode = 400, String message}) {
  request.response
    ..statusCode = statusCode
    ..headers.contentType = ContentType.TEXT
    ..write(message != null ? message : exception.toString())
    ..close();
}
