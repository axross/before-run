import 'dart:async' show Future;
import 'dart:io' show File, InternetAddress;
import './src/server.dart' show startHttpServer;

Future<dynamic> main() async {
  final gcpServiceAccountKeyjson = await new File('./before-run-3bd6d3f6a649.json').readAsString();

  await startHttpServer(
    selfAddress: InternetAddress.LOOPBACK_IP_V4,
    selfPort: 8000,
    encryptionSecretKey: '',
    postgresUri: new Uri(
      scheme: 'postgres',
      host: 'localhost',
      port: 5432,
      path: '/database_name',
      userInfo: 'user_name:user_password',
    ),
    githubOauthClientId: 'github_oauth_client_id',
    githubOauthClientSecret: 'github_oauth_client_secret',
    gcpServiceAccountKeyjson: gcpServiceAccountKeyjson,
  );
}
