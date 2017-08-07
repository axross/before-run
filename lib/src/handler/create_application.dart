import 'dart:io' show HttpRequest;
import 'package:meta/meta.dart';
import '../usecase/application_usecase.dart';
import '../usecase/authentication_usecase.dart';
import '../utility/validate.dart';
import './src/extract_session_token.dart';
import './src/parse_payload_as_json.dart';
import './src/respond_in_zone.dart';
import './src/serialize.dart';

class CreateApplication {
  final ApplicationUsecase _applicationUsecase;
  final AuthenticationUsecase _authenticationUsecase;

  void call(HttpRequest request) {
    respondInZone(request, () async {
      final payload = await parsePayloadAsJson(request);

      _validate(payload);

      final String name = payload['name'];
      final user = await _authenticationUsecase.authenticate(extractSessionToken(request.headers));
      final application = await _applicationUsecase.create(name: name, requester: user);

      return serializeApplication(application);
    }, {
      InvalidHttpRequestException: 400,
      ValidationException: 400,
      AuthenticationException: 401,
      NoAutorizationException: 401,
      ApplicationConflictException: 409,
    }, 201);
  }
  
  CreateApplication({
    @required ApplicationUsecase applicationUsecase,
    @required AuthenticationUsecase authenticationUsecase,
  }):
    _applicationUsecase = applicationUsecase,
    _authenticationUsecase = authenticationUsecase;
}

void _validate(Map<dynamic, dynamic> value) =>
  validate(value, containsPair('name', allOf(isNotNull, matches(new RegExp(r'^[a-z0-9_\-]{1,100}$')))));
