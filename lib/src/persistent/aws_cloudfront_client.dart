import 'dart:async' show Future;
import 'dart:convert' show UTF8;
import 'package:http/http.dart' show Request;
import 'package:meta/meta.dart';
import 'package:xml/xml.dart' as xml;
import '../entity/uuid.dart';
import './src/aws_client.dart';
import './src/resource_exception.dart';

class AwsCloudfrontClient extends AwsClient {
  // a host and region of cloudfront is fixed
  static const host = 'cloudfront.amazonaws.com';
  static const region = 'us-east-1';
  static const serviceName = 'cloudfront';

  Future<AwsCloudfrontDistribution> getDistribution({@required String distributionId, @required accessKeyId, @required secretAccessKey}) async {
    final request = new Request('GET', new Uri.https(host, '/2016-09-29/distribution/$distributionId'));
    final requestId = new Uuid.v4();
    final response = await sendRequest(
      request,
      region: region,
      serviceName: serviceName,
      accessKeyId: accessKeyId,
      secretAccessKey: secretAccessKey,
      requestId: requestId,
    );
    final responseBody = await UTF8.decodeStream(response.stream);

    if (response.statusCode == 404) {
      throw new AwsCloudfrontDistributionNotFound(
        distributionId: distributionId,
        accessKeyId: accessKeyId,
        secretAccessKey: secretAccessKey,
      );
    }

    final parsedXml = xml.parse(responseBody);

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
