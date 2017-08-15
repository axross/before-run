import 'dart:async' show Future;
import 'dart:io' show File, InternetAddress;
import 'package:dotenv/dotenv.dart' show env, load, isEveryDefined;
import './src/server.dart' show startHttpServer;

Future<dynamic> main() async {
  load();

  final gcpServiceAccountKeyjson = await new File(env['GCP_SERVICE_ACCOUNT_KEY_JSON_PATH']).readAsString();

  await startHttpServer(
    selfAddress: InternetAddress.LOOPBACK_IP_V4,
    selfPort: int.parse(env['SERVER_PORT']),
    encryptionSecretKey: env['ENCRYPTION_SECRET_KEY'],
    postgresUri: new Uri(
      scheme: 'postgres',
      host: env['POSTGRESQL_HOST'],
      port: int.parse(env['POSTGRESQL_PORT']),
      path: env['POSTGRESQL_PATH'],
      userInfo: '${env['POSTGRESQL_USERNAME']}:${env['POSTGRESQL_PASSWORD']}',
    ),
    githubOauthClientId: env['GITHUB_OAUTH_CLIENT_ID'],
    githubOauthClientSecret: env['GITHUB_OAUTH_CLIENT_SECRET'],
    gcpServiceAccountKeyjson: gcpServiceAccountKeyjson,
  );
}
