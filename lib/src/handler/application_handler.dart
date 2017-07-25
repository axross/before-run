import 'dart:async' show Future;
import 'dart:convert' show JSON;
import 'dart:io' show HttpRequest;
import 'package:meta/meta.dart';
import '../entity/application.dart';
import '../exception/bad_request_exception.dart';
import '../repository/application_repository.dart';
import '../service/authentication_service.dart';
import '../utility/receive.dart';
import '../utility/respond.dart';
import '../utility/validate.dart';

void _validatePayloadForCreate(Map<dynamic, dynamic> value) =>
  validate(value, containsPair('name', allOf(isNotNull, matches(new RegExp(r'^[a-z0-9_\-]{1,100}$')))));

String _serializeApplication(Application application) => JSON.encode({
  'id': application.id,
  'name': application.name,
});

class ApplicationHandler {
  final ApplicationRepository _applicationRepository;
  final AuthenticationService _authenticationService;

  Future<dynamic> getApplication(HttpRequest request) async {
    try {
      final id = int.parse(request.uri.path.split('/').last, radix: 10);
      final user = await _authenticationService.authenticate(request);
      final application = await _applicationRepository.getApplication(id: id, owner: user);

      respondAsJson(request, _serializeApplication(application));
    } on BadRequestException catch (err, st) {
      print(err);
      print(st);

      respondException(request, err, statusCode: 400);
    } on AuthenticationException catch (err, st) {
      print(err);
      print(st);
      
      respondException(request, err, statusCode: 401);
    } catch (err, st) {
      print(err);
      print(st);
      
      respondException(request, err, statusCode: 500, message: 'An internal server error has occured.');
    }
  }

  Future<dynamic> createApplication(HttpRequest request) async {
    try {
      final payload = await getPayloadAsJson(request);

      _validatePayloadForCreate(payload);

      final String name = payload['name'];
      final user = await _authenticationService.authenticate(request);
      final application = await _applicationRepository.createApplication(name: name, owner: user);

      respondAsJson(request, _serializeApplication(application));
    } on BadRequestException catch (err, st) {
      print(err);
      print(st);
      
      respondException(request, err, statusCode: 400);
    } on AuthenticationException catch (err, st) {
      print(err);
      print(st);
      
      respondException(request, err, statusCode: 401);
    } catch (err, st) {
      print(err);
      print(st);
      
      respondException(request, err, statusCode: 500, message: 'An internal server error has occured.');
    }
  }
  
  ApplicationHandler({
    @required ApplicationRepository applicationRepository,
    @required AuthenticationService authenticationService,
  }):
    _applicationRepository = applicationRepository,
    _authenticationService = authenticationService;
}