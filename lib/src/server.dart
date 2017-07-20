import 'dart:async' show Future;
import 'dart:io' show HttpServer, InternetAddress;
import 'package:postgresql/pool.dart';
import 'package:route/server.dart';
import 'package:meta/meta.dart';
import './handler/authentication_handler.dart';
import './repository/github_access_token_repository.dart';
import './repository/user_github_repository.dart';
import './repository/user_repository.dart';

Future<dynamic> startHttpServer({
  @required InternetAddress serverAddress,
  @required int sereverPort,
  @required Uri postgresUri,
  @required String githubOauthClientId,
  @required String githubOauthClientSecret,
}) async {
  final httpServer = await HttpServer.bind(serverAddress, sereverPort);
  final router = new Router(httpServer);

  final postgresConnectionPool = new Pool(
    postgresUri.toString(),
    minConnections: 1,
    maxConnections: 5,
  );

  final githubAccessTokenRepository = new GithubAccessTokenRepository(
    oauthClientId: githubOauthClientId,
    oauthClientSecret: githubOauthClientSecret,
  );
  final userGithubRepository = new UserGithubRepository();
  final userRepository = new UserRepository(
    postgresConnectionPool: postgresConnectionPool,
  );

  final authenticationHandler = new AuthenticationHandler(
    githubOauthClientId: githubOauthClientId,
    githubOauthCallbackUrl: new Uri.http('localhost:8000', '/authentication/callback'),
    githubAccessTokenRepository: githubAccessTokenRepository,
    userGithubRepository: userGithubRepository,
    userRepository: userRepository,
  );

  router
    ..serve(new UrlPattern(r'/authentication'), method: 'GET')
      .listen(authenticationHandler.authenticateUser)
    ..serve(new UrlPattern(r'/authentication/callback'), method: 'GET')
      .listen(authenticationHandler.receiveOauthCallback);
  
  await postgresConnectionPool.start();
}
