import 'dart:io' show HttpRequest;
import 'package:meta/meta.dart';
import '../entity/application.dart';
import '../repository/application_environment_repository.dart';
import '../service/authentication_service.dart';
import '../request_handler.dart';

Map<String, dynamic> _serializeApplication(Application application) => {
  'id': application.id,
  'name': application.name,
};

int _extractApplicationId(Uri url) =>
  int.parse(new RegExp(r'applications/([0-9]+)').firstMatch('$url').group(1), radix: 10);

int _extractApplicationEnvironmentId(Uri url) =>
  int.parse(new RegExp(r'environments/([0-9]+)').firstMatch('$url').group(1), radix: 10);

class GetApplicationEnvironment extends RequestHandler {
  final ApplicationEnvironmentRepository _applicationEnvironmentRepository;
  final AuthenticationService _authenticationService;

  void call(HttpRequest request) {
    handle(request, () async {
      final applicationId = _extractApplicationId(request.uri);
      final id = _extractApplicationEnvironmentId(request.uri);
      final user = await _authenticationService.authenticate(request);
      final application = await _applicationEnvironmentRepository.getEnvironment(id: id, owner: user);

      return _serializeApplication(application);
    });
  }
  
  GetApplicationEnvironment({
    @required ApplicationEnvironmentRepository applicationEnvironmentRepository,
    @required AuthenticationService authenticationService,
  }):
    _applicationEnvironmentRepository = applicationEnvironmentRepository,
    _authenticationService = authenticationService;
}