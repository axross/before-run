import 'dart:async' show Future;
import 'package:meta/meta.dart';
import 'package:postgresql/postgresql.dart' show PostgresqlException;
import 'package:postgresql/pool.dart' show Pool;
import '../entity/application.dart';
import '../entity/user.dart';
import './src/deserialize.dart';
import './src/resource_exception.dart';

class ApplicationDatastore {
  final Pool _postgresConnectionPool;

  Future<Application> getApplication({@required int id, @required User requester}) async {
    final connection = await _postgresConnectionPool.connect();

    try {
      final rows = await connection.query('select id, name, owner_id, created_at from applications where id = @id limit 1;', {
        'id': id,
      }).toList();

      if (rows.isEmpty) {
        throw new ApplicationNotFoundException(id: id);
      }

      final application = deserializeToApplication(rows[0]);

      if (application.ownerId != requester.id) {
        throw new ApplicationForbiddenException(id: id, requester: requester);
      }

      return application;
    } finally {
      connection.close();
    }
  }

  Future<Application> createApplication({@required String name, @required User requester}) async {
    final connection = await _postgresConnectionPool.connect();

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
    } finally {
      connection.close();
    }
  }
  
  ApplicationDatastore({@required postgresConnectionPool}):
    _postgresConnectionPool = postgresConnectionPool;
}
