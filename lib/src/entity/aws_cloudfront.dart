import 'package:meta/meta.dart';
import './application_destination.dart';
import './uuid.dart';

class AwsCloudfront implements ApplicationDestination {
  final Uuid id;
  final String distributionId;
  final String arn;
  final String domainName;

  AwsCloudfront({
    @required this.id,
    @required this.distributionId,
    @required this.arn,
    @required this.domainName,
  });
}
