import 'dart:io' show HttpRequest;
import 'package:meta/meta.dart';
import '../usecase/authentication_usecase.dart';
import './src/serialize.dart';
import './src/respond_in_zone.dart';
import './src/extract_session_token.dart';

class GetMe {
  final AuthenticationUsecase _authenticationUsecase;

  void call(HttpRequest request) {
    respondInZone(request, () async {
      final user = await _authenticationUsecase.authenticate(extractSessionToken(request.headers));

      return serializeUser(user);
    }, {
      AuthenticationException: 401,
      NoAutorizationException: 401,
    });
  }

  GetMe({@required AuthenticationUsecase authenticationUsecase}):
    _authenticationUsecase = authenticationUsecase;
}
