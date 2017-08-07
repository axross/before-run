import 'dart:io' show HttpRequest;
import 'package:meta/meta.dart';
import '../usecase/application_environment_usecase.dart';
import '../usecase/authentication_usecase.dart';
import './src/extract_session_token.dart';
import './src/respond_in_zone.dart';
import './src/serialize.dart';

class GetAllEnvironmentsOfApplication {
  final ApplicationEnvironmentUsecase _applicationEnvironmentUsecase;
  final AuthenticationUsecase _authenticationUsecase;

  void call(HttpRequest request) {
    respondInZone(request, () async {
      final applicationId = _extractApplicationId(request.uri);
      final user = await _authenticationUsecase.authenticate(extractSessionToken(request.headers));
      final environments = await _applicationEnvironmentUsecase.getAllByApplicationId(
        applicationId: applicationId,
        requester: user,
      );

      return environments.map((environment) => serializeApplicationEnvironment(environment)).toList();
    }, {
      AuthenticationException: 401,
      NoAutorizationException: 401,
    });
  }

  GetAllEnvironmentsOfApplication({
    @required ApplicationEnvironmentUsecase applicationEnvironmentUsecase,
    @required AuthenticationUsecase authenticationUsecase,
  }):
    _applicationEnvironmentUsecase = applicationEnvironmentUsecase,
    _authenticationUsecase = authenticationUsecase;
}

int _extractApplicationId(Uri url) =>
  int.parse(new RegExp(r'applications/([0-9]+)').firstMatch('$url').group(1));
