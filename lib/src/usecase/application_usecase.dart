import 'dart:async' show Future;
import 'package:meta/meta.dart';
import 'package:postgresql/pool.dart' show Pool;
import '../entity/application.dart';
import '../entity/user.dart';
import '../persistent/application_datastore.dart';

export '../persistent/application_datastore.dart' show
  ApplicationConflictException,
  ApplicationForbiddenException,
  ApplicationNotFoundException;

class ApplicationUsecase {
  final ApplicationDatastore _applicationDatastore;
  final Pool _postgresqlConnectionPool;

  Future<Application> getById({
    @required int id,
    @required User requester,
  }) async {
    final connection = await _postgresqlConnectionPool.connect();

    try {
      return await _applicationDatastore.getById(connection, id: id, requester: requester);
    } finally {
      connection.close();
    }
  }

  Future<Application> create({
    @required String name,
    @required User requester,
  }) async {
    final connection = await _postgresqlConnectionPool.connect();

    try {
      return await _applicationDatastore.create(connection, name: name, requester: requester);
    } finally {
      connection.close();
    }
  }

  ApplicationUsecase({
    @required ApplicationDatastore applicationDatastore,
    @required Pool postgresqlConnectionPool,
  }):
    _applicationDatastore = applicationDatastore,
    _postgresqlConnectionPool = postgresqlConnectionPool;
}
