import 'package:meta/meta.dart';
import './uuid.dart';

abstract class ApplicationBucket {
  final Uuid id;

  ApplicationBucket({@required this.id});
}

abstract class ApplicationBucketType {
  static final ApplicationBucketType AwsS3 = new ApplicationBucketType._('AWS_S3');

  String toString();
  String toJson();

  factory ApplicationBucketType._(String value) => new _ApplicationBucketType(value);
}

class _ApplicationBucketType implements ApplicationBucketType {
  final String value;

  String toString() => value;
  String toJson() => toString();

  @override
  operator ==(ApplicationBucketType other) => other.toString() == toString();

  _ApplicationBucketType(String this.value);
}
