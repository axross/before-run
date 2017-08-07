import 'dart:async' show Future;
import 'package:meta/meta.dart';
import 'package:postgresql/pool.dart' show Pool;
import '../entity/session.dart';
import '../entity/user.dart';
import '../persistent/github_client.dart';
import '../persistent/session_datastore.dart';
import '../persistent/user_datastore.dart';

export '../persistent/session_datastore.dart' show SessionNotFoundException;
export '../persistent/user_datastore.dart' show UserNotFoundException;

class AuthenticationUsecase {
  final GithubClient _githubClient;
  final Pool _postgresqlConnectionPool;
  final SessionDatastore _sessionDatastore;
  final UserDatastore _userDatastore;

  Future<User> authenticate(String token) async {
    final connection = await _postgresqlConnectionPool.connect();

    try {
      final session = await _sessionDatastore.getByToken(connection, token);

      return await _userDatastore.getUserBySession(connection, session);
    } on SessionNotFoundException catch (_) {
      throw new AuthenticationException('Authentication token `$token` is not a valid token.');
    } finally {
      connection.close();
    }
  }

  Future<dynamic> deauthenticate(String token) async {
    final connection = await _postgresqlConnectionPool.connect();

    try {
      await _sessionDatastore.delete(connection, token);
    } finally {
      connection.close();
    }
  }

  Future<Session> registerUserFromGithub(String code) async {
    final accessToken = await _githubClient.getAccessToken(code);
    final user = await _githubClient.getUser(accessToken);
    final connection = await _postgresqlConnectionPool.connect();

    try {
      return await connection.runInTransaction(() async {
        final createdUser = await _userDatastore.createOrUpdate(connection, user);

        return await _sessionDatastore.create(connection, createdUser);
      });
    } finally {
      connection.close();
    }
  }

  AuthenticationUsecase({
    @required GithubClient githubClient,
    @required Pool postgresqlConnectionPool,
    @required SessionDatastore sessionDatastore,
    @required UserDatastore userDatastore,
  }):
    _githubClient = githubClient,
    _postgresqlConnectionPool = postgresqlConnectionPool,
    _sessionDatastore = sessionDatastore,
    _userDatastore = userDatastore;
}

class AuthenticationException implements Exception {
  final String message;

  String toString() => message;

  AuthenticationException(String this.message);
}
