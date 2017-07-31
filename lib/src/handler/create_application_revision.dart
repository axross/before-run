import 'package:meta/meta.dart';
import '../persistent/application_datastore.dart';
import '../persistent/application_revision_file_storage.dart';
import '../persistent/application_revision_datastore.dart';
import '../service/authentication_service.dart';
import './src/request_handler.dart';
import './src/serialize.dart';
import '../request_exception.dart';

class InvalidContentTypeException extends BadRequestException {
  final HttpRequest request;
  final String message;

  String toString() => message;

  InvalidContentTypeException(this.request, {@required this.message});
}

class CreateApplicationRevision extends RequestHandler {
  final ApplicationDatastore _applicationDatastore;
  final ApplicationRevisionDatastore _applicationRevisionDatastore;
  final AuthenticationService _authenticationService;
  final ApplicationRevisionFileStorage _applicationRevisionFileStorage;

  void call(HttpRequest request) {
    handle(request, () async {
      if (request.headers.contentType == null ||
          request.headers.contentType.mimeType != 'application/zip') {
        throw new InvalidContentTypeException(request, message: 'This API requires a request as application/zip.');
      }

      final applicationId = _extractApplicationId(request.uri);

      // authenticate
      final user = await _authenticationService.authenticate(request);

      // get application
      final application = await _applicationDatastore.getApplication(id: applicationId, requester: user);

      // insert to rdb
      final revision =  await _applicationRevisionDatastore.createRevision(application: application);

      // post to storage
      await _applicationRevisionFileStorage.saveRevisionFile(revision, request);

      // wip: check

      return serializeApplicationRevision(revision);
    }, statusCode: 201);
  }

  CreateApplicationRevision({
    @required ApplicationDatastore applicationDatastore,
    @required ApplicationRevisionDatastore applicationRevisionDatastore,
    @required AuthenticationService authenticationService,
    @required ApplicationRevisionFileStorage applicationRevisionFileStorage,
  }):
    _applicationDatastore = applicationDatastore,
    _applicationRevisionDatastore = applicationRevisionDatastore,
    _authenticationService = authenticationService,
    _applicationRevisionFileStorage = applicationRevisionFileStorage;
}

int _extractApplicationId(Uri url) =>
  int.parse(new RegExp(r'applications/([0-9]+)').firstMatch('$url').group(1), radix: 10);
