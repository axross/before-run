import 'dart:async' show Future;
import 'dart:convert' show UTF8;
import 'package:http/http.dart' show Request;
import 'package:meta/meta.dart';
import 'package:xml/xml.dart' as xml;
import '../entity/uuid.dart';
import './src/send_aws_http_request.dart';

class AwsCloudfrontClient {
  // a host and region of cloudfront is fixed
  static const host = 'cloudfront.amazonaws.com';
  static const region = 'us-east-1';
  static const serviceName = 'cloudfront';

  Future<AwsCloudfrontDistribution> getDistribution({@required String distributionId, @required accessKeyId, @required secretAccessKey}) async {
    final request = new Request('GET', new Uri.https(host, '/2016-09-29/distribution/$distributionId'));
    final requestId = new Uuid.v4();
    final response = await sendAwsHttpRequest(
      request,
      region: region,
      serviceName: serviceName,
      accessKeyId: accessKeyId,
      secretAccessKey: secretAccessKey,
      requestId: requestId,
    );
    final responseBody = await UTF8.decodeStream(response.stream);
    final parsedXml = xml.parse(responseBody);

    // todo: validation

    return new AwsCloudfrontDistribution(
      distributionId: parsedXml.findElements('Distribution').single.findElements('Id').single.text,
      arn: parsedXml.findElements('Distribution').single.findElements('ARN').single.text,
      domainName: parsedXml.findElements('Distribution').single.findElements('DomainName').single.text,
    );
  }

  AwsCloudfrontClient();
}

class AwsCloudfrontDistribution {
  final String distributionId;
  final String arn;
  final String domainName;

  AwsCloudfrontDistribution({@required this.distributionId, @required this.arn, @required this.domainName});
}

class AwsCloudfrontDistributionNotFound implements Exception {
  final String distributionId;
  final String accessKeyId;
  final String secretAccessKey;

  String toString() => 'An AWS CloudFront distribution (id: "$distributionId") cannot be browsed with pair of access keys.';

  AwsCloudfrontDistributionNotFound({@required this.distributionId, @required this.accessKeyId, @required this.secretAccessKey});
}
