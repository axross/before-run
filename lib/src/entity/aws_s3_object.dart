import 'package:meta/meta.dart';

class AwsS3Object {
  final String key;
  final int size;
  final String etag;
  final DateTime lastModifiedAt;

  AwsS3Object({@required this.key, @required this.size, @required this.etag, @required this.lastModifiedAt});
}
