import 'dart:async' show Future;
import 'package:meta/meta.dart';
import 'package:postgresql/postgresql.dart' show PostgresqlException;
import 'package:postgresql/pool.dart' show Pool;
import '../entity/application.dart';
import '../entity/user.dart';
import './src/deserialize.dart';
import './src/resource_exception.dart';

class ApplicationRepository {
  final Pool _postgresConnectionPool;

  Future<Application> getApplication({@required int id, @required User owner}) async {
    final connection = await _postgresConnectionPool.connect();

    try {
      final rows = await connection.query('select id, name, owner_id, created_at from applications where id = @id and owner_id = @ownerId limit 1;', {
        'id': id,
        'ownerId': owner.id,
      }).toList();

      if (rows.isEmpty) {
        throw new ApplicationNotFoundException(owner: owner, id: id);
      }

      return deserializeToApplication(rows[0]);
    } finally {
      connection.close();
    }
  }

  Future<Application> createApplication({@required String name, @required User owner}) async {
    final connection = await _postgresConnectionPool.connect();

    try {
      final row = await connection.query('insert into applications (name, owner_id, created_at) values (@name, @userId, @now) returning id, name, owner_id, created_at;', {
        'name': name,
        'userId': owner.id,
        'now': new DateTime.now(),
      }).single;

      return deserializeToApplication(row);
    } on PostgresqlException catch (err, st) {
      if (err.toString().contains('duplicate key value violates unique constraint')) {
        throw new ApplicationConflictException(owner: owner, name: name);
      }

      rethrow;
    } finally {
      connection.close();
    }
  }
  
  ApplicationRepository({@required postgresConnectionPool}):
    _postgresConnectionPool = postgresConnectionPool;
}
