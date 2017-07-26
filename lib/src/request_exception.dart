import 'dart:io' show HttpStatus;

abstract class RequestException implements Exception {
  int statusCode;

  String toString();
}

abstract class BadRequestException extends RequestException {
  int statusCode = HttpStatus.BAD_REQUEST;
}

abstract class UnauthorizedException extends RequestException {
  int statusCode = HttpStatus.UNAUTHORIZED;
}

abstract class ForbiddenException extends RequestException {
  int statusCode = HttpStatus.FORBIDDEN;
}

abstract class NotFoundException extends RequestException {
  int statusCode = HttpStatus.NOT_FOUND;
}

abstract class ConflictException extends RequestException {
  int statusCode = HttpStatus.CONFLICT;
}
