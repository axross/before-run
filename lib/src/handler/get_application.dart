import 'package:meta/meta.dart';
import '../persistent/application_datastore.dart';
import '../service/authentication_service.dart';
import './src/request_handler.dart';
import './src/serialize.dart';

class GetApplication extends RequestHandler {
  final ApplicationDatastore _applicationDatastore;
  final AuthenticationService _authenticationService;

  void call(HttpRequest request) {
    handle(request, () async {
      final id = int.parse(request.uri.path.split('/').last, radix: 10);
      final user = await _authenticationService.authenticate(request);
      final application = await _applicationDatastore.getApplication(id: id, requester: user);

      return serializeApplication(application);
    });
  }
  
  GetApplication({
    @required ApplicationDatastore applicationDatastore,
    @required AuthenticationService authenticationService,
  }):
    _applicationDatastore = applicationDatastore,
    _authenticationService = authenticationService;
}