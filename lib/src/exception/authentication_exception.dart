import './http_exception.dart';

class AuthenticationException extends UnauthorizedException {
  final String message;

  String toString() => message;

  AuthenticationException(String this.message);
}
