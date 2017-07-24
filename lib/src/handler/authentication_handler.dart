import 'dart:async' show Future;
import 'dart:io' show HttpRequest;
import 'package:meta/meta.dart';
import '../entity/uuid.dart';
import '../repository/github_access_token_repository.dart';
import '../repository/session_repository.dart';
import '../repository/user_github_repository.dart';
import '../repository/user_repository.dart';
import '../utility/respond.dart';

class AuthenticationHandler {
  final String _githubOauthClientId;
  final GithubAccessTokenRepository _githubAccessTokenRepository;
  final SessionRepository _sessionRepository;
  final UserGithubRepository _userGithubRepository;
  final UserRepository _userRepository;

  Future<dynamic> authenticateUser(HttpRequest request) async {
    request.response.redirect(new Uri.https('github.com', '/login/oauth/authorize', {
      'client_id': _githubOauthClientId,
      'scope': ['user'].join(','),
      'state': new Uuid.v5('a').toString(),
    }));
  }

  Future<dynamic> revokeSession(HttpRequest request) async {
    try {
      final token = request.uri.path.split('/').last;

      await _sessionRepository.deleteSession(token);

      respondAsJson(request, {});
    } on SessionNotFoundException catch (err, st) {
      print(err);
      print(st);

      respondException(request, err);
    }
  }

  Future<dynamic> receiveOauthCallback(HttpRequest request) async {
    final code = request.uri.queryParameters['code'];

    // need to check fingerprint
    // final fingerprint = request.uri.queryParameters['state'];

    final accessToken = await _githubAccessTokenRepository.getAccessToken(code);
    final user = await _userGithubRepository.getUser(accessToken);
    final createdUser = await _userRepository.createOrUpdate(user);
    final session = await _sessionRepository.createSession(createdUser);

    respondAsJson(request, { 'token': session.token });
  }

  AuthenticationHandler({
    @required String githubOauthClientId,
    @required GithubAccessTokenRepository githubAccessTokenRepository,
    @required SessionRepository sessionRepository,
    @required UserGithubRepository userGithubRepository,
    @required UserRepository userRepository,
  }):
    _githubOauthClientId = githubOauthClientId,
    _githubAccessTokenRepository = githubAccessTokenRepository,
    _sessionRepository = sessionRepository,
    _userGithubRepository = userGithubRepository,
    _userRepository = userRepository;
}