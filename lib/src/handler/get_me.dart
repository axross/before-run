import 'dart:io' show HttpRequest;
import 'package:meta/meta.dart';
import '../entity/user.dart';
import '../service/authentication_service.dart';
import '../request_handler.dart';

String _serializeUser(User user) => {
  'id': user.id,
  'username': user.username,
  'email': user.email,
  'name': user.name,
  'profileImageUrl': user.profileImageUrl,
};

class GetMe extends RequestHandler {
  final AuthenticationService _authenticationService;

  void call(HttpRequest request) {
    handle(request, () async {
      final user = await _authenticationService.authenticate(request);

      return _serializeUser(user);
    });
  }

  GetMe({@required AuthenticationService authenticationService}):
    _authenticationService = authenticationService;
}
