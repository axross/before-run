import 'package:meta/meta.dart';
import '../../entity/application.dart';
import '../../entity/user.dart';
import '../../request_exception.dart';

class ApplicationNotFoundException extends NotFoundException {
  final User owner;
  final int id;

  String toString() => 'An application (owner: "${owner.name}", id: "$id") is not found.';

  ApplicationNotFoundException({@required this.owner, @required this.id});
}

class ApplicationConflictException extends ConflictException {
  final User owner;
  final String name;

  String toString() => 'Creating an application (owner: "${owner.name}", name: "$name") is conflicted.';

  ApplicationConflictException({@required this.owner, @required this.name});
}

class ApplicationEnvironmentNotFoundException extends NotFoundException {
  final int applicationId;
  final int id;

  String toString() => 'An application environment (id: "$id") of an application (id: "${applicationId}") is not found.';

  ApplicationEnvironmentNotFoundException({@required this.applicationId, @required this.id});
}

class ApplicationEnvironmentConflictException extends ConflictException {
  final int applicationId;
  final String name;

  String toString() => 'Creating an application environment (name: "$name") for an application (id: "${applicationId}") is conflicted.';

  ApplicationEnvironmentConflictException({@required this.applicationId, @required this.name});
}

class SessionNotFoundException extends NotFoundException {
  final String token;

  String toString() => 'Authentication token "$token" is not a valid token.';

  SessionNotFoundException(this.token);
}

class UserNotFoundException extends NotFoundException {
  final int id;
  final String token;

  String toString() => id != null
    ? 'An user (id: "$id") is not found.'
    : 'An user (authentication token: "$token") is not found.';
  
  UserNotFoundException({this.id, this.token}) {
    assert(id != null || token != null);
  }
}
