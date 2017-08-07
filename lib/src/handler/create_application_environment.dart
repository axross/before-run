import 'dart:io' show HttpRequest;
import 'package:meta/meta.dart';
import '../entity/application_bucket.dart';
import '../entity/application_destination.dart';
import '../usecase/application_environment_usecase.dart';
import '../usecase/authentication_usecase.dart';
import '../utility/validate.dart';
import './src/extract_session_token.dart';
import './src/parse_payload_as_json.dart';
import './src/respond_in_zone.dart';
import './src/serialize.dart';

class CreateApplicationEnvironment {
  final ApplicationEnvironmentUsecase _applicationEnvironmentUsecase;
  final AuthenticationUsecase _authenticationUsecase;

  void call(HttpRequest request) {
    respondInZone(request, () async {
      final applicationId = _extractApplicationId(request.uri);
      final user = await _authenticationUsecase.authenticate(extractSessionToken(request.headers));

      final payload = await parsePayloadAsJson(request);
      final name = _extractNameFromPayload(payload);
      final payloadForBucket = _extractPayloadForBucket(payload);
      final payloadForDestination = _extractPayloadForDestination(payload);

      final environment = await _applicationEnvironmentUsecase.create(
        applicationId: applicationId,
        name: name,
        bucketType: payloadForBucket.type,
        bucketName: payloadForBucket.bucketName,
        bucketRegion: payloadForBucket.region,
        bucketAccessKeyId: payloadForBucket.accessKeyId,
        bucketSecretAccessKey: payloadForBucket.secretAccessKey,
        destinationType: payloadForDestination.type,
        destinationDistributionId: payloadForDestination.distributionId,
        destinationAccessKeyId: payloadForDestination.accessKeyId,
        destinationSecretAccessKey: payloadForDestination.secretAccessKey,
        requester: user,
      );

      return serializeApplicationEnvironment(environment);
    }, {
      InvalidHttpRequestException: 400,
      ValidationException: 400,
      AuthenticationException: 401,
      NoAutorizationException: 401,
      UserNotFoundException: 404,
      ApplicationEnvironmentConflictException: 409,
    }, 201);
  }
  
  CreateApplicationEnvironment({
    @required ApplicationEnvironmentUsecase applicationEnvironmentUsecase,
    @required AuthenticationUsecase authenticationUsecase,
  }):
    _applicationEnvironmentUsecase = applicationEnvironmentUsecase,
    _authenticationUsecase = authenticationUsecase;
}

int _extractApplicationId(Uri url) =>
  int.parse(new RegExp(r'applications/([0-9]+)').firstMatch('$url').group(1));

String _extractNameFromPayload(Map<String, dynamic> payload) {
  validate(payload, containsPair('name', allOf(isNotNull, matches(new RegExp(r'^[a-z0-9_\-]{1,100}$')))));

  return payload['name'];
}

_PayloadForBucket _extractPayloadForBucket(Map<String, dynamic> payload) {
  validate(payload, containsPair('bucket', allOf(
    isNotNull,
    containsPair('type', equals('AWS_S3')),
    containsPair('bucketName', isValidString),
    containsPair('region', isValidString),
    containsPair('accessKeyId', isValidString),
    containsPair('secretAccessKey', isValidString),
  )));

  return new _PayloadForBucket(
    type: ApplicationBucketType.AwsS3,
    bucketName: payload['bucket']['bucketName'],
    region: payload['bucket']['region'],
    accessKeyId: payload['bucket']['accessKeyId'],
    secretAccessKey: payload['bucket']['secretAccessKey'],
  );
}

_PayloadForDestination _extractPayloadForDestination(Map<String, dynamic> payload) {
  validate(payload, containsPair('destination', allOf(
    isNotNull,
    containsPair('type', equals('AWS_CLOUDFRONT')),
    containsPair('distributionId', isValidString),
    containsPair('accessKeyId', isValidString),
    containsPair('secretAccessKey', isValidString),
  )));

  return new _PayloadForDestination(
    type: ApplicationDestinationType.AwsCloudfront,
    distributionId: payload['destination']['distributionId'],
    accessKeyId: payload['destination']['accessKeyId'],
    secretAccessKey: payload['destination']['secretAccessKey'],
  );
}

class _PayloadForBucket {
  final ApplicationBucketType type;
  final String bucketName;
  final String region;
  final String accessKeyId;
  final String secretAccessKey;

  _PayloadForBucket({
    @required ApplicationBucketType this.type,
    @required String this.bucketName,
    @required String this.region,
    @required String this.accessKeyId,
    @required String this.secretAccessKey,
  });
}

class _PayloadForDestination {
  final ApplicationDestinationType type;
  final String distributionId;
  final String accessKeyId;
  final String secretAccessKey;

  _PayloadForDestination({
    @required ApplicationDestinationType this.type,
    @required String this.distributionId,
    @required String this.accessKeyId,
    @required String this.secretAccessKey,
  });
}
