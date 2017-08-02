import 'package:meta/meta.dart';
import '../persistent/application_environment_datastore.dart';
import '../persistent/application_datastore.dart';
import '../service/authentication_service.dart';
import '../utility/validate.dart';
import './src/request_handler.dart';
import './src/serialize.dart';

class CreateApplicationEnvironment extends RequestHandler {
  final ApplicationEnvironmentDatastore _applicationEnvironmentDatastore;
  final ApplicationDatastore _applicationDatastore;
  final AuthenticationService _authenticationService;

  void call(HttpRequest request) {
    handle(request, () async {
      final applicationId = _extractApplicationId(request.uri);
      final payload = await getPayloadAsJson(request);

      _validatePayloadForCreate(payload);

      final String name = payload['name'];
      final user = await _authenticationService.authenticate(request);

      // check permission to browse an application
      final application = await _applicationDatastore.getApplication(id: applicationId, requester: user);

      final environment = await _applicationEnvironmentDatastore.createEnvironment(name: name, application: application, requester: user);

      return serializeApplicationEnvironment(environment);
    }, statusCode: 201);
  }
  
  CreateApplicationEnvironment({
    @required ApplicationEnvironmentDatastore applicationEnvironmentDatastore,
    @required ApplicationDatastore applicationDatastore,
    @required AuthenticationService authenticationService,
  }):
    _applicationEnvironmentDatastore = applicationEnvironmentDatastore,
    _applicationDatastore = applicationDatastore,
    _authenticationService = authenticationService;
}

void _validatePayloadForCreate(Map<dynamic, dynamic> value) =>
  validate(value, containsPair('name', allOf(isNotNull, matches(new RegExp(r'^[a-z0-9_\-]{1,100}$')))));

int _extractApplicationId(Uri url) =>
  int.parse(new RegExp(r'applications/([0-9]+)').firstMatch('$url').group(1), radix: 10);
