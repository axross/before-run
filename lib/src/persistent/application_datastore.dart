import 'dart:async' show Future;
import 'package:meta/meta.dart';
import 'package:postgresql/postgresql.dart' show Connection, PostgresqlException;
import '../entity/application.dart';
import '../entity/user.dart';
import './src/deserialize.dart';

class ApplicationDatastore {
  Future<Application> getById(Connection connection, {@required int id, @required User requester}) async {
    final rows = await connection.query('select id, name, owner_id, created_at from applications where id = @id limit 1;', {
      'id': id,
    }).toList();

    if (rows.isEmpty) {
      throw new ApplicationNotFoundException(id: id);
    }

    final application = deserializeToApplication(rows.single);

    if (application.ownerId != requester.id) {
      throw new ApplicationForbiddenException(id: id, requester: requester);
    }

    return application;
  }

  Future<Application> create(Connection connection, {@required String name, @required User requester}) async {
    try {
      final row = await connection.query('insert into applications (name, owner_id, created_at) values (@name, @ownerId, @now) returning id, name, owner_id, created_at;', {
        'name': name,
        'ownerId': requester.id,
        'now': new DateTime.now(),
      }).single;

      return deserializeToApplication(row);
    } on PostgresqlException catch (err) {
      if (err.toString().contains('duplicate key value violates unique constraint')) {
        throw new ApplicationConflictException(requester: requester, name: name);
      }

      rethrow;
    }
  }
}

class ApplicationNotFoundException implements Exception {
  final int id;

  String toString() => 'An application (id: "$id") is not found.';

  ApplicationNotFoundException({@required this.id});
}

class ApplicationForbiddenException implements Exception {
  final int id;
  final User requester;

  String toString() => 'An application (id: "$id") cannot be browsed by an user (username: "${requester.username}").';

  ApplicationForbiddenException({@required this.id, @required this.requester});
}

class ApplicationConflictException implements Exception {
  final String name;
  final User requester;

  String toString() => 'Creating an application (name: "$name") for an user (username: "${requester.username}") is already existed.';

  ApplicationConflictException({@required this.name, @required this.requester});
}
