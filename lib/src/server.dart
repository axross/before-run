import 'dart:async' show Future;
import 'dart:io' show HttpServer, InternetAddress;
import 'package:postgresql/pool.dart';
import 'package:route/server.dart';
import 'package:meta/meta.dart';
import './handler/authenticate_callback.dart';
import './handler/authenticate.dart';
import './handler/create_application.dart';
import './handler/create_application_environment.dart';
import './handler/get_all_envrionments_of_application.dart';
import './handler/get_application.dart';
import './handler/get_me.dart';
import './handler/revoke_session.dart';
import './repository/application_repository.dart';
import './repository/application_environment_repository.dart';
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
  final applicationRepository = new ApplicationRepository(
    postgresConnectionPool: postgresConnectionPool,
  );
  final applicationEnvironmentRepository = new ApplicationEnvironmentRepository(
    postgresConnectionPool: postgresConnectionPool,
  );
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
  final authenticate = new Authenticate(githubOauthClientId: githubOauthClientId);
  final authenticateCallback = new AuthenticateCallback(
    githubAccessTokenRepository: githubAccessTokenRepository,
    sessionRepository: sessionRepository,
    userGithubRepository: userGithubRepository,
    userRepository: userRepository,
  );
  final createApplication = new CreateApplication(
    applicationRepository: applicationRepository,
    authenticationService: authenticationService,
  );
  final createApplicationEnvironment = new CreateApplicationEnvironment(
    applicationEnvironmentRepository: applicationEnvironmentRepository,
    applicationRepository: applicationRepository,
    authenticationService: authenticationService,
  );
  final getAllEnvironmentsOfApplication = new GetAllEnvironmentsOfApplication(
    applicationEnvironmentRepository: applicationEnvironmentRepository,
    applicationRepository: applicationRepository,
    authenticationService: authenticationService,
  );
  final getApplication = new GetApplication(
    applicationRepository: applicationRepository,
    authenticationService: authenticationService,
  );
  final getMe = new GetMe(authenticationService: authenticationService);
  final revokeSession = new RevokeSession(sessionRepository: sessionRepository);

  router
    ..serve(new UrlPattern(r'/sessions'), method: 'GET')
      .listen(authenticate)
    ..serve(new UrlPattern(r'/sessions/callback'), method: 'GET')
      .listen(authenticateCallback)
    ..serve(new UrlPattern(r'/sessions/([a-f0-9]{64})'), method: 'DELETE')
      .listen(revokeSession)
    ..serve(new UrlPattern(r'/users/me'), method: 'GET')
      .listen(getMe)
    ..serve(new UrlPattern(r'/applications'), method: 'POST')
      .listen(createApplication)
    ..serve(new UrlPattern(r'/applications/([0-9]+)'), method: 'GET')
      .listen(getApplication)
    ..serve(new UrlPattern(r'/applications/([0-9]+)/environments'), method: 'GET')
      .listen(getAllEnvironmentsOfApplication)
    ..serve(new UrlPattern(r'/applications/([0-9]+)/environments'), method: 'POST')
      .listen(createApplicationEnvironment);
  
  await postgresConnectionPool.start();
}
