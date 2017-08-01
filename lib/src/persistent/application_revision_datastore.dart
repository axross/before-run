import 'dart:async' show Future;
import 'package:meta/meta.dart';
import 'package:postgresql/pool.dart' show Pool;
import '../entity/application.dart';
import '../entity/application_revision.dart';
import '../entity/user.dart';
import '../entity/uuid.dart';
import './src/deserialize.dart';

class ApplicationRevisionDatastore {
  final Pool _postgresConnectionPool;

  Future<List<ApplicationRevision>> getAllRevisions({@required Application application}) async {
    final connection = await _postgresConnectionPool.connect();

    try {
      final rows = await connection.query('select id, application_id, creator_id, created_at from application_revisions where application_id = @applicationId;', {
        'applicationId': application.id,
      }).toList();

      return rows.map((row) => deserializeToApplicationRevision(row)).toList();
    } finally {
      connection.close();
    }
  }

  Future<ApplicationRevision> createRevision({@required Application application, @required User requester}) async {
    final connection = await _postgresConnectionPool.connect();

    try {
      final row = await connection.query('insert into application_revisions (id, application_id, creator_id, created_at) values (@id, @applicationId, @creatorId, @now) returning id, application_id, creator_id, created_at;', {
        'id': new Uuid.v4().toString(),
        'applicationId': application.id,
        'creatorId': requester.id,
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
