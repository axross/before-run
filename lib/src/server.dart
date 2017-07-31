import 'dart:async' show Future;
import 'dart:io' show HttpServer, InternetAddress;
import 'package:postgresql/pool.dart';
import 'package:route/server.dart';
import 'package:meta/meta.dart';
import './handler/authenticate_callback.dart';
import './handler/authenticate.dart';
import './handler/create_application.dart';
import './handler/create_application_revision.dart';
import './handler/create_application_environment.dart';
import './handler/get_all_envrionments_of_application.dart';
import './handler/get_application.dart';
import './handler/get_me.dart';
import './handler/revoke_session.dart';
import './persistent/application_datastore.dart';
import './persistent/application_environment_datastore.dart';
import './persistent/application_revision_datastore.dart';
import './persistent/application_revision_file_storage.dart';
import './persistent/github_access_token_datastore.dart';
import './persistent/session_datastore.dart';
import './persistent/user_github_datastore.dart';
import './persistent/user_datastore.dart';
import './service/authentication_service.dart';

Future<dynamic> startHttpServer({
  @required InternetAddress selfAddress,
  @required int selfPort,
  @required Uri postgresUri,
  @required String githubOauthClientId,
  @required String githubOauthClientSecret,
  @required String gcpServiceAccountKeyjson,
}) async {
  final httpServer = await HttpServer.bind(selfAddress, selfPort);
  final router = new Router(httpServer);

  final postgresConnectionPool = new Pool(
    postgresUri.toString(),
    minConnections: 1,
    maxConnections: 5,
  );

  // repositories
  final applicationDatastore = new ApplicationDatastore(
    postgresConnectionPool: postgresConnectionPool,
  );
  final applicationEnvironmentDatastore = new ApplicationEnvironmentDatastore(
    postgresConnectionPool: postgresConnectionPool,
  );
  final applicationRevisionDatastore = new ApplicationRevisionDatastore(
    postgresConnectionPool: postgresConnectionPool,
  );
  final applicationRevisionFileStorage = await ApplicationRevisionFileStorage.createStorage(
    serviceAccountKeyJson: gcpServiceAccountKeyjson,
    projectName: 'before-run',
  );
  final githubAccessTokenDatastore = new GithubAccessTokenDatastore(
    oauthClientId: githubOauthClientId,
    oauthClientSecret: githubOauthClientSecret,
  );
  final sessionDatastore = new SessionDatastore(
    postgresConnectionPool: postgresConnectionPool,
  );
  final userGithubDatastore = new UserGithubDatastore();
  final userDatastore = new UserDatastore(
    postgresConnectionPool: postgresConnectionPool,
  );

  // services
  final authenticationService = new AuthenticationService(
    userDatastore: userDatastore,
    sessionDatastore: sessionDatastore,
  );

  // request handlers
  final authenticate = new Authenticate(githubOauthClientId: githubOauthClientId);
  final authenticateCallback = new AuthenticateCallback(
    githubAccessTokenDatastore: githubAccessTokenDatastore,
    sessionDatastore: sessionDatastore,
    userGithubDatastore: userGithubDatastore,
    userDatastore: userDatastore,
  );
  final createApplication = new CreateApplication(
    applicationDatastore: applicationDatastore,
    authenticationService: authenticationService,
  );
  final createApplicationEnvironment = new CreateApplicationEnvironment(
    applicationEnvironmentDatastore: applicationEnvironmentDatastore,
    applicationDatastore: applicationDatastore,
    authenticationService: authenticationService,
  );
  final createApplicationRevision = new CreateApplicationRevision(
    applicationDatastore: applicationDatastore,
    applicationRevisionDatastore: applicationRevisionDatastore,
    applicationRevisionFileStorage: applicationRevisionFileStorage,
    authenticationService: authenticationService,
  );
  final getAllEnvironmentsOfApplication = new GetAllEnvironmentsOfApplication(
    applicationEnvironmentDatastore: applicationEnvironmentDatastore,
    applicationDatastore: applicationDatastore,
    authenticationService: authenticationService,
  );
  final getApplication = new GetApplication(
    applicationDatastore: applicationDatastore,
    authenticationService: authenticationService,
  );
  final getMe = new GetMe(authenticationService: authenticationService);
  final revokeSession = new RevokeSession(sessionDatastore: sessionDatastore);

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
      .listen(createApplicationEnvironment)
    ..serve(new UrlPattern(r'/applications/([0-9]+)/revisions'), method: 'POST')
      .listen(createApplicationRevision);
  
  await postgresConnectionPool.start();
}
