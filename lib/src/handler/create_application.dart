import 'package:meta/meta.dart';
import '../persistent/application_datastore.dart';
import '../service/authentication_service.dart';
import '../utility/validate.dart';
import './src/request_handler.dart';
import './src/serialize.dart';

class CreateApplication extends RequestHandler {
  final ApplicationDatastore _applicationDatastore;
  final AuthenticationService _authenticationService;

  void call(HttpRequest request) {
    handle(request, () async {
      final payload = await getPayloadAsJson(request);

      _validatePayloadForCreate(payload);

      final String name = payload['name'];
      final user = await _authenticationService.authenticate(request);
      final application = await _applicationDatastore.createApplication(name: name, requester: user);

      return serializeApplication(application);
    }, statusCode: 201);
  }
  
  CreateApplication({
    @required ApplicationDatastore applicationDatastore,
    @required AuthenticationService authenticationService,
  }):
    _applicationDatastore = applicationDatastore,
    _authenticationService = authenticationService;
}

void _validatePayloadForCreate(Map<dynamic, dynamic> value) =>
  validate(value, containsPair('name', allOf(isNotNull, matches(new RegExp(r'^[a-z0-9_\-]{1,100}$')))));
