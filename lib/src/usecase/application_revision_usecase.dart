import 'dart:async' show Future;
import 'dart:io' show HttpRequest;
import 'package:meta/meta.dart';
import 'package:postgresql/pool.dart' show Pool;
import '../entity/application_revision.dart';
import '../entity/user.dart';
import '../persistent/application_datastore.dart';
import '../persistent/application_revision_datastore.dart';
import '../persistent/application_revision_file_storage.dart';

export '../persistent/application_datastore.dart' show ApplicationForbiddenException, ApplicationNotFoundException;
export '../persistent/application_revision_datastore.dart' show ApplicationRevisionCreationFailureException;

class ApplicationRevisionUsecase {
  final ApplicationDatastore _applicationDatastore;
  final ApplicationRevisionDatastore _applicationRevisionDatastore;
  final ApplicationRevisionFileStorage _applicationRevisionFileStorage;
  final Pool _postgresqlConnectionPool;

  Future<Iterable<ApplicationRevision>> getAllByApplicationId({
    @required int applicationId,
    @required User requester,
  }) async {
    final connection = await _postgresqlConnectionPool.connect();

    try {
      final application = await _applicationDatastore.getById(connection, id: applicationId, requester: requester);

      return await _applicationRevisionDatastore.getAll(connection, application: application);
    } finally {
      connection.close();
    }
  }

  Future<ApplicationRevision> create({
    @required int applicationId,
    @required HttpRequest request,
    @required User requester,
  }) async {
    final connection = await _postgresqlConnectionPool.connect();

    try {
      final application = await _applicationDatastore.getById(
        connection,
        id: applicationId,
        requester: requester,
      );

      ApplicationRevision revision;

      await connection.runInTransaction(() async {
        revision = await _applicationRevisionDatastore.create(
          connection,
          application: application,
          requester: requester,
        );

        await _applicationRevisionFileStorage.saveRevisionFile(revision, request);
      });

      return revision;
    } finally {
      connection.close();
    }
  }

  ApplicationRevisionUsecase({
    @required ApplicationDatastore applicationDatastore,
    @required ApplicationRevisionDatastore applicationRevisionDatastore,
    @required ApplicationRevisionFileStorage applicationRevisionFileStorage,
    @required Pool postgresqlConnectionPool,
  }):
    _applicationDatastore = applicationDatastore,
    _applicationRevisionDatastore = applicationRevisionDatastore,
    _applicationRevisionFileStorage = applicationRevisionFileStorage,
    _postgresqlConnectionPool = postgresqlConnectionPool;
}
