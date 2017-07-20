import 'dart:async' show Future;
import 'dart:io' show InternetAddress;
import './src/server.dart' show startHttpServer;

Future<dynamic> main() async {
  await startHttpServer(
    serverAddress: InternetAddress.LOOPBACK_IP_V4,
    sereverPort: 8000,
    postgresUri: new Uri(
      scheme: 'postgres',
      host: 'localhost',
      port: 5432,
      path: '/database_name',
      userInfo: 'user_name:user_password',
    ),
    githubOauthClientId: 'github_oauth_client_id',
    githubOauthClientSecret: 'github_oauth_client_secret',
  );
}
