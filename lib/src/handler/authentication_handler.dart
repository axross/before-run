import 'dart:async' show Future;
import 'dart:convert' show JSON;
import 'dart:io' show ContentType, HttpRequest;
import 'package:meta/meta.dart';
import '../entity/session.dart';
import '../entity/uuid.dart';
import '../repository/github_access_token_repository.dart';
import '../repository/session_repository.dart';
import '../repository/user_github_repository.dart';
import '../repository/user_repository.dart';

class AuthenticationHandler {
  final String githubOauthClientId;
  final Uri githubOauthCallbackUrl;
  final GithubAccessTokenRepository githubAccessTokenRepository;
  final SessionRepository sessionRepository;
  final UserGithubRepository userGithubRepository;
  final UserRepository userRepository;

  Future<dynamic> authenticateUser(HttpRequest request) async {
    request.response.redirect(new Uri.https('github.com', '/login/oauth/authorize', {
      'client_id': githubOauthClientId,
      'redirect_uri': githubOauthCallbackUrl.toString(),
      'scope': ['user'].join(','),
      'state': new Uuid.v5('a').toString(),
    }));
  }

  Future<dynamic> receiveOauthCallback(HttpRequest request) async {
    final code = request.uri.queryParameters['code'];

    // need to check fingerprint
    // final fingerprint = request.uri.queryParameters['state'];

    final accessToken = await githubAccessTokenRepository.getAccessToken(code);
    final user = await userGithubRepository.getUser(accessToken);
    final createdUser = await userRepository.createOrUpdate(user);
    final session = await sessionRepository.createSession(createdUser);

    request.response
      ..statusCode = 200
      ..headers.contentType = ContentType.JSON
      ..write(JSON.encode({ 'token': session.token }))
      ..close();
  }

  AuthenticationHandler({
    @required this.githubOauthClientId,
    @required this.githubOauthCallbackUrl,
    @required this.githubAccessTokenRepository,
    @required this.sessionRepository,
    @required this.userGithubRepository,
    @required this.userRepository,
  });
}