import 'dart:async' show Future;
import 'dart:convert' show UTF8;
import 'package:http/http.dart' show Request;
import 'package:meta/meta.dart';
import 'package:xml/xml.dart' as xml;
import '../entity/aws_s3_object.dart';
import './src/aws_client.dart';

class AwsS3Client extends AwsClient {
  static const serviceName = 's3';

  Future<Iterable<AwsS3Object>> getAllObjectsOfBucket({@required String bucketName, @required String region, @required accessKeyId, @required secretAccessKey}) async {
    final request = new Request('GET', new Uri.https('$bucketName.s3.amazonaws.com', '/', {
      'list-type': '2',
    }));

    final response = await sendRequest(
      request,
      region: region,
      serviceName: serviceName,
      accessKeyId: accessKeyId,
      secretAccessKey: secretAccessKey,
    );

    final responseBody = await UTF8.decodeStream(response.stream);

    print(response.statusCode);
    print(responseBody);

    final parsedXml = xml.parse(responseBody);

    return parsedXml.findElements('Contents').map<AwsS3Object>((node) => new AwsS3Object(
      key: node.findElements('Key').single.text,
      size: int.parse(node.findElements('Size').single.text) ,
      etag: node.findElements('ETag').single.text,
      lastModifiedAt: DateTime.parse(node.findElements('LastModified').single.text),
    ));
  }
}
