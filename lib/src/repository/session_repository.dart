import 'dart:async';
import 'package:meta/meta.dart';
import 'package:postgresql/postgresql.dart' show Row;
import 'package:postgresql/pool.dart' show Pool;
import '../entity/session.dart';
import '../entity/user.dart';

Session _assembleSession(Row row) => row == null ? null : new Session.fromToken(row.token);

class SessionRepository {
  final Pool _postgresConnectionPool;

  Future<Session> createSession(User user) async {
    final temporarySession = new Session.generateWithUser(user);
    final connection = await _postgresConnectionPool.connect();

    final row = await connection.query('insert into sessions (token, user_id, created_at) values (@token, @userId, @now) returning id, token;', {
      'token': temporarySession.token,
      'userId': user.id,
      'now': new DateTime.now(),
    }).single;

    connection.close();

    return _assembleSession(row);
  }

  SessionRepository({@required Pool postgresConnectionPool}):
    _postgresConnectionPool = postgresConnectionPool;
}