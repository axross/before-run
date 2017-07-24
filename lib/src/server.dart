import 'dart:async' show Future;
import 'dart:io' show HttpServer, InternetAddress;
import 'package:postgresql/pool.dart';
import 'package:route/server.dart';
import 'package:meta/meta.dart';
import './handler/authentication_handler.dart';
import './handler/user_handler.dart';
import './repository/github_access_token_repository.dart';
import './repository/session_repository.dart';
import './repository/user_github_repository.dart';
import './repository/user_repository.dart';
import './service/authentication_service.dart';

Future<dynamic> startHttpServer({
  @required InternetAddress selfAddress,
  @required int selfPort,
  @required Uri postgresUri,
  @required String githubOauthClientId,
  @required String githubOauthClientSecret,
}) async {
  final httpServer = await HttpServer.bind(selfAddress, selfPort);
  final router = new Router(httpServer);

  final postgresConnectionPool = new Pool(
    postgresUri.toString(),
    minConnections: 1,
    maxConnections: 5,
  );

  // repositories
  final githubAccessTokenRepository = new GithubAccessTokenRepository(
    oauthClientId: githubOauthClientId,
    oauthClientSecret: githubOauthClientSecret,
  );
  final sessionRepository = new SessionRepository(
    postgresConnectionPool: postgresConnectionPool,
  );
  final userGithubRepository = new UserGithubRepository();
  final userRepository = new UserRepository(
    postgresConnectionPool: postgresConnectionPool,
  );

  // services
  final authenticationService = new AuthenticationService(
    userRepository: userRepository,
    sessionRepository: sessionRepository,
  );

  // request handlers
  final authenticationHandler = new AuthenticationHandler(
    githubOauthClientId: githubOauthClientId,
    githubAccessTokenRepository: githubAccessTokenRepository,
    sessionRepository: sessionRepository,
    userGithubRepository: userGithubRepository,
    userRepository: userRepository,
  );
  final userHandler = new UserHandler(authenticationService: authenticationService);

  router
    ..serve(new UrlPattern(r'/sessions'), method: 'GET')
      .listen(authenticationHandler.authenticateUser)
    ..serve(new UrlPattern(r'/sessions/([a-f0-9]{64})'), method: 'DELETE')
      .listen(authenticationHandler.revokeSession)
    ..serve(new UrlPattern(r'/sessions/callback'), method: 'GET')
      .listen(authenticationHandler.receiveOauthCallback)
    ..serve(new UrlPattern(r'/users/me'), method: 'GET')
      .listen(userHandler.getMe);
  
  await postgresConnectionPool.start();
}
