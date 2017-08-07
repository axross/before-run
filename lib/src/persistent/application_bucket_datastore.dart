import 'dart:async' show Future;
import 'dart:convert' show BASE64;
import 'package:meta/meta.dart';
import 'package:postgresql/postgresql.dart' show Connection;
import 'package:pointycastle/pointycastle.dart' show BlockCipher, KeyParameter;
import '../entity/aws_s3.dart';
import '../entity/uuid.dart';
import '../utility/string_to_uint8list.dart';
import './src/deserialize.dart';

class ApplicationBucketDatastore {
  final BlockCipher _encrypter;

  Future<AwsS3> createAwsS3(Connection connection, {
    @required String bucketName,
    @required String accessKeyId,
    @required String secretAccessKey,
  }) async {
    final row = await connection.query('insert into application_buckets (id, type, payload, created_at) values (@id, @type, @payload, @now) on conflict (id) do update set type = @type, payload = @payload, updated_at = @now returning id, type, payload', {
      'id': new Uuid.v5('AwsS3::$bucketName').toString(),
      'type': 'AWS_S3',
      'payload': {
        'bucketName': bucketName,
        'accessKeyId': BASE64.encode(_encrypter.process(stringToUint8List(accessKeyId))),
        'secretAccessKey': BASE64.encode(_encrypter.process(stringToUint8List(secretAccessKey))),
      },
      'now': new DateTime.now(),
    }).single;

    return deserializeToAwsS3(row);
  }

  ApplicationBucketDatastore({@required String encryptionSecretKey}):
    _encrypter = new BlockCipher('AES')
      ..init(true, new KeyParameter(stringToUint8List(encryptionSecretKey)));
}