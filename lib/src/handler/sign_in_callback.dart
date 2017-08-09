import 'dart:io' show HttpRequest;
import 'package:meta/meta.dart';
import '../usecase/authentication_usecase.dart';
import './src/respond_in_zone.dart';

class SignInCallback {
  final AuthenticationUsecase _authenticationUsecase;

  void call(HttpRequest request) {
    respondInZone(request, () async {
      final code = request.uri.queryParameters['code'];

      // need to check fingerprint
      // final fingerprint = request.uri.queryParameters['state'];

      final session = await _authenticationUsecase.registerUserFromGithub(code);

      return { 'token': session.token };
    });
  }

  SignInCallback({@required AuthenticationUsecase authenticationUsecase}):
    _authenticationUsecase = authenticationUsecase;
}
