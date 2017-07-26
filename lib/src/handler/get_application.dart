import 'dart:io' show HttpRequest;
import 'package:meta/meta.dart';
import '../entity/application.dart';
import '../repository/application_repository.dart';
import '../service/authentication_service.dart';
import '../request_handler.dart';

Map<String, dynamic> _serializeApplication(Application application) => {
  'id': application.id,
  'name': application.name,
};

class GetApplication extends RequestHandler {
  final ApplicationRepository _applicationRepository;
  final AuthenticationService _authenticationService;

  void call(HttpRequest request) {
    handle(request, () async {
      final id = int.parse(request.uri.path.split('/').last, radix: 10);
      final user = await _authenticationService.authenticate(request);
      final application = await _applicationRepository.getApplication(id: id, owner: user);

      return _serializeApplication(application);
    });
  }
  
  GetApplication({
    @required ApplicationRepository applicationRepository,
    @required AuthenticationService authenticationService,
  }):
    _applicationRepository = applicationRepository,
    _authenticationService = authenticationService;
}