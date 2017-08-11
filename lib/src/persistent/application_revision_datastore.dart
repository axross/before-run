import 'dart:async' show Future;
import 'package:meta/meta.dart';
import 'package:postgresql/postgresql.dart' show Connection;
import '../entity/application.dart';
import '../entity/application_revision.dart';
import '../entity/user.dart';
import '../entity/uuid.dart';
import './src/deserialize.dart';

class ApplicationRevisionDatastore {
  Future<Iterable<ApplicationRevision>> getAllOfApplication(Connection connection, {@required Application application}) async {
    final rows = await connection.query('select id, application_id, creator_id, created_at from application_revisions where application_id = @applicationId;', {
      'applicationId': application.id,
    });

    return rows.map<ApplicationRevision>((row) => deserializeToApplicationRevision(row));
  }

  Future<ApplicationRevision> getById(Connection connection, {@required Uuid id, @required User requester}) async {
    final rows = await connection.query('select id, application_id, creator_id, created_at from application_revisions where id = @id limit 1;', {
      'id': '$id',
    }).toList();

    if (rows.length == 0) {
      throw new ApplicationRevisionNotFoundException(id: id);
    }

    return deserializeToApplicationRevision(rows.single);
  }

  Future<ApplicationRevision> create(Connection connection, {@required Application application, @required User requester}) async {
    final row = await connection.query('insert into application_revisions (id, application_id, creator_id, created_at) values (@id, @applicationId, @creatorId, @now) returning id, application_id, creator_id, created_at;', {
      'id': new Uuid.v4().toString(),
      'applicationId': application.id,
      'creatorId': requester.id,
      'now': new DateTime.now(),
    }).single;

    return deserializeToApplicationRevision(row);
  }
}

class ApplicationRevisionCreationFailureException implements Exception {
  final int applicationId;
  final User requester;

  String toString() => 'Creating an application revision for an application (id: "${applicationId}") is failed.';

  ApplicationRevisionCreationFailureException({@required this.applicationId, @required this.requester});
}
