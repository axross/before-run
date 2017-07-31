import 'package:meta/meta.dart';
import '../service/authentication_service.dart';
import './src/request_handler.dart';
import './src/serialize.dart';

class GetMe extends RequestHandler {
  final AuthenticationService _authenticationService;

  void call(HttpRequest request) {
    handle(request, () async {
      final user = await _authenticationService.authenticate(request);

      return serializeUser(user);
    });
  }

  GetMe({@required AuthenticationService authenticationService}):
    _authenticationService = authenticationService;
}
