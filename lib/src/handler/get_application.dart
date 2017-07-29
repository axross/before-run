import 'package:meta/meta.dart';
import '../entity/application.dart';
import '../persistent/application_datastore.dart';
import '../service/authentication_service.dart';
import './src/request_handler.dart';

Map<String, dynamic> _serializeApplication(Application application) => {
  'id': application.id,
  'name': application.name,
};

class GetApplication extends RequestHandler {
  final ApplicationDatastore _applicationDatastore;
  final AuthenticationService _authenticationService;

  void call(HttpRequest request) {
    handle(request, () async {
      final id = int.parse(request.uri.path.split('/').last, radix: 10);
      final user = await _authenticationService.authenticate(request);
      final application = await _applicationDatastore.getApplication(id: id, requester: user);

      return _serializeApplication(application);
    });
  }
  
  GetApplication({
    @required ApplicationDatastore applicationDatastore,
    @required AuthenticationService authenticationService,
  }):
    _applicationDatastore = applicationDatastore,
    _authenticationService = authenticationService;
}