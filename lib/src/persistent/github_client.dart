import 'dart:async' show Future;
import 'dart:convert' show JSON;
import 'package:http/http.dart' show get, post;
import 'package:meta/meta.dart';
import '../entity/user.dart' show User;
import '../entity/uuid.dart' show Uuid;
import '../utility/validate.dart';

void _validatePayloadForUser(Map<dynamic, dynamic> value) =>
  validate(value, allOf(
    containsPair('id', allOf(isNotNull, isPositive)),
    containsPair('login', allOf(isNotNull, const isInstanceOf<String>(), isNotEmpty)),
    containsPair('email', allOf(isNotNull, isEmail)),
    containsPair('name', isNotNull),
    containsPair('avatar_url', allOf(isNotNull, isUrl)),
  ));

User _decodeToUser(String json) {
  final decoded = JSON.decode(json);
  
  _validatePayloadForUser(decoded);

  return new User(
    id: decoded['id'],
    username: decoded['login'],
    email: decoded['email'],
    name: decoded['name'],
    profileImageUrl: decoded['avatar_url'],
  );
}

class GithubClient {
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

  Future<User> getUser(String accessToken) async {
    final response = await get(new Uri.https('api.github.com', '/user'), headers: {
      'accept': 'application/vnd.github.v3+json',
      'authorization': 'token $accessToken',
    });

    return _decodeToUser(response.body);
  }

  GithubClient({@required String oauthClientId, @required String oauthClientSecret}):
    _oauthClientId = oauthClientId,
    _oauthClientSecret = oauthClientSecret;
}
