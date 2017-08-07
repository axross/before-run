import 'dart:io' show HttpStatus;

abstract class HttpException implements Exception {
  int statusCode;

  String toString();
}

abstract class BadRequestException extends HttpException {
  int statusCode = HttpStatus.BAD_REQUEST;
}

abstract class UnauthorizedException extends HttpException {
  int statusCode = HttpStatus.UNAUTHORIZED;
}

abstract class ForbiddenException extends HttpException {
  int statusCode = HttpStatus.FORBIDDEN;
}

abstract class NotFoundException extends HttpException {
  int statusCode = HttpStatus.NOT_FOUND;
}

abstract class ConflictException extends HttpException {
  int statusCode = HttpStatus.CONFLICT;
}
