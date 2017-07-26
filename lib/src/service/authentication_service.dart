import 'dart:async';
import 'dart:io';
import 'package:meta/meta.dart';
import '../entity/user.dart';
import '../repository/session_repository.dart';
import '../repository/user_repository.dart';
import '../request_exception.dart';

final RegExp _headerValueRegExp = new RegExp(r'^token [a-z0-9]{64}$');

class AuthenticationException extends UnauthorizedException {
  final String message;

  String toString() => message;

  AuthenticationException(String this.message);
}

class AuthenticationService {
  final SessionRepository _sessionRepository;
  final UserRepository _userRepository;

  Future<User> authenticate(HttpRequest request) async {
    final headerValue = request.headers.value('authorization');
    final isValid = headerValue is String && _headerValueRegExp.hasMatch(headerValue);

    if (!isValid) {
      throw new AuthenticationException('This API endpoint needs authentication. Call with `authorization: token xxx...`.');
    }

    final token = headerValue.substring(6);

    try {
      final session = await _sessionRepository.getSessionByToken(token);

      return await _userRepository.getUserBySession(session);
    } on SessionNotFoundException catch (_) {
      throw new AuthenticationException('Authentication token `$token` is not a valid token.');
    } on UserNotFoundException catch (_) {
      throw new StateError('起こるはずがない');
    }
  }

  AuthenticationService({
    @required SessionRepository sessionRepository,
    @required UserRepository userRepository,
  }):
    _sessionRepository = sessionRepository,
    _userRepository = userRepository;
}
