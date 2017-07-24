import 'dart:async' show Future;
import 'dart:convert' show JSON;
import 'dart:io' show HttpRequest;
import 'package:meta/meta.dart';
import '../entity/user.dart';
import '../service/authentication_service.dart';
import '../utility/respondException.dart';
import '../utility/respondPayload.dart';

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

      respondPayload(request, encodeUser(user));
    } on AuthenticationException catch (err, st) {
      print(err);
      print(st);
      
      respondException(request, err, statusCode: 401);
    } catch (err, st) {
      print(err);
      print(st);

      respondException(request, err, message: 'An internal server error has occured.');
    }
  }

  UserHandler({@required AuthenticationService authenticationService}):
    _authenticationService = authenticationService;
}
