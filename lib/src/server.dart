import 'dart:async' show Future;
import 'dart:io' show HttpServer, InternetAddress;
import 'package:route/server.dart';
import './handler/create_user.dart' show createUser;

Future<dynamic> startHttpServer() async {
  final httpServer = await HttpServer.bind(InternetAddress.LOOPBACK_IP_V4, 8000);
  final router = new Router(httpServer);

  router
    ..serve(new UrlPattern(r'/users'), method: 'POST')
      .listen(createUser);
}
