import 'dart:async' show Future;
import 'package:meta/meta.dart';
import 'package:postgresql/postgresql.dart' show Connection, PostgresqlException;
import '../entity/application.dart';
import '../entity/application_environment.dart';
import '../entity/application_bucket.dart';
import '../entity/application_destination.dart';
import '../entity/user.dart';
import './src/deserialize.dart';

class ApplicationEnvironmentDatastore {
  Future<Iterable<ApplicationEnvironment>> getAllOfApplication(Connection connection, {@required Application application}) async {
    final rows = await connection.query('select application_environments.id as id, application_id, application_environments.name as name, bucket_id, destination_id, application_environments.created_at as created_at from application_environments inner join applications on applications.id = application_environments.application_id where application_environments.application_id = @applicationId;', {
      'applicationId': application.id,
    });

    return rows.map((row) => deserializeToApplicationEnvironment(row));
  }

  Future<ApplicationEnvironment> getById(Connection connection, {@required int id, @required Application application, @required User requester}) async {
    final rows = await connection.query('select application_environments.id as id, application_id, application_environments.name as name, bucket_id, destination_id, application_environments.created_at as created_at from application_environments inner join applications on applications.id = application_environments.application_id where application_environments.id = @id and application_environments.application_id = @applicationId limit 1;', {
      'id': id,
      'applicationId': application.id,
    }).toList();

    if (rows.isEmpty) {
      throw new ApplicationEnvironmentNotFoundException(applicationId: application.id, id: id);
    }

    return deserializeToApplicationEnvironment(rows.single);
  }

  Future<ApplicationEnvironment> create(Connection connection, {@required String name, @required ApplicationBucket bucket, @required ApplicationDestination destination, @required Application application, @required User requester}) async {
    try {
      final row = await connection.query('insert into application_environments (application_id, name, bucket_id, destination_id, created_at) values (@applicationId, @name, @bucketId, @destinationId, @now) returning id, application_id, name, bucket_id, destination_id, created_at;', {
        'applicationId': application.id,
        'name': name,
        'bucketId': '${bucket.id}',
        'destinationId': '${destination.id}',
        'now': new DateTime.now(),
      }).single;

      return deserializeToApplicationEnvironment(row);
    } on PostgresqlException catch (err) {
      if (err.toString().contains('duplicate key value violates unique constraint')) {
        throw new ApplicationEnvironmentConflictException(applicationId: application.id, name: name);
      }

      rethrow;
    }
  }
}

class ApplicationEnvironmentNotFoundException implements Exception {
  final int id;
  final int applicationId;

  String toString() => 'An application environment (id: "$id") of an application (id: "${applicationId}") is not found.';

  ApplicationEnvironmentNotFoundException({@required this.id, @required this.applicationId});
}

class ApplicationEnvironmentForbiddenException implements Exception {
  final int id;
  final int applicationId;
  final User requester;

  String toString() => 'An application environment (id: "$id") of an application (id: "${applicationId}") cannot be browsed by an user (username: "${requester.username}").';

  ApplicationEnvironmentForbiddenException({@required this.id, @required this.applicationId, @required this.requester});
}

class ApplicationEnvironmentConflictException implements Exception {
  final int applicationId;
  final String name;

  String toString() => 'Creating an application environment (name: "$name") for an application (id: "${applicationId}") is conflicted.';

  ApplicationEnvironmentConflictException({@required this.applicationId, @required this.name});
}
