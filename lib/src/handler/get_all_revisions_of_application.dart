import 'package:meta/meta.dart';
import '../persistent/application_datastore.dart';
import '../persistent/application_revision_datastore.dart';
import '../service/authentication_service.dart';
import './src/request_handler.dart';
import './src/serialize.dart';

class GetAllRevisionsOfApplication extends RequestHandler {
  final ApplicationRevisionDatastore _applicationRevisionDatastore;
  final ApplicationDatastore _applicationDatastore;
  final AuthenticationService _authenticationService;

  void call(HttpRequest request) {
    handle(request, () async {
      final applicationId = _extractApplicationId(request.uri);
      final user = await _authenticationService.authenticate(request);
      
      // check permission to browse an application
      final application = await _applicationDatastore.getApplication(id: applicationId, requester: user);

      final revisions = await _applicationRevisionDatastore.getAllRevisions(application: application);

      return revisions.map((revision) => serializeApplicationRevision(revision)).toList();
    });
  }

  GetAllRevisionsOfApplication({
    @required ApplicationRevisionDatastore applicationRevisionDatastore,
    @required ApplicationDatastore applicationDatastore,
    @required AuthenticationService authenticationService,
  }):
    _applicationRevisionDatastore = applicationRevisionDatastore,
    _applicationDatastore = applicationDatastore,
    _authenticationService = authenticationService;
}

int _extractApplicationId(Uri url) =>
  int.parse(new RegExp(r'applications/([0-9]+)').firstMatch('$url').group(1), radix: 10);
