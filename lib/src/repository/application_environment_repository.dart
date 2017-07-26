import 'dart:async' show Future;
import 'package:meta/meta.dart';
import 'package:postgresql/postgresql.dart' show PostgresqlException;
import 'package:postgresql/pool.dart' show Pool;
import '../entity/application_environment.dart';
import '../entity/user.dart';
import './src/deserialize.dart';
import './src/resource_exception.dart';

class ApplicationEnvironmentRepository {
  final Pool _postgresConnectionPool;

  Future<ApplicationEnvironment> getEnvironment({@required int id, @required applicationId, @required User owner}) async {
    final connection = await _postgresConnectionPool.connect();

    try {
      final rows = await connection.query('select application_environments.id as id, application_id, application_environments.name as name, application_environments.created_at as created_at from application_environments inner join applications on applications.id = application_environments.application_id where application_environments.id = @id and application_environments.application_id = @applicationId and applications.owner_id = @ownerId limit 1;', {
        'id': id,
        'applicationId': applicationId,
        'ownerId': owner.id,
      }).toList();

      if (rows.isEmpty) {
        throw new ApplicationEnvironmentNotFoundException(applicationId: applicationId, id: id);
      }

      return deserializeToApplicationEnvironment(rows.first);
    } finally {
      connection.close();
    }
  }

  Future<ApplicationEnvironment> createEnvironment({@required String name, @required int applicationId, @required User owner}) async {
    final connection = await _postgresConnectionPool.connect();

    try {
      final applicationRows = await connection.query('select id, name, owner_id, created_at from applications where id = @id and owner_id = @ownerId limit 1;', {
        'id': applicationId,
        'ownerId': owner.id,
      }).toList();

      if (applicationRows.isEmpty) {
        throw new ApplicationNotFoundException(owner: owner, id: applicationId);
      }

      final application = deserializeToApplication(applicationRows.first);

      try {
        final row = await connection.query('insert into application_environments (application_id, name, created_at) values (@applicationId, @name, @now) returning id, application_id, name, created_at;', {
          'applicationId': applicationId,
          'name': name,
          'now': new DateTime.now(),
        }).single;

        return deserializeToApplicationEnvironment(row);
      } on PostgresqlException catch (err) {
        if (err.toString().contains('duplicate key value violates unique constraint')) {
          throw new ApplicationEnvironmentConflictException(applicationId: application.id, name: name);
        }

        rethrow;
      }
    } finally {
      connection.close();
    }
  }
  
  ApplicationEnvironmentRepository({@required postgresConnectionPool}):
    _postgresConnectionPool = postgresConnectionPool;
}
