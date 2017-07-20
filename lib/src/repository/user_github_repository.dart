import 'dart:async' show Future;
import 'dart:convert' show JSON;
import 'package:http/http.dart' show get;
import 'package:angel_validate/angel_validate.dart';
import '../entity/user.dart' show User;

final Validator _userValidator = new Validator({
  'id': [isNotNull, isPositive],
  'login': [isNotNull, isNonEmptyString],
  'email': [isNotNull, isEmail],
  'name': [isNotNull],
  'avatar_url': [isNotNull, isUrl],
});

User _decodeToUser(String json) {
  final object = JSON.decode(json);
  final validated = _userValidator.enforce(object);

  return new User(
    id: validated['id'],
    username: validated['login'],
    email: validated['email'],
    name: validated['name'],
    profileImageUrl: validated['avatar_url'],
  );
}

class UserGithubRepository {
  Future<User> getUser(String accessToken) async {
    final response = await get(new Uri.https('api.github.com', '/user'), headers: {
      'accept': 'application/vnd.github.v3+json',
      'authorization': 'token $accessToken',
    });

    return _decodeToUser(response.body);
  }
}