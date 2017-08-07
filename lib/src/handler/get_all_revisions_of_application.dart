import 'dart:io' show HttpRequest;
import 'package:meta/meta.dart';
import '../usecase/application_revision_usecase.dart';
import '../usecase/authentication_usecase.dart';
import './src/serialize.dart';
import './src/respond_in_zone.dart';
import './src/extract_session_token.dart';

class GetAllRevisionsOfApplication {
  final ApplicationRevisionUsecase _applicationRevisionUsecase;
  final AuthenticationUsecase _authenticationUsecase;

  void call(HttpRequest request) {
    respondInZone(request, () async {
      final applicationId = _extractApplicationId(request.uri);
      final user = await _authenticationUsecase.authenticate(extractSessionToken(request.headers));
      final revisions = await _applicationRevisionUsecase.getAllByApplicationId(
        applicationId: applicationId,
        requester: user,
      );

      return revisions.map((revision) => serializeApplicationRevision(revision)).toList();
    }, {
      AuthenticationException: 401,
      NoAutorizationException: 401,
      ApplicationForbiddenException: 403,
      ApplicationNotFoundException: 404,
    });
  }

  GetAllRevisionsOfApplication({
    @required ApplicationRevisionUsecase applicationRevisionUsecase,
    @required AuthenticationUsecase authenticationUsecase,
  }):
    _applicationRevisionUsecase = applicationRevisionUsecase,
    _authenticationUsecase = authenticationUsecase;
}

int _extractApplicationId(Uri url) =>
  int.parse(new RegExp(r'applications/([0-9]+)').firstMatch('$url').group(1));
