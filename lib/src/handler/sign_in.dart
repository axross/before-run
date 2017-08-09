import 'dart:io' show HttpRequest;
import 'package:meta/meta.dart';
import '../entity/uuid.dart';

class SignIn {
  final String _githubOauthClientId;

  void call(HttpRequest request) {
    request.response.redirect(new Uri.https('github.com', '/login/oauth/authorize', {
      'client_id': _githubOauthClientId,
      'scope': ['user'].join(','),
      'state': new Uuid.v5('a').toString(),
    }));
  }

  SignIn({@required String githubOauthClientId}):
    _githubOauthClientId = githubOauthClientId;
}
