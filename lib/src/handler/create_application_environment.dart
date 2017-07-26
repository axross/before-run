import 'dart:io' show HttpRequest;
import 'package:meta/meta.dart';
import '../entity/application_environment.dart';
import '../repository/application_environment_repository.dart';
import '../service/authentication_service.dart';
import '../utility/validate.dart';
import '../request_handler.dart';

void _validatePayloadForCreate(Map<dynamic, dynamic> value) =>
  validate(value, containsPair('name', allOf(isNotNull, matches(new RegExp(r'^[a-z0-9_\-]{1,100}$')))));

Map<String, dynamic> _serializeApplicationEnvironment(ApplicationEnvironment applicationEnvironment) => {
  'id': applicationEnvironment.id,
  'name': applicationEnvironment.name,
};

int _extractApplicationId(Uri url) =>
  int.parse(new RegExp(r'applications/([0-9]+)').firstMatch('$url').group(1), radix: 10);

class CreateApplicationEnvironment extends RequestHandler {
  final ApplicationEnvironmentRepository _applicationEnvironmentRepository;
  final AuthenticationService _authenticationService;

  void call(HttpRequest request) {
    handle(request, () async {
      final payload = await getPayloadAsJson(request);

      _validatePayloadForCreate(payload);

      final String name = payload['name'];
      final applicationId = _extractApplicationId(request.uri);
      final user = await _authenticationService.authenticate(request);
      final applicationEnvironment = await _applicationEnvironmentRepository.createEnvironment(name: name, applicationId: applicationId, owner: user);

      return _serializeApplicationEnvironment(applicationEnvironment);
    }, statusCode: 201);
  }
  
  CreateApplicationEnvironment({
    @required ApplicationEnvironmentRepository applicationEnvironmentRepository,
    @required AuthenticationService authenticationService,
  }):
    _applicationEnvironmentRepository = applicationEnvironmentRepository,
    _authenticationService = authenticationService;
}