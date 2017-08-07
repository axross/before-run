import 'package:meta/meta.dart';
import './uuid.dart';

class ApplicationEnvironment {
  final int id;
  final String name;
  final Uuid bucketId;
  final Uuid destinationId;

  ApplicationEnvironment({@required this.id, @required this.name, @required this.bucketId, @required this.destinationId});
}
