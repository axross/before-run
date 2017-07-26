import 'dart:io' show HttpRequest;
import 'package:meta/meta.dart';
import '../entity/application_environment.dart';
import '../repository/application_environment_repository.dart';
import '../repository/application_repository.dart';
import '../service/authentication_service.dart';
import '../request_handler.dart';

Map<String, dynamic> _serializeApplicationEnvironment(ApplicationEnvironment environment) => {
  'id': environment.id,
  'name': environment.name,
};

int _extractApplicationId(Uri url) =>
  int.parse(new RegExp(r'applications/([0-9]+)').firstMatch('$url').group(1), radix: 10);

class GetAllEnvironmentsOfApplication extends RequestHandler {
  final ApplicationEnvironmentRepository _applicationEnvironmentRepository;
  final ApplicationRepository _applicationRepository;
  final AuthenticationService _authenticationService;

  void call(HttpRequest request) {
    handle(request, () async {
      final applicationId = _extractApplicationId(request.uri);
      final user = await _authenticationService.authenticate(request);
      
      // check permission to browse an application
      await _applicationRepository.getApplication(id: applicationId, requester: user);

      final environments = await _applicationEnvironmentRepository.getAllEnvironments(applicationId: applicationId, requester: user);

      return environments.map((environment) => _serializeApplicationEnvironment(environment)).toList();
    });
  }

  GetAllEnvironmentsOfApplication({
    @required ApplicationEnvironmentRepository applicationEnvironmentRepository,
    @required ApplicationRepository applicationRepository,
    @required AuthenticationService authenticationService,
  }):
    _applicationEnvironmentRepository = applicationEnvironmentRepository,
    _applicationRepository = applicationRepository,
    _authenticationService = authenticationService;
}
