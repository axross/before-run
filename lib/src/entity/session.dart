import 'package:meta/meta.dart';
import './user.dart';
import './uuid.dart';

class Session {
  final Uuid _firstPart;
  final Uuid _lastPart;

  String get token => '${_firstPart.toString().replaceAll('-', '')}${_lastPart.toString().replaceAll('-', '')}';

  Session({@required Uuid firstPart, @required Uuid lastPart}):
    _firstPart = firstPart,
    _lastPart = lastPart;
  Session.generateWithUser(User user):
    _firstPart = new Uuid.v5('${user.id}'),
    _lastPart = new Uuid.v4();
  Session.fromToken(String token):
    _firstPart = new Uuid.fromString(token.substring(0, 16)),
    _lastPart = new Uuid.fromString(token.substring(16)) {
      assert(token.length == 32);
    }
}
