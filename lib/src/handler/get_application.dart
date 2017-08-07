import 'dart:io' show HttpRequest;
import 'package:meta/meta.dart';
import '../usecase/application_usecase.dart';
import '../usecase/authentication_usecase.dart';
import './src/extract_session_token.dart';
import './src/serialize.dart';
import './src/respond_in_zone.dart';

class GetApplication {
  final ApplicationUsecase _applicationUsecase;
  final AuthenticationUsecase _authenticationUsecase;

  void call(HttpRequest request) {
    respondInZone(request, () async {
      final id = _extractApplicationId(request.uri);
      final user = await _authenticationUsecase.authenticate(extractSessionToken(request.headers));
      final application = await _applicationUsecase.getById(id: id, requester: user);

      return serializeApplication(application);
    }, {
      AuthenticationException: 401,
      NoAutorizationException: 401,
      ApplicationForbiddenException: 403,
      ApplicationNotFoundException: 404,
    });
  }
  
  GetApplication({
    @required ApplicationUsecase applicationUsecase,
    @required AuthenticationUsecase authenticationUsecase,
  }):
    _applicationUsecase = applicationUsecase,
    _authenticationUsecase = authenticationUsecase;
}

int _extractApplicationId(Uri url) =>
  int.parse(new RegExp(r'applications/([0-9]+)').firstMatch('$url').group(1));
