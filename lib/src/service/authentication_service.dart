import 'dart:async';
import 'dart:io';
import 'package:meta/meta.dart';
import '../entity/user.dart';
import '../persistent/session_datastore.dart';
import '../persistent/user_datastore.dart';
import '../request_exception.dart';

final RegExp _headerValueRegExp = new RegExp(r'^token [a-z0-9]{64}$');

class AuthenticationException extends UnauthorizedException {
  final String message;

  String toString() => message;

  AuthenticationException(String this.message);
}

class AuthenticationService {
  final SessionDatastore _sessionDatastore;
  final UserDatastore _userDatastore;

  Future<User> authenticate(HttpRequest request) async {
    final headerValue = request.headers.value('authorization');
    final isValid = headerValue is String && _headerValueRegExp.hasMatch(headerValue);

    if (!isValid) {
      throw new AuthenticationException('This API endpoint needs authentication. Call with `authorization: token xxx...`.');
    }

    final token = headerValue.substring(6);

    try {
      final session = await _sessionDatastore.getSessionByToken(token);

      return await _userDatastore.getUserBySession(session);
    } on SessionNotFoundException catch (_) {
      throw new AuthenticationException('Authentication token `$token` is not a valid token.');
    }
  }

  AuthenticationService({
    @required SessionDatastore sessionDatastore,
    @required UserDatastore userDatastore,
  }):
    _sessionDatastore = sessionDatastore,
    _userDatastore = userDatastore;
}
