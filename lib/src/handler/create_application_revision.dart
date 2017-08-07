import 'dart:io' show HttpRequest;
import 'package:meta/meta.dart';
import '../usecase/application_revision_usecase.dart';
import '../usecase/authentication_usecase.dart';
import './src/extract_session_token.dart';
import './src/respond_in_zone.dart';
import './src/serialize.dart';

class CreateApplicationRevision {
  final ApplicationRevisionUsecase _applicationRevisionUsecase;
  final AuthenticationUsecase _authenticationUsecase;

  void call(HttpRequest request) {
    respondInZone(request, () async {
      _validateHeaders(request);

      final applicationId = _extractApplicationId(request.uri);
      final user = await _authenticationUsecase.authenticate(extractSessionToken(request.headers));
      final revision = await _applicationRevisionUsecase.create(
        applicationId: applicationId,
        request: request,
        requester: user,
      );

      return serializeApplicationRevision(revision);
    }, {
      InvalidContentTypeException: 400,
      AuthenticationException: 401,
      NoAutorizationException: 401,
      ApplicationRevisionCreationFailureException: 409,
    }, 201);
  }

  CreateApplicationRevision({
    @required ApplicationRevisionUsecase applicationRevisionUsecase,
    @required AuthenticationUsecase authenticationUsecase,
  }):
    _applicationRevisionUsecase = applicationRevisionUsecase,
    _authenticationUsecase = authenticationUsecase;
}

class InvalidContentTypeException {
  final HttpRequest request;
  final String message;

  String toString() => message;

  InvalidContentTypeException(this.request, {@required this.message});
}

void _validateHeaders(HttpRequest request) {
  if (request.headers.contentType == null ||
      request.headers.contentType.mimeType != 'application/zip') {
    throw new InvalidContentTypeException(request, message: 'This API requires a request as application/zip.');
  }
}

int _extractApplicationId(Uri url) =>
  int.parse(new RegExp(r'applications/([0-9]+)').firstMatch('$url').group(1));
