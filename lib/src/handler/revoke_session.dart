import 'dart:io' show HttpRequest;
import 'package:meta/meta.dart';
import '../repository/session_repository.dart';
import '../request_handler.dart';

class RevokeSession extends RequestHandler {
  final SessionRepository _sessionRepository;

  void call(HttpRequest request) {
    handle(request, () async {
      final token = request.uri.path.split('/').last;

      await _sessionRepository.deleteSession(token);

      return {};
    });
  }

  RevokeSession({@required SessionRepository sessionRepository}):
    _sessionRepository = sessionRepository;
}