import 'dart:async' show Future;
import 'dart:io' show HttpServer, InternetAddress;
import 'package:postgresql/pool.dart';
import 'package:route/server.dart';
import 'package:meta/meta.dart';
import './handler/create_application.dart';
import './handler/create_application_revision.dart';
import './handler/create_application_environment.dart';
import './handler/get_all_envrionments_of_application.dart';
import './handler/get_all_revisions_of_application.dart';
import './handler/get_application.dart';
import './handler/get_application_environment.dart';
import './handler/get_me.dart';
import './handler/revoke_session.dart';
import './handler/sign_in.dart';
import './handler/sign_in_callback.dart';
import './persistent/application_bucket_datastore.dart';
import './persistent/application_datastore.dart';
import './persistent/application_destination_datastore.dart';
import './persistent/application_environment_datastore.dart';
import './persistent/application_revision_datastore.dart';
import './persistent/application_revision_file_storage.dart';
import './persistent/aws_cloudfront_client.dart';
import './persistent/aws_s3_client.dart';
import './persistent/github_client.dart';
import './persistent/session_datastore.dart';
import './persistent/user_datastore.dart';
import './usecase/application_environment_usecase.dart';
import './usecase/application_revision_usecase.dart';
import './usecase/application_usecase.dart';
import './usecase/authentication_usecase.dart';

Future<dynamic> startHttpServer({
  @required InternetAddress selfAddress,
  @required int selfPort,
  @required String encryptionSecretKey,
  @required Uri postgresUri,
  @required String githubOauthClientId,
  @required String githubOauthClientSecret,
  @required String gcpServiceAccountKeyjson,
}) async {
  final httpServer = await HttpServer.bind(selfAddress, selfPort);
  final router = new Router(httpServer);

  final postgresqlConnectionPool = new Pool(
    postgresUri.toString(),
    minConnections: 1,
    maxConnections: 5,
  );

  // repositories
  final applicationBucketDatastore = new ApplicationBucketDatastore(encryptionSecretKey: encryptionSecretKey);
  final applicationDatastore = new ApplicationDatastore();
  final applicationDestinationDatastore = new ApplicationDestinationDatastore(
    encryptionSecretKey: encryptionSecretKey,
  );
  final applicationEnvironmentDatastore = new ApplicationEnvironmentDatastore();
  final applicationRevisionDatastore = new ApplicationRevisionDatastore();
  final applicationRevisionFileStorage = await ApplicationRevisionFileStorage.createStorage(
    serviceAccountKeyJson: gcpServiceAccountKeyjson,
    projectName: 'before-run',
  );
  final awsCloudfrontClient = new AwsCloudfrontClient();
  final awsS3Client = new AwsS3Client();
  final githubClient = new GithubClient(
    oauthClientId: githubOauthClientId,
    oauthClientSecret: githubOauthClientSecret,
  );
  final sessionDatastore = new SessionDatastore();
  final userDatastore = new UserDatastore();

  // use cases
  final applicationEnvironmentUsecase = new ApplicationEnvironmentUsecase(
    applicationBucketDatastore: applicationBucketDatastore,
    applicationDatastore: applicationDatastore,
    applicationDestinationDatastore: applicationDestinationDatastore,
    applicationEnvironmentDatastore: applicationEnvironmentDatastore,
    awsCloudfrontClient: awsCloudfrontClient,
    awsS3Client: awsS3Client,
    postgresqlConnectionPool: postgresqlConnectionPool,
  );
  final applicationRevisionUsecase = new ApplicationRevisionUsecase(
    applicationDatastore: applicationDatastore,
    applicationRevisionDatastore: applicationRevisionDatastore,
    applicationRevisionFileStorage: applicationRevisionFileStorage,
    postgresqlConnectionPool: postgresqlConnectionPool,
  );
  final applicationUsecase = new ApplicationUsecase(
    applicationDatastore: applicationDatastore,
    postgresqlConnectionPool: postgresqlConnectionPool,
  );
  final authenticationUsecase = new AuthenticationUsecase(
    githubClient: githubClient,
    postgresqlConnectionPool: postgresqlConnectionPool,
    sessionDatastore: sessionDatastore,
    userDatastore: userDatastore,
  );

  // request handlers
  final createApplication = new CreateApplication(
    applicationUsecase: applicationUsecase,
    authenticationUsecase: authenticationUsecase,
  );
  final createApplicationEnvironment = new CreateApplicationEnvironment(
    applicationEnvironmentUsecase: applicationEnvironmentUsecase,
    authenticationUsecase: authenticationUsecase,
  );
  final createApplicationRevision = new CreateApplicationRevision(
    applicationRevisionUsecase: applicationRevisionUsecase,
    authenticationUsecase: authenticationUsecase,
  );
  final getAllEnvironmentsOfApplication = new GetAllEnvironmentsOfApplication(
    applicationEnvironmentUsecase: applicationEnvironmentUsecase,
    authenticationUsecase: authenticationUsecase,
  );
  final getAllRevisionsOfApplication = new GetAllRevisionsOfApplication(
    applicationRevisionUsecase: applicationRevisionUsecase,
    authenticationUsecase: authenticationUsecase,
  );
  final getApplication = new GetApplication(
    applicationUsecase: applicationUsecase,
    authenticationUsecase: authenticationUsecase,
  );
  final getApplicationEnvironment = new GetApplicationEnvironment(
    applicationEnvironmentUsecase: applicationEnvironmentUsecase,
    authenticationUsecase: authenticationUsecase,
  );
  final getMe = new GetMe(authenticationUsecase: authenticationUsecase);
  final revokeSession = new RevokeSession(authenticationUsecase: authenticationUsecase);
  final signIn = new SignIn(githubOauthClientId: githubOauthClientId);
  final signInCallback = new SignInCallback(authenticationUsecase: authenticationUsecase);

  router
    ..serve(new UrlPattern(r'/sessions'), method: 'GET')
      .listen(signIn)
    ..serve(new UrlPattern(r'/sessions/callback'), method: 'GET')
      .listen(signInCallback)
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
    ..serve(new UrlPattern(r'/applications/([0-9]+)/environments/([0-9]+)'), method: 'GET')
      .listen(getApplicationEnvironment)
    ..serve(new UrlPattern(r'/applications/([0-9]+)/revisions'), method: 'GET')
      .listen(getAllRevisionsOfApplication)
    ..serve(new UrlPattern(r'/applications/([0-9]+)/revisions'), method: 'POST')
      .listen(createApplicationRevision);
  
  await postgresqlConnectionPool.start();
}
