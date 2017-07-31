import 'package:meta/meta.dart';
import './uuid.dart';

class ApplicationRevision {
  Uuid id;
  DateTime createdAt;

  ApplicationRevision({@required this.id, @required this.createdAt});
}
