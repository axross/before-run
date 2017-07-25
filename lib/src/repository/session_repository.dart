import 'dart:async';
import 'package:meta/meta.dart';
import 'package:postgresql/postgresql.dart' show Row;
import 'package:postgresql/pool.dart' show Pool;
import '../entity/session.dart';
import '../entity/user.dart';

Session _assembleSession(Row row) => row == null ? null : new Session.fromToken(row.token);

class SessionNotFoundException implements Exception {
  final String token;

  String toString() => 'Authentication token "$token" is not a valid token.';

  SessionNotFoundException(this.token);
}

class SessionRepository {
  final Pool _postgresConnectionPool;

  Future<Session> getSessionByToken(String token) async {
    final connection = await _postgresConnectionPool.connect();

    try {
      final rows = await connection.query('select token from sessions where token = @token limit 1;', {
        'token': token,
      }).toList();

      if (rows.length != 1) {
        throw new SessionNotFoundException(token);
      }

      return _assembleSession(rows.first);
    } finally {
      connection.close();
    }
  }

  Future<Session> createSession(User user) async {
    final connection = await _postgresConnectionPool.connect();

    try {
      final temporarySession = new Session.generateWithUser(user);
      final row = await connection.query('insert into sessions (token, user_id, created_at) values (@token, @userId, @now) returning token;', {
        'token': temporarySession.token,
        'userId': user.id,
        'now': new DateTime.now(),
      }).single;

      return _assembleSession(row);
    } finally {
      connection.close();
    }
  }

  Future<dynamic> deleteSession(String token) async {
    final connection = await _postgresConnectionPool.connect();

    try {
      final affectedRows = await connection.execute('delete from sessions where token = @token;', {
        'token': token,
      });

      

      if (affectedRows == 0) {
        throw new SessionNotFoundException(token);
      }
    } finally {
      connection.close();
    }
  }

  SessionRepository({@required Pool postgresConnectionPool}):
    _postgresConnectionPool = postgresConnectionPool;
}