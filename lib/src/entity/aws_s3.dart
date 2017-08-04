import 'package:meta/meta.dart';
import './application_bucket.dart';
import './uuid.dart';

class AwsS3 implements ApplicationBucket {
  final Uuid id;
  final String bucketName;

  AwsS3({@required this.id, @required this.bucketName});
}
