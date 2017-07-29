import 'package:meta/meta.dart';
import '../persistent/github_access_token_datastore.dart';
import '../persistent/session_datastore.dart';
import '../persistent/user_github_datastore.dart';
import '../persistent/user_datastore.dart';
import './src/request_handler.dart';

class AuthenticateCallback extends RequestHandler {
  final GithubAccessTokenDatastore _githubAccessTokenDatastore;
  final SessionDatastore _sessionDatastore;
  final UserGithubDatastore _userGithubDatastore;
  final UserDatastore _userDatastore;

  void call(HttpRequest request) {
    handle(request, () async {
      final code = request.uri.queryParameters['code'];

      // need to check fingerprint
      // final fingerprint = request.uri.queryParameters['state'];

      final accessToken = await _githubAccessTokenDatastore.getAccessToken(code);
      final user = await _userGithubDatastore.getUser(accessToken);
      final createdUser = await _userDatastore.createOrUpdate(user);
      final session = await _sessionDatastore.createSession(createdUser);

      return { 'token': session.token };
    });
  }

  AuthenticateCallback({
    @required GithubAccessTokenDatastore githubAccessTokenDatastore,
    @required SessionDatastore sessionDatastore,
    @required UserGithubDatastore userGithubDatastore,
    @required UserDatastore userDatastore,
  }):
    _githubAccessTokenDatastore = githubAccessTokenDatastore,
    _sessionDatastore = sessionDatastore,
    _userGithubDatastore = userGithubDatastore,
    _userDatastore = userDatastore;
}