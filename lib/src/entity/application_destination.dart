import 'package:meta/meta.dart';
import './uuid.dart';

abstract class ApplicationDestination {
  final Uuid id;

  ApplicationDestination({@required this.id});
}

abstract class ApplicationDestinationType {
  static final ApplicationDestinationType AwsCloudfront = new ApplicationDestinationType._('AWS_CLOUDFRONT');

  String toString();
  String toJson();

  factory ApplicationDestinationType._(String value) => new _ApplicationDestinationType(value);
}

class _ApplicationDestinationType implements ApplicationDestinationType {
  final String value;

  String toString() => value;
  String toJson() => toString();

  @override
  operator ==(ApplicationDestinationType other) => other.toString() == toString();

  _ApplicationDestinationType(String this.value);
}
