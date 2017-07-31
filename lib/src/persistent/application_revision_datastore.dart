import 'dart:async' show Future;
import 'package:meta/meta.dart';
import 'package:postgresql/pool.dart' show Pool;
import '../entity/application.dart';
import '../entity/application_revision.dart';
import '../entity/uuid.dart';
import './src/deserialize.dart';

class ApplicationRevisionDatastore {
  final Pool _postgresConnectionPool;

  Future<ApplicationRevision> createRevision({@required Application application}) async {
    final connection = await _postgresConnectionPool.connect();

    try {
      final row = await connection.query('insert into application_revisions (id, application_id, created_at) values (@id, @applicationId, @now) returning id, application_id, created_at;', {
        'id': new Uuid.v4().toString(),
        'applicationId': application.id,
        'now': new DateTime.now(),
      }).single;

      return deserializeToApplicationRevision(row);
    } finally {
      connection.close();
    }
  }

  ApplicationRevisionDatastore({@required Pool postgresConnectionPool}):
    _postgresConnectionPool = postgresConnectionPool;
}
