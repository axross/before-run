import 'dart:async' show Future;
import 'dart:convert' show JsonUnsupportedObjectError, JSON, UTF8;
import 'dart:io' show ContentType, HttpRequest;
import 'package:meta/meta.dart';

Future<Map<String, dynamic>> parsePayloadAsJson(HttpRequest request) async {
  if (request.headers.contentType == null ||
      request.headers.contentType.mimeType != (ContentType.JSON as ContentType).mimeType) {
    throw new InvalidHttpRequestException(request, message: 'This API requires a request as application/json.');
  }

  try {
    final json = await await UTF8.decodeStream(request);
    final decoded = JSON.decode(json);

    return decoded;
  } on JsonUnsupportedObjectError catch (_) {
    throw new InvalidHttpRequestException(request, message: 'This API requires a request as application/json.');
  }
}

class InvalidHttpRequestException {
  final HttpRequest request;
  final String message;

  String toString() => message;

  InvalidHttpRequestException(this.request, {@required this.message});
}
