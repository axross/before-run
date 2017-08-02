import 'package:meta/meta.dart';
import '../persistent/session_datastore.dart';
import './src/request_handler.dart';

class RevokeSession extends RequestHandler {
  final SessionDatastore _sessionDatastore;

  void call(HttpRequest request) {
    handle(request, () async {
      final token = request.uri.path.split('/').last;

      await _sessionDatastore.deleteSession(token);

      return {};
    });
  }

  RevokeSession({@required SessionDatastore sessionDatastore}):
    _sessionDatastore = sessionDatastore;
}
