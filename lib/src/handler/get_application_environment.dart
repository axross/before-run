import 'package:meta/meta.dart';
import '../persistent/application_environment_datastore.dart';
import '../persistent/application_datastore.dart';
import '../service/authentication_service.dart';
import './src/request_handler.dart';
import './src/serialize.dart';

class GetApplicationEnvironment extends RequestHandler {
  final ApplicationEnvironmentDatastore _applicationEnvironmentDatastore;
  final ApplicationDatastore _applicationDatastore;
  final AuthenticationService _authenticationService;

  void call(HttpRequest request) {
    handle(request, () async {
      final applicationId = _extractApplicationId(request.uri);
      final environmentId = _extractApplicationEnvironmentId(request.uri);
      final user = await _authenticationService.authenticate(request);

      // check permission to browse an application
      final application = await _applicationDatastore.getApplication(id: applicationId, requester: user);

      final environment = await _applicationEnvironmentDatastore.getEnvironment(id: environmentId, application: application, requester: user);

      return serializeApplicationEnvironment(environment);
    });
  }
  
  GetApplicationEnvironment({
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

int _extractApplicationEnvironmentId(Uri url) =>
  int.parse(new RegExp(r'environments/([0-9]+)').firstMatch('$url').group(1), radix: 10);
