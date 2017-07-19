import 'dart:async' show Future;
import 'dart:convert' show JSON, UTF8;
import 'dart:io' show ContentType, HttpRequest;

Future<dynamic> createUser(HttpRequest request) async {
  final requestBody = await UTF8.decodeStream(request);
  final object = JSON.decode(requestBody);
  
  print(object);

  request.response
    ..statusCode = 200
    ..headers.contentType = ContentType.JSON
    ..write(JSON.encode({ 'status': 'ok' }))
    ..close();
}
