import 'dart:async' show Future;
import 'dart:convert' show JSON;
import 'package:http/http.dart' show post;
import 'package:meta/meta.dart';
import '../entity/uuid.dart' show Uuid;

class GithubAccessTokenDatastore {
  final String _oauthClientId;
  final String _oauthClientSecret;

  Future<String> getAccessToken(String code) async {
    final response = await post(new Uri.https('github.com', '/login/oauth/access_token', {
      'client_id': _oauthClientId,
      'client_secret': _oauthClientSecret,
      'code': code,
      'state': new Uuid.v5('b').toString(),
    }), headers: {
      'accept': 'application/json',
    });

    final responseJson = JSON.decode(response.body);
    final accessToken = responseJson['access_token'];

    return accessToken;
  }

  GithubAccessTokenDatastore({@required String oauthClientId, @required String oauthClientSecret}):
    _oauthClientId = oauthClientId,
    _oauthClientSecret = oauthClientSecret;
}
