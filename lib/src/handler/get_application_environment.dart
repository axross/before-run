import 'dart:io' show HttpRequest;
import 'package:meta/meta.dart';
import '../usecase/application_environment_usecase.dart';
import '../usecase/authentication_usecase.dart';
import './src/extract_session_token.dart';
import './src/respond_in_zone.dart';
import './src/serialize.dart';

class GetApplicationEnvironment {
  final ApplicationEnvironmentUsecase _applicationEnvironmentUsecase;
  final AuthenticationUsecase _authenticationUsecase;

  void call(HttpRequest request) {
    respondInZone(request, () async {
      final applicationId = _extractApplicationId(request.uri);
      final applicationEnvironmentId = _extractApplicationEnvironmentId(request.uri);
      final user = await _authenticationUsecase.authenticate(extractSessionToken(request.headers));
      final environment = await _applicationEnvironmentUsecase.getById(
        applicationEnvironmentId: applicationEnvironmentId,
        applicationId: applicationId,
        requester: user,
      );

      return serializeApplicationEnvironment(environment);
    }, {
      AuthenticationException: 401,
      NoAutorizationException: 401,
      ApplicationForbiddenException: 403,
      ApplicationEnvironmentForbiddenException: 403,
      ApplicationNotFoundException: 404,
      ApplicationEnvironmentNotFoundException: 404,
    });
  }
  
  GetApplicationEnvironment({
    @required ApplicationEnvironmentUsecase applicationEnvironmentUsecase,
    @required AuthenticationUsecase authenticationUsecase,
  }):
    _applicationEnvironmentUsecase = applicationEnvironmentUsecase,
    _authenticationUsecase = authenticationUsecase;
}

int _extractApplicationId(Uri url) =>
  int.parse(new RegExp(r'applications/([0-9]+)').firstMatch('$url').group(1));

int _extractApplicationEnvironmentId(Uri url) =>
  int.parse(new RegExp(r'environments/([0-9]+)').firstMatch('$url').group(1));
