import 'dart:async';
import 'dart:io';
import 'package:meta/meta.dart';
import '../entity/user.dart';
import '../repository/session_repository.dart';
import '../repository/user_repository.dart';

final _headerValueRegExp = new RegExp(r'^token [a-z0-9]{64}$', caseSensitive: false);

class AuthenticationException implements Exception {
  final String message;

  String toString() => message;

  AuthenticationException(String this.message);
}

class AuthenticationService {
  final SessionRepository _sessionRepository;
  final UserRepository _userRepository;

  Future<User> authenticate(HttpRequest request) async {
    final headerValue = request.headers.value('authorization');
    final isValid = _headerValueRegExp.hasMatch(headerValue);

    print(headerValue);
    print(isValid);

    if (!isValid) {
      throw new AuthenticationException('This API endpoint needs authentication. Call with `authorization: token xxx...`.');
    }

    final token = headerValue.substring(6);
    final session = await _sessionRepository.getSessionByToken(token);

    return await _userRepository.getUserBySession(session);
  }

  AuthenticationService({
    @required SessionRepository sessionRepository,
    @required UserRepository userRepository,
  }):
    _sessionRepository = sessionRepository,
    _userRepository = userRepository;
}
