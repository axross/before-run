import 'dart:async' show Future;
import './src/server.dart' show startHttpServer;

Future<dynamic> main() async {
  await startHttpServer();
}
