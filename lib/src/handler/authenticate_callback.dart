import 'package:meta/meta.dart';
import '../repository/github_access_token_repository.dart';
import '../repository/session_repository.dart';
import '../repository/user_github_repository.dart';
import '../repository/user_repository.dart';
import './src/request_handler.dart';

class AuthenticateCallback extends RequestHandler {
  final GithubAccessTokenRepository _githubAccessTokenRepository;
  final SessionRepository _sessionRepository;
  final UserGithubRepository _userGithubRepository;
  final UserRepository _userRepository;

  void call(HttpRequest request) {
    handle(request, () async {
      final code = request.uri.queryParameters['code'];

      // need to check fingerprint
      // final fingerprint = request.uri.queryParameters['state'];

      final accessToken = await _githubAccessTokenRepository.getAccessToken(code);
      final user = await _userGithubRepository.getUser(accessToken);
      final createdUser = await _userRepository.createOrUpdate(user);
      final session = await _sessionRepository.createSession(createdUser);

      return { 'token': session.token };
    });
  }

  AuthenticateCallback({
    @required GithubAccessTokenRepository githubAccessTokenRepository,
    @required SessionRepository sessionRepository,
    @required UserGithubRepository userGithubRepository,
    @required UserRepository userRepository,
  }):
    _githubAccessTokenRepository = githubAccessTokenRepository,
    _sessionRepository = sessionRepository,
    _userGithubRepository = userGithubRepository,
    _userRepository = userRepository;
}