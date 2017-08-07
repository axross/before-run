import 'dart:io' show HttpRequest;
import 'package:meta/meta.dart';
import '../usecase/authentication_usecase.dart';
import './src/respond_in_zone.dart';

class RevokeSession {
  final AuthenticationUsecase _authenticationUsecase;

  void call(HttpRequest request) {
    respondInZone(request, () async {
      final token = _extractSessionToken(request.uri);

      await _authenticationUsecase.deauthenticate(token);

      return '';
    }, {
      SessionNotFoundException: 404,
    });
  }

  RevokeSession({@required AuthenticationUsecase authenticationUsecase}):
    _authenticationUsecase = authenticationUsecase;
}

String _extractSessionToken(Uri url) =>
  new RegExp(r'sessions/([0-9a-f]+)').firstMatch('$url').group(1);
