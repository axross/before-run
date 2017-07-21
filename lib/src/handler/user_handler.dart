import 'dart:async' show Future;
import 'dart:convert' show JSON;
import 'dart:io' show ContentType, HttpRequest;
import 'package:meta/meta.dart';
import '../entity/user.dart';
import '../service/authentication_service.dart';

String encodeUser(User user) => JSON.encode({
  'id': user.id,
  'username': user.username,
  'email': user.email,
  'name': user.name,
  'profileImageUrl': user.profileImageUrl,
});

class UserHandler {
  final AuthenticationService _authenticationService;

  Future<dynamic> getMe(HttpRequest request) async {
    try {
      final user = await _authenticationService.authenticate(request);

      request.response
        ..statusCode = 200
        ..headers.contentType = ContentType.JSON
        ..write(encodeUser(user))
        ..close();
    } on AuthenticationException catch (err, stackTrace) {
      print(err.toString());
      print(stackTrace);

      request.response
        ..statusCode = 401
        ..headers.contentType = ContentType.JSON
        ..write(JSON.encode({ 'message': err.toString() }))
        ..close();
    } catch (err, stackTrace) {
      print(err.toString());
      print(stackTrace);

      request.response
        ..statusCode = 500
        ..headers.contentType = ContentType.JSON
        ..write(JSON.encode({ 'message': 'An internal server error has occured.' }))
        ..close();
    }
  }

  UserHandler({@required AuthenticationService authenticationService}):
    _authenticationService = authenticationService;
}
