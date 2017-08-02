import 'package:meta/meta.dart';
import '../persistent/application_environment_datastore.dart';
import '../persistent/application_datastore.dart';
import '../service/authentication_service.dart';
import './src/request_handler.dart';
import './src/serialize.dart';

class GetAllEnvironmentsOfApplication extends RequestHandler {
  final ApplicationEnvironmentDatastore _applicationEnvironmentDatastore;
  final ApplicationDatastore _applicationDatastore;
  final AuthenticationService _authenticationService;

  void call(HttpRequest request) {
    handle(request, () async {
      final applicationId = _extractApplicationId(request.uri);
      final user = await _authenticationService.authenticate(request);
      
      // check permission to browse an application
      final application = await _applicationDatastore.getApplication(id: applicationId, requester: user);

      final environments = await _applicationEnvironmentDatastore.getAllEnvironments(application: application);

      return environments.map((environment) => serializeApplicationEnvironment(environment)).toList();
    });
  }

  GetAllEnvironmentsOfApplication({
    @required ApplicationEnvironmentDatastore applicationEnvironmentDatastore,
    @required ApplicationDatastore applicationDatastore,
    @required AuthenticationService authenticationService,
  }):
    _applicationEnvironmentDatastore = applicationEnvironmentDatastore,
    _applicationDatastore = applicationDatastore,
    _authenticationService = authenticationService;
}

int _extractApplicationId(Uri url) =>
  int.parse(new RegExp(r'applications/([0-9]+)').firstMatch('$url').group(1), radix: 10);
