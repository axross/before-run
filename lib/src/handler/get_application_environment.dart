import 'package:meta/meta.dart';
import '../entity/application_environment.dart';
import '../repository/application_environment_repository.dart';
import '../repository/application_repository.dart';
import '../service/authentication_service.dart';
import './src/request_handler.dart';

Map<String, dynamic> _serializeApplicationEnvironment(ApplicationEnvironment environment) => {
  'id': environment.id,
  'name': environment.name,
};

int _extractApplicationId(Uri url) =>
  int.parse(new RegExp(r'applications/([0-9]+)').firstMatch('$url').group(1), radix: 10);

int _extractApplicationEnvironmentId(Uri url) =>
  int.parse(new RegExp(r'environments/([0-9]+)').firstMatch('$url').group(1), radix: 10);

class GetApplicationEnvironment extends RequestHandler {
  final ApplicationEnvironmentRepository _applicationEnvironmentRepository;
  final ApplicationRepository _applicationRepository;
  final AuthenticationService _authenticationService;

  void call(HttpRequest request) {
    handle(request, () async {
      final applicationId = _extractApplicationId(request.uri);
      final environmentId = _extractApplicationEnvironmentId(request.uri);
      final user = await _authenticationService.authenticate(request);

      // check permission to browse an application
      await _applicationRepository.getApplication(id: applicationId, requester: user);

      final environment = await _applicationEnvironmentRepository.getEnvironment(id: environmentId, applicationId: applicationId, requester: user);

      return _serializeApplicationEnvironment(environment);
    });
  }
  
  GetApplicationEnvironment({
    @required ApplicationEnvironmentRepository applicationEnvironmentRepository,
    @required ApplicationRepository applicationRepository,
    @required AuthenticationService authenticationService,
  }):
    _applicationEnvironmentRepository = applicationEnvironmentRepository,
    _applicationRepository = applicationRepository,
    _authenticationService = authenticationService;
}