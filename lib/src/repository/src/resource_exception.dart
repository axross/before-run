import 'package:meta/meta.dart';
import '../../entity/user.dart';
import '../../request_exception.dart';

class ApplicationNotFoundException extends NotFoundException {
  final int id;

  String toString() => 'An application (id: "$id") is not found.';

  ApplicationNotFoundException({@required this.id});
}

class ApplicationForbiddenException extends ForbiddenException {
  final int id;
  final User requester;

  String toString() => 'An application (id: "$id") cannot be browsed by an user (username: "${requester.username}").';

  ApplicationForbiddenException({@required this.id, @required this.requester});
}

class ApplicationConflictException extends ConflictException {
  final String name;
  final User requester;

  String toString() => 'Creating an application (name: "$name") for an user (username: "${requester.username}") is already existed.';

  ApplicationConflictException({@required this.name, @required this.requester});
}

class ApplicationEnvironmentNotFoundException extends NotFoundException {
  final int id;
  final int applicationId;

  String toString() => 'An application environment (id: "$id") of an application (id: "${applicationId}") is not found.';

  ApplicationEnvironmentNotFoundException({@required this.id, @required this.applicationId});
}

class ApplicationEnvironmentForbiddenException extends NotFoundException {
  final int id;
  final int applicationId;
  final User requester;

  String toString() => 'An application environment (id: "$id") of an application (id: "${applicationId}") cannot be browsed by an user (username: "${requester.username}").';

  ApplicationEnvironmentForbiddenException({@required this.id, @required this.applicationId, @required this.requester});
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
