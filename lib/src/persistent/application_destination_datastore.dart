import 'dart:async' show Future;
import 'dart:convert' show BASE64;
import 'package:meta/meta.dart';
import 'package:postgresql/postgresql.dart' show Connection;
import 'package:pointycastle/pointycastle.dart' show BlockCipher, KeyParameter;
import '../entity/aws_cloudfront.dart';
import '../entity/uuid.dart';
import '../utility/string_to_256bit_uint8list.dart';
import './src/deserialize.dart';

class ApplicationDestinationDatastore {
  final BlockCipher _encrypter;

  Future<AwsCloudfront> createAwsCloudfront(Connection connection, {
    @required String distributionId,
    @required String arn,
    @required String domainName,
    @required String accessKeyId,
    @required String secretAccessKey,
  }) async {
    final row = await connection.query('insert into application_destinations (id, type, payload, created_at) values (@id, @type, @payload, @now) on conflict (id) do update set type = @type, payload = @payload, updated_at = @now returning id, type, payload', {
      'id': new Uuid.v5('AwsCloudfront::$distributionId').toString(),
      'type': 'AWS_CLOUDFRONT',
      'payload': {
        'distributionId': distributionId,
        'arn': arn,
        'domainName': domainName,
        'accessKeyId': BASE64.encode(_encrypter.process(stringTo256bitUint8List(accessKeyId))),
        'secretAccessKey': BASE64.encode(_encrypter.process(stringTo256bitUint8List(secretAccessKey))),
      },
      'now': new DateTime.now(),
    }).single;

    return deserializeToAwsCloudfront(row);
  }

  ApplicationDestinationDatastore({@required String encryptionSecretKey}):
    _encrypter = new BlockCipher('AES')
      ..init(true, new KeyParameter(stringTo256bitUint8List(encryptionSecretKey)));
}