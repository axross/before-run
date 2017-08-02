import 'package:meta/meta.dart';
import '../persistent/github_client.dart';
import '../persistent/session_datastore.dart';
import '../persistent/user_datastore.dart';
import './src/request_handler.dart';

class AuthenticateCallback extends RequestHandler {
  final GithubClient _githubClient;
  final SessionDatastore _sessionDatastore;
  final UserDatastore _userDatastore;

  void call(HttpRequest request) {
    handle(request, () async {
      final code = request.uri.queryParameters['code'];

      // need to check fingerprint
      // final fingerprint = request.uri.queryParameters['state'];

      final accessToken = await _githubClient.getAccessToken(code);
      final user = await _githubClient.getUser(accessToken);
      final createdUser = await _userDatastore.createOrUpdate(user);
      final session = await _sessionDatastore.createSession(createdUser);

      return { 'token': session.token };
    });
  }

  AuthenticateCallback({
    @required GithubClient githubClient,
    @required SessionDatastore sessionDatastore,
    @required UserDatastore userDatastore,
  }):
    _githubClient = githubClient,
    _sessionDatastore = sessionDatastore,
    _userDatastore = userDatastore;
}