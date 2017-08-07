import 'dart:async' show Future, runZoned;
import 'dart:convert' show JSON;
import 'dart:io' show ContentType, HttpRequest;

typedef Future<T> Body<T>();

void respondInZone<T>(HttpRequest request, Body<T> body, [Map<Type, int> errorMapper, int statusCode = 200]) {
  if (errorMapper == null) {
    errorMapper = {};
  }
  
  runZoned(() async {
    final payload = await body();
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

    final statusCode = errorMapper[err.runtimeType];

    if (statusCode == null) {
      request.response
        ..statusCode = 500
        ..headers.contentType = ContentType.TEXT
        ..write('An internal server error has occured.')
        ..close();
    } else {
      request.response
        ..statusCode = statusCode
        ..headers.contentType = ContentType.TEXT
        ..write(err.toString())
        ..close();
    }
  });
}