import 'dart:async' show Future;
import 'package:crypto/crypto.dart' show Hmac, sha256, Sha256;
import 'package:http/http.dart' show Request, StreamedResponse;
import 'package:meta/meta.dart';
import '../../entity/uuid.dart';

Future<StreamedResponse> sendAwsHttpRequest(Request request, {
  @required String region,
  @required String serviceName,
  @required String accessKeyId,
  @required String secretAccessKey,
  Uuid requestId
}) async {
  final now = new DateTime.now().toUtc();

  final formattedRequestDatetime = 
    '${now.year}'
    '${now.month.toString().padLeft(2, '0')}'
    '${now.day.toString().padLeft(2, '0')}T'
    '${now.hour.toString().padLeft(2, '0')}'
    '${now.minute.toString().padLeft(2, '0')}'
    '${now.second.toString().padLeft(2, '0')}Z';
  final formattedRequestDate = formattedRequestDatetime.substring(0, 8);
  
  final headers = <String, String>{
    'content-type': 'application/json',
    'date': formattedRequestDatetime,
    'host': request.url.host,
    'x-amz-request-id': (requestId == null ? new Uuid.v4() : requestId).toString(),
  };

  if (request.bodyBytes.length > 0) {
    headers['content-length'] = '${request.bodyBytes.length}';
  }

  final sortedHeadersKeys = headers.keys.toList()..sort();

  final canonicalRequest = 
    '${request.method}\n'
    '${request.url.path}\n'
    '${request.url.query}\n' +
    sortedHeadersKeys
      .map((key) => '$key:${headers[key]}')
      .join('\n') + '\n'
    '\n' +
    sortedHeadersKeys.join(';') + '\n' +
    (sha256 as Sha256).convert(request.bodyBytes).toString();

  final stringToSign = 
    'AWS4-HMAC-SHA256\n'
    '$formattedRequestDatetime\n'
    '${formattedRequestDate}/$region/$serviceName/aws4_request\n' +
    (sha256 as Sha256).convert(canonicalRequest.codeUnits).toString();

  print('--------');
  print(canonicalRequest);
  print('--------');
  print(stringToSign);

  final key = new Hmac(
    sha256,
    new Hmac(
      sha256,
      new Hmac(
        sha256,
        new Hmac(
          sha256,
          'AWS4$secretAccessKey'.codeUnits,
        ).convert(formattedRequestDate.codeUnits).bytes,
      ).convert(region.codeUnits).bytes,
    ).convert(serviceName.codeUnits).bytes,
  ).convert('aws4_request'.codeUnits).bytes;

  final signature = new Hmac(sha256, key).convert(stringToSign.codeUnits).toString();

  request.headers.addAll(headers);
  request.headers['authorization'] =
    'AWS4-HMAC-SHA256 '
    'Credential=$accessKeyId/$formattedRequestDate/$region/$serviceName/aws4_request, '
    'SignedHeaders=${sortedHeadersKeys.join(';')}, '
    'Signature=$signature';

  return await request.send();
}
