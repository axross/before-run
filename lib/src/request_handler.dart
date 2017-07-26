import 'dart:async' show Future, runZoned;
import 'dart:convert' show JsonUnsupportedObjectError, JSON, UTF8;
import 'dart:io' show ContentType, HttpRequest;
import 'package:meta/meta.dart';
import './request_exception.dart';

typedef Future<T> HandlerBody<T>();

class InvalidHttpRequestException extends BadRequestException {
  final HttpRequest request;
  final String message;

  String toString() => message;

  InvalidHttpRequestException(this.request, {@required this.message});
}

abstract class RequestHandler {
  void call(HttpRequest request);

  void handle<T>(HttpRequest request, HandlerBody<T> handlerBody, {int statusCode = 200}) {
    runZoned(() async {
      final payload = await handlerBody();
      final encoded = payload is String 
        ? payload
        : JSON.encode(payload);
      final contentType = payload is String
        ? ContentType.TEXT
        : ContentType.JSON;

      request.response
        ..statusCode = statusCode
        ..headers.contentType = contentType
        ..write(encoded)
        ..close();
    }, onError: (err, st) {
      print('Exception in a request handler:');
      print(err);
      print(st);

      if (err is BadRequestException) {
        request.response
          ..statusCode = 400
          ..headers.contentType = ContentType.TEXT
          ..write(err.toString())
          ..close();
      } else if (err is UnauthorizedException) {
        request.response
          ..statusCode = 401
          ..headers.contentType = ContentType.TEXT
          ..write(err.toString())
          ..close();
      } else if (err is NotFoundException) {
        request.response
          ..statusCode = 404
          ..headers.contentType = ContentType.TEXT
          ..write(err.toString())
          ..close();
      } else {
        request.response
          ..statusCode = 500
          ..headers.contentType = ContentType.TEXT
          ..write('An internal server error has occured.')
          ..close();
      }
    });
  }

  Future<Map> getPayloadAsJson(HttpRequest request) async {
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
}